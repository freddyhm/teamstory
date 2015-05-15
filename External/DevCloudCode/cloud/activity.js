Parse.Cloud.job("photoCount", function(request, status) {
                // Set up to modify user data
                Parse.Cloud.useMasterKey();
                // Query for all users
                var query = new Parse.Query(Parse.User);
                query.doesNotExist("postCount");
                query.exists("displayName");
                query.each(function(user) {
                           var subQuery = new Parse.Query("Photo");
                           subQuery.equalTo("user", user);
                           subQuery.count({
                                          success: function(number) {
                                          // Set and save the change
                                          user.set("postCount", number);
                                          return user.save();
                                          },
                                          error: function(error) {
                                          // error is an instance of Parse.Error.
                                          console.log(error);
                                          }
                                          });
                           }).then(function() {
                                   // Set the job's success status
                                   status.success("User photo counting completed successfully.");
                                   }, function(error) {
                                   // Set the job's error status
                                   status.error("Uh oh, something went wrong.");
                                   console.log(error);
                                   });
                });

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


Parse.Cloud.job("notifyFollowersJob", function(request, status) {
                
                Parse.Cloud.useMasterKey();
                
                // create pointer to post activity to save in query
                var Author = Parse.Object.extend("User");
                var postAuthor = new Author();
                var postAuthorId = request.params.postAuthorId;
                postAuthor.id = postAuthorId;
                
                var notifyFollowersQuery = new Parse.Query("Activity");
                
                // create pointer to post activity to save in query
                var Activity  = Parse.Object.extend("Activity");
                var postActivityQuery = new Parse.Query(Activity);
                
                var activityId = request.params.activityId;
                var displayName = request.params.displayName;
                var postId = request.params.postId;
                var postType = request.params.postType;
                
                var f = 0;
                
                
                
                var pushMsg = displayName + ' posted a ' + postType;
                
                var pushData = {
                alert: pushMsg, // Set our alert message.
                badge: 'Increment', // Increment the target device's badge count.
                // The following keys help load the correct data in response to this push notification.
                p: 'a', // Payload Type: Activity
                t: 'po', // Post Type: post
                fu: postAuthor.id, // From User
                pid: postId, // Photo Id
                aid: activityId // Activity Id
                };
                
                
                console.log("in notify");
                
                postActivityQuery.get(activityId, {
                                      success: function(postActivity) {
                                      
                                      // The object was retrieved successfully.
                                      console.log("in activity query");
                                      
                                      // get all follow activities related to the author
                                      notifyFollowersQuery.equalTo("type", "follow");
                                      notifyFollowersQuery.equalTo("toUser", postAuthor);
                                      notifyFollowersQuery.include("fromUser");
                                      
                                      notifyFollowersQuery.find({
                                                                
                                                                success: function(results) {
                                                                
                                                                console.log("in follow");
                                                                
                                                                // use to keep track of duplicate followers
                                                                var notifiedUsers = [];
                                                                
                                                                // loop through all followers
                                                                for (var i = 0; i < results.length; i++) {
                                                                
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
                                                                
                                                                // check if we've already sent notification
                                                                if(notifiedUsers.indexOf(follower.id) == -1)
                                                                {
                                                                // add to list of users we sent pushes
                                                                notifiedUsers.push(follower.id);
                                                                
                                                                followerObj.save(null, {
                                                                                 success: function(newFollowerObj) {
                                                                                 
                                                                                 
                                                                                 console.log("in follow obj");
                                                                                 
                                                                                 /* add follower as a subscriber in post activity.
                                                                                  This is so we can pull in activity feed from
                                                                                  client side. Similar to comment subscription. */
                                                                                 
                                                                                 postActivity.add("subscribers", newFollowerObj);
                                                                                 
                                                                                 console.log("saving act in subs");
                                                                                 
                                                                                 
                                                                                 postActivity.save(null, {
                                                                                                   success: function(obj) {
                                                                                                   
                                                                                                   console.log("saved act in subs");
                                                                                                   // check if
                                                                                                   
                                                                                                   
                                                                                                   
                                                                                                   f++;
                                                                                                   console.log(results.length);
                                                                                                   if(f == results.length){
                                                                                                   
                                                                                                   console.log("success!");
                                                                                                   status.success();
                                                                                                   }
                                                                                                   },
                                                                                                   error: function(obj, error) {
                                                                                                   console.log(error);
                                                                                                   }
                                                                                                   });
                                                                                 
                                                                                 },
                                                                                 error: function(newFollowerObj, error) {
                                                                                 // Execute any logic that should take place if the save fails.
                                                                                 // error is a Parse.Error with an error code and message.
                                                                                 alert('Failed to create new object, with error code: ' + error.message);
                                                                                 }
                                                                                 });
                                                                
                                                                // update activity badge for follower
                                                                var newActivityBadge = follower.get("activityBadge") + 1;
                                                                follower.set("activityBadge", newActivityBadge);
                                                                follower.save();
                                                                
                                                                // send push notification with proper message
                                                                Parse.Push.send({
                                                                                where: installationQuery,
                                                                                data: pushData
                                                                                }).then(function() {
                                                                                        console.log('Sent follower push');
                                                                                        }, function(error) {
                                                                                        throw "Push Error" + error.code + " : " + error.message;
                                                                                        });
                                                                }
                                                                }
                                                                },
                                                                error: function(error) {
                                                                
                                                                console.error("Error: " + error.code + " " + error.message);
                                                                }
                                                                });
                                      },
                                      error: function(object, error) {
                                      
                                      }
                                      });
                
                
                
                
                
                
                });


