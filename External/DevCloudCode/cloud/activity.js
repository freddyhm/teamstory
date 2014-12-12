Parse.Cloud.job("deleteDuplicateFollowing", function(request, status) {
                
                // Set up to modify user data
                Parse.Cloud.useMasterKey();
                
                // Query for all users, used only to break down large +1000 plus query into queries for each user with follows
                var queryUser = new Parse.Query(Parse.User);
                queryUser.limit("1000");
                
                var allFollowingEntries = [];
                var followingQuery = new Parse.Query('Activity');
                var count = 0;
                
                // get all follow activities and include user field
                followingQuery.equalTo("type", "follow");
                followingQuery.include("toUser");
                followingQuery.include("fromUser");
                
                queryUser.find({
                               
                               success: function(results){
                               
                               for(var i = 0; i < results.length; i++){
                               
                               // followings for user
                               followingQuery.equalTo("fromUser", results[i]);
                               
                               followingQuery.each(function(following){
                                                   
                                                   // get following user display name and follower
                                                   var toUser = following.get("toUser");
                                                   var fromUser = following.get("fromUser");
                                                   
                                                   
                                                   
                                                   // make sure the user exists
                                                   if(typeof toUser !== "undefined"){
                                                   
                                                   // create unique combo to check for duplicates through whole db
                                                   var comboUnique = toUser.id + fromUser.id;
                                                   
                                                   var displayName = fromUser.get("displayName");
                                                   
                                                   //console.log(allFollowingEntries);
                                                   
                                                   // if not already in array, push else destroy duplicate
                                                   if(allFollowingEntries.indexOf(comboUnique) == -1){
                                                   allFollowingEntries.push(comboUnique);
                                                   }else{
                                                   
                                                   //console.log("GOING TO DELETE COMBO: " + comboUnique);
                                                   //console.log("FOR USER: " + displayName);
                                                   
                                                   following.destroy({
                                                                     success: function(result) {
                                                                     //console.log("DELETED FOLLOWING ID: " + following.id);
                                                                     //console.log("FOR USER: " + displayName);
                                                                     
                                                                     }, error: function(result, error){
                                                                     console.log(error);
                                                                     }
                                                                     });
                                                   }
                                                   }else{
                                                   
                                                   console.log(count);
                                                   count++;
                                                   following.destroy({
                                                                     success: function(result) {
                                                                     //console.log("GOING TO DELETE COMBO: " + comboUnique);
                                                                     //console.log("FOR USER: " + displayName);
                                                                     }, error: function(result, error){
                                                                     console.log(error);
                                                                     }
                                                                     });
                                                   
                                                   }
                                                   });
                               }
                               }
                               });
});


Parse.Cloud.beforeSave('Activity', function(request, response) {
                       var currentUser = request.user;
                       var objectUser = request.object.get('fromUser');
                       
                       if(!currentUser || !objectUser) {
                       response.error('An Activity should have a valid fromUser.');
                       } else if (currentUser.id === objectUser.id) {
                       response.success();
                       } else {
                       response.error('Cannot set fromUser on Activity to a user other than the current user.');
                       }
                       
                       });

