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
                      
    var toUser = request.object.get("toUser");

    var toUserId = request.object.get("toUser").id;
    var fromUserId = request.object.get("fromUser").id;
    var photoId = request.object.get('photo').id;
    
    // Only send push notifications for new activities & no self pushes
    if (request.object.existed() || toUserId == fromUserId) {
    return;
    }
    
    
    if (!toUser) {
    throw "Undefined toUser. Skipping push for Activity " + request.object.get('type') + " : " + request.object.id;
    return;
    }
    
    var query = new Parse.Query(Parse.Installation);
    
    /*
    query.equalTo('user', toUser);
    
    Parse.Push.send({
                    where: query, // Set our Installation query.
                    data: alertPayload(request)
                    }).then(function() {
                            // Push was successful
                            console.log('Sent push.');
                            }, function(error) {
                            throw "Push Error " + error.code + " : " + error.message;
                            });
    */

    // send notification to proper post channel
    var channelName = "ch" + photoId;

    query.equalTo('channels', channelName); // Set our channel

    Parse.Push.send({
      where: query,
      data: alertPayload(request)
      }).then(function() {
        // Push was successful
        console.log('Sent push.');
        }, function(error) {
        throw "Push Error " + error.code + " : " + error.message;
        });  
});

                    

var alertMessage = function(request) {
    var message = "";
    
    if (request.object.get("type") === "comment") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ': ' + request.object.get('content').trim();
        } else {
            message = "Someone commented on your photo.";
        }
    } else if (request.object.get("type") === "like") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' likes your photo.';
        } else {
            message = 'Someone likes your photo.';
        }
    } else if (request.object.get("type") === "follow") {
        if (request.user.get('displayName')) {
            message = request.user.get('displayName') + ' is now following you.';
        } else {
            message = "You have a new follower.";
        }
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
        pid: request.object.get('photo').id // Photo Id
        };
    } else if (request.object.get("type") === "like") {
        return {
        alert: alertMessage(request), // Set our alert message.
        badge: 'Increment',
            // The following keys help load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'l', // Activity Type: Like
        fu: request.object.get('fromUser').id, // From User
        pid: request.object.get('photo').id // Photo Id
        };
    } else if (request.object.get("type") === "follow") {
        return {
        alert: alertMessage(request), // Set our alert message.
        badge: 'Increment',
            // The following keys help load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'f', // Activity Type: Follow
        fu: request.object.get('fromUser').id // From User
        };
    }
    
    
}