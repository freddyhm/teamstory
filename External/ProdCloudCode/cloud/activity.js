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
                      
                      atmentionUserArray = request.object.get("atmention") != undefined ? request.object.get("atmention") : "";
                      
                      // Only send push notifications for new activities
                      if (request.object.existed()) {
                      return;
                      }
                      
                      if (!toUser) {
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
                                              console.log('Sent atmetion push');
                                              }, function(error) {
                                              throw "Push Error" + error.code + " : " + error.message;
                                              });
                      }
                      }
                      
                      
                      // notify all users except fromUser who are subscribed to post when new comment is sent
                      if(request.object.get("type") === "comment" && atmentionUserArray.length == 0){
                      
                      var toSubscribersQuery = new Parse.Query(Parse.Installation);
                      var channelName = "ch" + photoId;
                      
                      toSubscribersQuery.equalTo("channels", channelName);
                      toSubscribersQuery.notEqualTo("user", fromUser);
                      
                      Parse.Push.send({
                                      where: toSubscribersQuery,
                                      data: alertPayload(request)
                                      }).then(function() {
                                              // Push was successful
                                              console.log('Sent subscribers push.');
                                              }, function(error) {
                                              throw "Push Error " + error.code + " : " + error.message;
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
                      
                      // Only send push notifications for new activities
                      if (request.object.existed()) {
                      return;
                      }
                      
                      if (!toUser) {
                      throw "Undefined toUser. Skipping push for Activity " + request.object.get('type') + " : " + request.object.id;
                      return;
                      }
                      
                      });



var alertMessage = function(request) {
    var message = "";
    
    var atmentionUserArray = new Array();
    
    atmentionUserArray = request.object.get("atmention") != undefined ? request.object.get("atmention") : "";
    
    if (request.object.get("type") === "comment" && atmentionUserArray.length == 0) {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ': ' + request.object.get('content').trim();
        } else {
            message = "Someone commented on your photo.";
        }
    } else if (request.object.get("type") === "comment" && atmentionUserArray.length > 0) {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ': ' + 'mentioned you in a post';
        } else {
            message = "Someone mentioned you in a post.";
        }
    } else if (request.object.get("type") === "like") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' likes your photo.';
        } else {
            message = 'Someone likes your photo.';
        }
    } else if (request.object.get("type") === "like comment") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' likes your comment.';
        } else {
            message = 'Someone likes your comment.';
        }
    } else if (request.object.get("type") === "follow") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' is now following you.';
        }
    } else {
        message = "You have a new follower.";
    }
    
    // Trim our message to 140 characters.
    if (message.length > 140) {
        message = message.substring(0, 140);
    }
    
    return message;
}

var alertPayload = function(request) {
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
    }
    
    
}