Parse.Cloud.afterSave('Activity', function(request) {
                      var fromUser = request.object.get("fromUser");
                      var fromUserId = fromUser != undefined ? request.object.get("fromUser").id : "";
                      var fromUserEmail = fromUser != undefined ? request.user.get("email") : "";
                      
                      if (request.object.get("type") === "membership") {
                      var Mailgun = require('mailgun');
                      Mailgun.initialize('teamstoryapp.com', 'key-57rdy7ishc75mi99405w246l22tyevt8');
                      
                      Mailgun.sendEmail({
                                        to: fromUserEmail,
                                        from: "info@teamstoryapp.com",
                                        subject: "Getting Into Teamstory!",
                                        text: "Hey there!\n\nThanks for signing up for Teamstory.\nWe’re working hard to create a great collaborative platform where entrepreneurs & startups can capture and share their unique moments.\nWe’re currently invite-only to focus on the quality of the community. All members are reviewed manually.\n\nWe’ll get back to you soon. Please send us an email if you have any questions.\n\n\nTeamstory Crew\n\nhttps://angel.co/teamstory\nhttp://twitter.com/teamstoryapp"
                                        }, {
                                        success: function(httpResponse) {
                                        console.log(httpResponse);
                                        response.success("Email sent!");
                                        },
                                        error: function(httpResponse) {
                                        console.error(httpResponse);
                                        response.error("Uh oh, something went wrong");
                                        }
                                        });
                      return;
                      }
                      
                      
                      var toUser = request.object.get("toUser");
                      var toUserId = toUser != undefined ? request.object.get("toUser").id : "";
                      var photoId = request.object.get("photo") != undefined ? request.object.get("photo").id : "";
                      
                      var isSelfie = toUserId == fromUserId;
                      var atmentionUserArray = new Array();

                      toUser.increment('activityBadge', 1);
                      toUser.save();
                      
                      atmentionUserArray = request.object.get("atmention") != undefined ? request.object.get("atmention") : "";
                      
                      // Only send push notifications for new activities
                      if (request.object.existed()) {
                      return;
                      }
                      
                      // when something is posted, notify followers
                      if(!toUser && request.object.get("type") === "post"){
                      
                           // get picture object so we can find type of picture
                           var post = request.object.get("photo");
                           post.fetch({
                                     success: function(post) {
                                      
                                      // change wording "picture" to "moment"
                                      var postType = post.get("type") == "picture" ? "moment" : post.get("type");
                                      
                                      // send request and type of pic to notification method
                                      notifyFollowers(request, postType);
                                     }
                            });

                            return;
                      }else if(!toUser) {
                          throw "Undefined toUser. Skipping push for Activity " + request.object.get('type') + " : " + request.object.id;
                          return;
                      }
                      
                      if (atmentionUserArray.length > 0) {
                      for (i = 0; i < atmentionUserArray.length; i++) {
                      var atmetionUserQuery = new Parse.Query(Parse.Installation);
                      console.log("atmention array loop");
                      atmetionUserQuery.equalTo("user", atmentionUserArray[i]);
                      
                      Parse.Push.send({
                                      where: atmetionUserQuery,
                                      data: alertPayload(request)
                                      }).then(function() {
                                              console.log('Sent atmention push');
                                              }, function(error) {
                                              throw "Push Error" + error.code + " : " + error.message;
                                              });
                      }
                      }
                      
                      // notify all users except fromUser who are subscribed to post when new comment is sent
                      if(request.object.get("type") === "comment" && atmentionUserArray.length == 0){
                      
                      var subscriptionQuery = new Parse.Query("Subscription");
                      var Photo = Parse.Object.extend("Photo");
                      var photoPointer = new Photo();
                      photoPointer.id = photoId;
                      
                      // find all the subscriptions with this post
                      subscriptionQuery.equalTo("post", photoPointer);
                      
                      subscriptionQuery.find({
                                             success: function(results) {
                                             
                                             /* add all subscribers to new comment and save.
                                              This is so we can pull in activity feed from
                                              client side. */
                                             
                                             request.object.set("subscribers", results);
                                             request.object.save();
                                             
                                             // loop through all subscribers
                                             for (var i = 0; i < results.length; i++) {
                                             
                                             /* notify user except for comment author (fromUserId), post author is not subscribed to own post (client-side check) */
                                             
                                             if(fromUserId != results[i].get("subscriber").id){
                                             
                                             // notify subscriber
                                             var query = new Parse.Query(Parse.Installation);
                                             query.equalTo("user", results[i].get("subscriber"));
                                             
                                             Parse.Push.send({
                                                             where: query,
                                                             data: alertPayload(request)
                                                             }).then(function() {
                                                                     // Push was successful
                                                                     console.log('Sent subscribers push.');
                                                                     }, function(error) {
                                                                     throw "Push Error " + error.code + " : " + error.message;
                                                                     });
                                             }
                                             }
                                             },
                                             error: function(error) {
                                             console.error("Error: " + error.code + " " + error.message);
                                             }
                                             });
                      }
                      
                      // send activity/post owner notification if someone else creates activity
                      if(!isSelfie && atmentionUserArray.length == 0){
                      
                      var toOwnerQuery = new Parse.Query(Parse.Installation);
                      toOwnerQuery.equalTo('user', toUser);
                      
                      Parse.Push.send({
                                      where: toOwnerQuery, // Set our Installation query.
                                      data: alertPayload(request)
                                      }).then(function() {
                                              // Push was successful
                                              console.log('Sent owner push.');
                                              }, function(error) {
                                              throw "Push Error " + error.code + " : " + error.message;
                                              });
                      
                      
                      }
                      
                      toUser.increment('activityBadge', 1);
                      toUser.save();
                      
                      // Only send push notifications for new activities
                      
                      if (request.object.existed()) {
                      return;
                      }
                      
                      if (!toUser) {
                      throw "Undefined toUser. Skipping push for Activity " + request.object.get('type') + " : " + request.object.id;
                      return;
                      }
                      
                      if(request.object.get('photo').id != undefined && request.object.get('type') != undefined){
                      Parse.Cloud.run("incrementCounter", {currentObjectId: request.object.get('photo').id, type: request.object.get('type')});
                      }
                      
                      });
                      
                      
  // find the author's followers and send them a push
  var notifyFollowers = function(request, postType){
      
      // get author and prepare activity query
      var postAuthor = request.object.get("fromUser");
      var notifyFollowersQuery = new Parse.Query("Activity");
      
      // create pointer to post activity to save in query
      var Activity  = Parse.Object.extend("Activity");
      var postActivity = new Activity();
      postActivity.id = request.object.id;
    
      // get all follow activities related to the author
      notifyFollowersQuery.equalTo("type", "follow");
      notifyFollowersQuery.equalTo("toUser", postAuthor);
      
      notifyFollowersQuery.find({
                                
            success: function(results) {
                                
                // loop through all followers
                for (var i = 0; i < results.length; i++) {
                console.log(results[i]);
                var follower = results[i].get("fromUser");
                
                // notify follower
                var installationQuery = new Parse.Query(Parse.Installation);
                installationQuery.equalTo("user", follower);
                
                // save notice in follower table
                var FollowerObj = Parse.Object.extend("Follower");
                var followerObj = new FollowerObj();
                
                // set and save the new follower object
                followerObj.set("follower", follower);
                followerObj.set("following", postAuthor);
                followerObj.set("postActivity", postActivity);
                followerObj.save(null, {
                                 success: function(newFollowerObj) {
                                    
                                 /* add follower as a subscriber in post activity.
                                  This is so we can pull in activity feed from
                                  client side. Similar to comment subscription. */
                                 
                                    request.object.add("subscribers", newFollowerObj);
                                    request.object.save();
                                 },
                                 error: function(newFollowerObj, error) {
                                 // Execute any logic that should take place if the save fails.
                                 // error is a Parse.Error with an error code and message.
                                 alert('Failed to create new object, with error code: ' + error.message);
                                 }
                });
                
                
                 // send push notification with proper message
                 Parse.Push.send({
                 where: installationQuery,
                 data: alertPayload(request, postType)
                 }).then(function() {
                 console.log('Sent follower push');
                 }, function(error) {
                 throw "Push Error" + error.code + " : " + error.message;
                 });
                }
                
                
                },
                error: function(error) {
                console.error("Error: " + error.code + " " + error.message);
            }
    });
  }
                      


