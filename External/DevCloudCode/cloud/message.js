Parse.Cloud.beforeSave('Message', function(request, response) {
                       var currentUser = request.user;
                       var objectUser = request.object.get('fromUser');
                        
                       if(!currentUser || !objectUser) {
                       response.error('A Message should have a valid fromUser.');
                       } else if (currentUser.id === objectUser.id) {
                       response.success();
                       } else {
                       response.error('Cannot set fromUser on Message to a user other than the current user.');
                       }
                        
                        
                        
                       });
 
Parse.Cloud.afterSave('Message', function(request) {
                      var toUser = request.object.get("toUser");
 
                      var recipientQuery = new Parse.Query(Parse.Installation);
                      recipientQuery.equalTo('user', toUser.id);
 
                      Parse.Push.send({
                                      where: recipientQuery, // Set our Installation query.
                                      data: alertPayload(request)
                                      }).then(function() {
                                              // Push was successful
                                              console.log('Sent messages to a User.');
                                              }, function(error) {
                                              throw "Push message Error " + error.code + " : " + error.message;
                                              });
                       
                      });
 
 
 
var alertMessage = function(request) {
    var message = "";
    var userName = request.user.get("displayName");
 
    if (request.user.get('displayName')) {
            message = request.user.get("displayName") + ": " + request.object.get("messageBody");
        } else {
            message = "Someone sent a message";
        }
 
    // Trim our message to 140 characters.
    if (message.length > 140) {
        message = message.substring(0, 140);
    }
     
    return message;
}
 
var alertPayload = function(request) {
    var payload = {};
 
        return {
        alert: alertMessage(request), // Set our alert message.
        badge: 'Increment',
            // The following keys help load the correct photo in response to this push notification.
        p: 'm', // Payload Type: Message
        fu: request.object.get('fromUser').id, // From User
        tu: request.object.get('toUser').id,
        aid: request.object.id, // Activity Id
        rid: request.object.get('chatRoom').id // chatroom id.
        };
     
     
}