Parse.Cloud.beforeSave('Activity', function(request, response) {
                       var currentUser = request.user;
                       var objectUser = request.object.get('fromUser');
                       
                       if(currentUser && currentUser.id != objectUser.id){
                       response.error('Cannot set fromUser on Activity to a user other than the current user.');
                       }else{
                       response.success();
                       }
                       });

Parse.Cloud.afterSave('Activity', function(request) {
                      
                      // check if activity is of type post
                      if(request.object.get('type') == "post"){
                      
                      /* when user is present, post has just created so notify followers. If not then post activity is being saved so just return */
                      if(request.user){
                      request.user.increment("postCount");
                      request.user.save();
                      
                      console.log("in notify followers");
                      // get picture object so we can find type of picture
                      var post = request.object.get("photo");
                      
                      // parse keys
                      var dev_app_id = Parse.applicationId;
                      var dev_master_key = Parse.masterKey;
                      
                      post.fetch({
                                 success: function(post) {
                                 
                                 // change wording "picture" to "moment"
                                 var postType = post.get("type") == "picture" ? "moment" : post.get("type");
                                 
                                 
                                 Parse.Cloud.httpRequest({
                                                         method: "POST",
                                                         url: "https://api.parse.com/1/jobs/notifyFollowersJob",
                                                         headers: {
                                                         "X-Parse-Application-Id": dev_app_id,
                                                         "X-Parse-Master-Key": dev_master_key,
                                                         "Content-Type": "application/json"
                                                         },
                                                         body: {
                                                         "activityId": request.object.id,
                                                         "postAuthorId": request.object.get("fromUser").id,
                                                         "postType": postType,
                                                         "displayName": request.user.get("displayName"),
                                                         "postId": request.object.get("photo").id,
                                                         
                                                         },
                                                         success: function(httpResponse) {
                                                         console.log("SUCCESS");
                                                         },
                                                         error: function(error) {
                                                         console.log("ERROR");
                                                         }
                                                         });
                                 
                                 
                                 }
                                 });
                      
                      }
                      
                      return;
                      }
                      
                      
                      var toUser = request.object.get("toUser");
                      var toUserId = toUser != undefined ? request.object.get("toUser").id : "";
                      
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
                      
                      
                      var photoId = request.object.get("photo") != undefined ? request.object.get("photo").id : "";
                      
                      var isSelfie = toUserId == fromUserId;
                      var atmentionUserArray = new Array();
                      
                      atmentionUserArray = request.object.get("atmention") != undefined ? request.object.get("atmention") : "";
                      
                      // Only send push notifications for new activities
                      if (request.object.existed()) {
                      return;
                      }
                      
                      if(!toUser) {
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
                      subscriptionQuery.include("subscriber");
                      
                      subscriptionQuery.find({
                                             success: function(results) {
                                             
                                             /* add all subscribers to new comment and save.
                                              This is so we can pull in activity feed from
                                              client side. */
                                             
                                             console.log(results);
                                             
                                             request.object.set("subscribers", results);
                                             request.object.save();
                                             
                                             // loop through all subscribers
                                             for (var i = 0; i < results.length; i++) {
                                             
                                             /* notify user except for comment author (fromUserId), post author is not subscribed to own post (client-side check) */
                                             
                                             if(fromUserId != results[i].get("subscriber").id){
                                             
                                             // notify subscriber
                                             var query = new Parse.Query(Parse.Installation);
                                             query.equalTo("user", results[i].get("subscriber"));
                                             
                                             var subscriberUser = results[i].get("subscriber");
                                             
                                             // update activity badge for subscriber
                                             var newActivityBadge = subscriberUser.get("activityBadge") + 1;
                                             subscriberUser.set("activityBadge", newActivityBadge);
                                             subscriberUser.save();
                                             
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
                      
                      Parse.Cloud.useMasterKey();
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
                      
                      if(request.object.get('photo') != undefined && request.object.get('type') != undefined){
                      Parse.Cloud.run("incrementCounter", {currentObjectId: request.object.get('photo').id, type: request.object.get('type')});
                      }
                      
                      });


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
                              
                              var photoOwner = counter.get('user');
                              var points;
                              var commentCount = 0;
                              var newDiscoverTotalPoints = 0;
                              
                              if (request.params.type === 'comment') {
                                points = 2;
                                commentCount = incrementCommentCounter(counter);
                              } else {
                                points = 1;
                              }
                              
                              if (counter.get('discoverCount') === undefined) {
                                  counter.set('discoverCount', points);
                              } else {
                                  newDiscoverTotalPoints = counter.get('discoverCount') + points;
                                  counter.set('discoverCount', newDiscoverTotalPoints);
                              }
                              
                              evaluateActivityForPoints(photoOwner, counter, commentCount, newDiscoverTotalPoints);
                              
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
        
        function evaluateActivityForPoints(owner, photoObj, photoCommentCount, discoverCount){
            
                    console.log("in evaluate");
                    
            var isExtraForComments = photoCommentCount > 5;
            var isExtraForDiscoverPoints = discoverCount > 30;
                    
            if(isExtraForComments){
                    console.log("in extra for comments");
                addExtraActivityPoints("comments", owner, photoObj, function(){
                   if(isExtraForDiscoverPoints){
                                       console.log("in discover");
                      addExtraActivityPoints("discoverCount", photoOwner, counter);
                   }
                });
            }else if(isExtraForDiscoverPoints){
                addExtraActivityPoints("discoverCount", photoOwner, counter);
            }
        }
                    
        function incrementCommentCounter(photoObj){
            var photoCommentCount = photoObj.get('commentCount') !== undefined ? photoObj.get('commentCount') + 1 : 1;
            photoObj.set('commentCount', photoCommentCount);
            photoObj.save();
                    
            return photoCommentCount;
        }
                    
        function checkExtraActivityPoints(type, photoObj){
            var extraPointsList = photoObj.get('extraActivityPoints');
            var hasExtraActivityPoints = false;
            
            if(extraPointsList !== undefined && extraPointsList.indexOf(type) !== -1){
                hasExtraActivityPoints = true;
            }
           return hasExtraActivityPoints;
        }
                    
                    
        function addExtraActivityPoints(type, owner, photoObj, callback){
                    
            var hasExtraActivityPoints = checkExtraActivityPoints(type, photoObj);
                    
            if(!hasExtraActivityPoints){
                
                var photoObjActivityExtra = photoObj.get('extraActivityPoints');
                
                if(photoObjActivityExtra === undefined){
                  photoObjActivityExtra = [];
                }
                    
                photoObjActivityExtra.push(type);
                
                console.log(photoObjActivityExtra[0]);
                    
                var extraPoints = 0;
                
                if(type === "comments"){
                    extraPoints = 1;
                }else if(type === "discoverCount"){
                    extraPoints = 5;
                }
                        
                        
                var ownerQuery = new Parse.Query('User');
                ownerQuery.get(owner.id,{
                                       success: function(photoOwner) {
                                            // The object was retrieved successfully.
                                            var newActivityPointsTotal = photoOwner.get('activityPoints') + extraPoints;
                               
                                            photoOwner.set('activityPoints', newActivityPointsTotal);
                                            photoOwner.save();
                               
                                            photoObj.set('extraActivityPoints', photoObjActivityExtra);
                                            photoObj.save();
                               
                                            callback();
                                       },
                                       error: function(object, error) {
                                       // The object was not retrieved successfully.
                                       }
                });
            }
        }
                    
});