var alertMessage = function(request, postType) {
    var message = "";
    
    var atmentionUserArray = new Array();
    
    atmentionUserArray = request.object.get("atmention") != undefined ? request.object.get("atmention") : "";
    
    if (request.object.get("type") === "comment" && atmentionUserArray.length == 0) {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ': ' + request.object.get('content').trim();
        } else {
            message = "Someone commented on your post";
        }
    } else if (request.object.get("type") === "comment" && atmentionUserArray.length > 0) {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' mentioned you in a post';
        } else {
            message = "Someone mentioned you in a post";
        }
    } else if (request.object.get("type") === "like") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' likes your post';
        } else {
            message = 'Someone likes your post';
        }
    } else if (request.object.get("type") === "like comment") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' likes your comment';
        } else {
            message = 'Someone likes your comment.';
        }
    } else if (request.object.get("type") === "follow") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' is now following you';
        }
    }else if (request.object.get("type") === "post") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' posted a ' + postType;
        } else {
            message = 'Someone you are following posted a ' + postType;
        }
    }else{
        message = "You have a new follower.";
    }
    
    // Trim our message to 140 characters.
    if (message.length > 140) {
        message = message.substring(0, 140);
    }
    
    return message;
}

var alertPayload = function(request, postType) {
    var payload = {};
    
    if (request.object.get("type") === "comment") {
        return {
        alert: alertMessage(request), // Set our alert message.
        badge: 'Increment', // Increment the target device's badge count.
            // The following keys help load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'c', // Activity Type: Comment
        fu: request.object.get('fromUser').id, // From User
        pid: request.object.get('photo').id, // Photo Id
        aid: request.object.id // Activity Id
        };
    } else if (request.object.get("type") === "like") {
        return {
        alert: alertMessage(request), // Set our alert message.
        badge: 'Increment',
            // The following keys help load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'l', // Activity Type: Like
        fu: request.object.get('fromUser').id, // From User
        pid: request.object.get('photo').id, // Photo Id
        aid: request.object.id // Activity Id
        };
    } else if (request.object.get("type") === "like comment") {
        return {
        alert: alertMessage(request), // Set our alert message.
        badge: 'Increment',
            // The following keys help load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'lc', // Activity Type: Like Comment
        fu: request.object.get('fromUser').id, // From User
        pid: request.object.get('photo').id, // Photo Id
        aid: request.object.id // Activity Id
        };
    } else if (request.object.get("type") === "follow") {
        return {
        alert: alertMessage(request), // Set our alert message.
        badge: 'Increment',
            // The following keys help load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'f', // Activity Type: Follow
        fu: request.object.get('fromUser').id, // From User
        aid: request.object.id // Activity Id
        };
    } else if (request.object.get("type") === "post") {
        return {
        alert: alertMessage(request, postType), // Set our alert message.
        badge: 'Increment', // Increment the target device's badge count.
            // The following keys help load the correct data in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'po', // Post Type: post
        fu: request.object.get('fromUser').id, // From User
        pid: request.object.get('photo').id, // Photo Id
        aid: request.object.id // Activity Id
        };
    }
}


Parse.Cloud.define ('incrementCounter', function(request, response) {
                    Parse.Cloud.useMasterKey();
                    
                    var query = new Parse.Query('Photo');
                    query.get(request.params.currentObjectId, {
                              success: function(counter) {
                              var points;
                              if (request.params.type === 'comment') {
                              points = 2;
                              } else {
                              points = 1;
                              }
                              
                              if (counter.get('discoverCount') === undefined) {
                              counter.set('discoverCount', points);
                              } else {
                              counter.set('discoverCount', counter.get('discoverCount') + points);
                              }
                              
                              return counter.save({
                                                  success:function () {
                                                  response.success("Successfully incremented counter");
                                                  },
                                                  error:function (error) {
                                                  response.error("Could not increment the counter: " + error.message);
                                                  }});
                              },
                              error: function() {
                              response.error('could not be saved');
                              }
                              });
                    });