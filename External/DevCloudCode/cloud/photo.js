// Validate Photos have a valid owner in the "user" pointer.
Parse.Cloud.beforeSave('Photo', function(request, response) {
    response.success();
});

Parse.Cloud.afterSave('Photo', function(request) {
    notifyFollowers(request)
});


// find the author's followers and send them a push
var notifyFollowers = function(request){
    
    var notifyFollowersQuery = new Parse.Query("Activity");
    var postAuthor = request.object.get("user");
    
    var Post = Parse.Object.extend("Photo");
    var postPointer = new Post();
    postPointer.id = request.object.id;
    
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
                  
                  followerObj.set("follower", follower);
                  followerObj.set("following", postAuthor);
                  followerObj.set("post", postPointer);
                  followerObj.save(null, {
                                 success: function(newNotice) {
                                 },
                                 error: function(newNotice, error) {
                                 // Execute any logic that should take place if the save fails.
                                 // error is a Parse.Error with an error code and message.
                                 alert('Failed to create new object, with error code: ' + error.message);
                                 }
                    });
                            
                   /*
                  Parse.Push.send({
                                  where: installationQuery,
                                  data: alertPayload(request)
                                  }).then(function() {
                                          console.log('Sent follower push');
                                          }, function(error) {
                                          throw "Push Error" + error.code + " : " + error.message;
                                          });
                    
                    */
                  }
                       
                       
        },
        error: function(error) {
            console.error("Error: " + error.code + " " + error.message);
        }
    });
}


var alertMessage = function(request) {
    var message = request.user.get('displayName') + ' posted a ' + request.object.get("type");
    return message;
}

var alertPayload = function(request) {
    var type = request.object.get("type");
    return {
    alert: alertMessage(request), // Set our alert message.
    badge: 'Increment', // Increment the target device's badge count.
        // The following keys help load the correct data in response to this push notification.
    p: 'p', // Payload Type: Photo
    t: type, // Photo Type
    fu: request.object.get('user').id, // From User
    pid: request.object.id // Photo Id
    };
}



