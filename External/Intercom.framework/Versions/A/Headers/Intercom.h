
//
//  Intercom.h
//  Intercom for iOS SDK - Version 2.1.1
//
//  Created by Intercom on 8/01/2015.
//  Copyright (c) 2014 Intercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
#error This version (2.1.1) of the Intercom iOS SDK supports iOS 7.0 upwards.
#endif

__attribute__ ((deprecated))
@protocol IntercomSessionListener <NSObject>
- (void)intercomSessionStatusDidChange:(BOOL)isSessionOpen;
@end

// Use these values to constrain an incoming notification view to a defined section of the window.
typedef NS_ENUM(NSUInteger, ICMPreviewPosition){
    ICMPreviewPositionBottomLeft   = 0,
    ICMPreviewPositionBottomRight  = 1,
    ICMPreviewPositionTopLeft      = 2,
    ICMPreviewPositionTopRight     = 3
};

/**
 Intercom is your direct line of communication to every user, right inside your app. Intercom’s in-app messages
 are up to 10 times more effective than email too! Send the right messages, to the right users, at exactly the right time.
 
 ## How do I track my users?
 
 In order to see your users in Intercom's user list, you must first register them via your iOS application. If you have a
 place in your application where you become aware of the user's identity such as a log in view controller, call one of the
 following depending on the information you have available for that user:

 If you have both a unique user identifier and an email for your users::
 
    [Intercom registerUserWithUserId:@"123456" email:@"joe@example.com"];
 
 If you only have a unique identifier for your users:
 
    [Intercom registerUserWithUserId:@"123456"];
 
 Finally, if you only have an email address for your users:
    
    [Intercom registerUserWithEmail:@"joe@example.com"];
 
 ## Can I track unidentifed users?
 
 Yes, absolutely. If you have an application that doesn't require users to log in, you can call:
 
    [Intercom registerUnidentifiedUser];
 
 If the user subsequently logs in or you learn additional information about them (e.g. get an email address), 
 calling any of the other user registration methods will update that user's identity in Intercom and contain 
 all user data tracked previously.
 
 ## I'm using a previous SDK version and this looks different, what has changed?
 
 We have re-architected the internals of the iOS SDK to ensure it is as reliable as possible while tracking
 your users. We have focused on removing the asychronous behaviour of the SDK for example you no longer need 
 to wait for the completion blocks of the old `beginSession` calls before logging events or updating user data. 
 In doing so the SDK is more nimble and reliable than ever before.
 
 Previous versions of the SDK will migrate with minimal effort. All deprecated methods still work for now, 
 excluding the old session listener (since v2.0.6). These methods will be permanently removed in a future
 version.
 
 ## How do push notifications work?
 
 The Intercom iOS SDK enables your users to receive push notifications for new messages. Simply call:
 
    - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
        [Intercom setDeviceToken:deviceToken];
    }
 
 in your `didRegisterForRemoteNotificationsWithDeviceToken:` method once you have registered your app for 
 push notifications with the `UIApplicationDelegate`.
 
 When your app receives a push notification the SDK checks to see if it is an Intercom push notification
 and opens the SDK if required. You do not need to implement any additional code in order to launch the SDK.
 
 To do this we [safely swizzle](http://blog.newrelic.com/2014/04/16/right-way-to-swizzle/) the public methods
 in `UIApplicationDelegate` that handle receiving push notifications. We do not user any private APIs to do this.
 
 ## More information
 
 Full documentation is available [here](http://docs.intercom.io/Install-on-your-mobile-product) and please contact 
 us directly via Intercom for any support or questions you may have.
 
 */
@interface Intercom : NSObject

//=========================================================================================================
/*! @name Getting set up */
//=========================================================================================================
/*!
 Initialize Intercom with your iOS API key and App ID.  This will allow your app to connect with Intercom.
 This is best done in the application delegate's didFinishLaunchingWithOptions: method.
 
 @param apiKey The iOS-SDK API key found on the API Key settings page.
 @param appId  The App ID of your Intercom app.
 */
+ (void)setApiKey:(NSString *)apiKey forAppId:(NSString *)appId;

//=========================================================================================================
/*! @name Using secure mode */
//=========================================================================================================
/*!
 Secure Mode helps to make sure that conversations between you and your users are kept private, and that one
 user can't impersonate another. In Secure Mode the iOS SDK will sign all requests going to the Intercom servers
 with tokens. It requires your mobile application to have its own server which authenticates the app's users,
 and which can store a secret. More information on secure mode can be found [here](http://docs.intercom.io/Install-on-your-mobile-product/secure-mode-ios-sdk).
 
 @note This should be called before any user registration takes place.
 @param hmac A HMAC digest of data.
 @param data A piece of user data.
 */
+ (void)setHMAC:(NSString *)hmac data:(NSString *)data;

//=========================================================================================================
/*! @name Working with anonymous users */
//=========================================================================================================
/*!
 If you call registerUnidentifiedUser, all activity will be tracked anonymously. If you choose to subsequently
 identify that user, all that anonymous activity will be merged into the identified user. This means that you
 will no longer see the anonymous user in Intercom, but rather the identified one.

@note We recommend this is called from within the application delegate's didFinishLaunchingWithOptions: method.
 
 @note You must call one of the user registration methods in order to start communicating with Intercom.
 */
+ (void)registerUnidentifiedUser;

//=========================================================================================================
/*! @name Working with identified users */
//=========================================================================================================
/*!
 In order to keep track of a specific user, you must identify it with a unique user identifier, an email
 address, or both. By supplying information like this Intercom provides richer user profiles for your users.
 This is a userId, supplied by you (e.g. from an existing web service for your product) to represent your
 user in Intercom, once set it cannot be changed.
 
 @param userId  A unique identifer for your user.
 @param email   Your user's email address.
 @note You must call one of the user registration methods in order to start communicating with Intercom.
 */
+ (void)registerUserWithUserId:(NSString *)userId email:(NSString *)email;

/*!
 Register a user just with their userId.
 
 @param userId A unique identifer for your user.
 @note You must call one of the user registration methods in order to start communicating with Intercom.
 */
+ (void)registerUserWithUserId:(NSString *)userId;

/*!
 Register a user with just their email address.
 
 @param email   Your user's email address.
 @note You must call one of the user registration methods in order to start communicating with Intercom.
 */
+ (void)registerUserWithEmail:(NSString *)email;

//=========================================================================================================
/*! @name Resetting user data */
//=========================================================================================================
/*!
 reset is used to reset all local caches and user data the Intercom SDK has created. Use this at a time when
 you wish to log a user out of your app or change a user. Once called, the SDK will no longer communicate with Intercom
 until a further registration is made.
 */
+ (void)reset;

//=========================================================================================================
/** @name Updating the user */
//=========================================================================================================
/*!
 You can send any data you like to Intercom. Typically our customers see a lot of value in sending data that 
 relates to customer development, such as price plan, value of purchases, etc. Once these have been sent to
 Intercom you can then apply filters based on these attributes.
 
 A detailed list of the fields you can use to [update a user is available here](https://doc.intercom.io/api/#user-model)
 
 Attributes such as the user email or name can be updated by calling
 
     [Intercom updateUserWithAttributes:@{
         @"email" : @"admin@intercom.io",
         @"name" : @"Admin Name"
     }];
 
 Custom user attributes can be created and modified by passing a custom_attributes dictionary
 You do not have to create attributes in Intercom beforehand. If one hasn't been seen before, it will be
 created for you automatically.
 
     [Intercom updateUserWithAttributes:@{
         @"custom_attributes": @{
             @"paid_subscriber" : @YES,
             @"monthly_spend": @155.5,
             @"team_mates": @3
         }
     }];
 
 You can also set company data via this call by submitting an attribute dictionary like
 
     [Intercom updateUserWithAttributes:@{
         @"companies": @[ @{
             @"name" : @"My Company",
             @"id" : @"abcd1234"
         }
     ]}];
 
 id is a required field for adding or modifying a company. A detailed description of the
 [company model is available here](https://doc.intercom.io/api/#companies-and--users)
 
 @param attributes This is a dictionary containing key/value pairs for multiple attributes.
 @note Attributes may be either a `string`, `integer`, `double`, `unix timestamp` or `bool`.
 */
+ (void)updateUserWithAttributes:(NSDictionary *)attributes;

/*!
 Log an event with a given name.
 
 You can log events in Intercom based on user actions in your app. Events are different 
 to custom user attributes in that events are information on what Users did and when they 
 did it, whereas custom user attributes represent the User's current state as seen in their 
 profile. See details about Events [here](http://doc.intercom.io/api/#events).
 
 @param name The name of the event that it is going to be logged.
 */
+ (void)logEventWithName:(NSString *)name;

/*!
 Metadata Objects support a few simple types that Intercom can present on your behalf, see the
 [Intercom API docs](http://doc.intercom.io/api/#event-metadata-types)
 
 @param name The name of the event you wish to track.
 @param metadata contains simple types to present to Intercom
 
    [Intercom logEventWithName:@"ordered_item" metaData:@{
        @"order_date": @1392036272,
        @"stripe_invoice": @"inv_3434343434",
        @"order_number": @{
        @"value": @"3434-3434",
        @"url": @"https://example.org/orders/3434-3434"
    }];
 
 @param completion The completion block to be executed after the event is logged.
 */
+ (void)logEventWithName:(NSString *)name metaData:(NSDictionary *)metaData;

//=========================================================================================================
/*! @name Show Intercom messages and message composers */
//=========================================================================================================

/*!
 Present the message composer.
 */
+ (void)presentMessageComposer;

/*!
 Present the conversation list.
 */
+ (void)presentConversationList;

//=========================================================================================================
/*! @name Working with push notifications */
//=========================================================================================================
/*!
 Set the device token for push notifications. Once the device token is set, the SDK safely swizzles the methods
 for receiving push notifications so it can intercept ones sent from Intercom. When a push notification from
 Intercom is received, the SDK will automatically react and launch according to your preferences.
 
 @param deviceToken The device token provided in the `didRegisterForRemoteNotificationsWithDeviceToken` method.
 */
+ (void)setDeviceToken:(NSData *)deviceToken;

//=========================================================================================================
/*! @name Incoming message presentation options */
//=========================================================================================================

/*!
 Use this to constrain an incoming notification view to a defined section of the window. By default, if this is
 not set, message previews appear in the bottom left of your application's window.
 
 @param previewPosition The ICMPreviewPosition for your incoming notifications.
 */
+ (void)setPreviewPosition:(ICMPreviewPosition)previewPosition;

/*!
 Depending on the layout of your app you may need to modify the position of the message preview relative to the 
 preview's position. Use this method to add sufficent padding using x and y values.
 
 @param x A horizontal padding value.
 @param y A vertical padding value.
 */
+ (void)setPreviewPaddingWithX:(CGFloat)x y:(CGFloat)y;

//=========================================================================================================
/*! @name Toggling message visibility */
//=========================================================================================================

/*!
 Use this to hide all incoming Intercom messages and message previews in the parts of your app where you do
 not wish to interrupt users, for example Camera views, parts of a game or other scenarios.
 
 @param hidden A bool that toggles message visibility. Use this to either prevent or allow messages from being
 displayed in select parts of your app.
 */
+ (void)setMessagesHidden:(BOOL)hidden;

//=========================================================================================================
/*! @name Enable logging */
//=========================================================================================================

/*!
 Enable logging for the Intercom SDK. By calling this method, Intercom will display debug information.
 @note it is recommended to use it only while debugging)
 */
+ (void)enableLogging;

//=========================================================================================================
/*! @name Intercom Notifications */
//=========================================================================================================
/*!
 Notifications thrown by the SDK when the SDK window is displayed and hidden. These notifications are fired
 only when there is a change in the state of the SDK's UI: when a user receives a message for instance,
 willShow and didShow notifications will be fired accordingly when the Intercom Notification (chat head)
 is presented.
 
 Once the user taps on the chat head, the message is presented in your app. It will be presented covering
 the entire screen, but no notifications will be thrown here as the SDK has already been visible.
 */

UIKIT_EXTERN NSString *const IntercomWindowWillShowNotification;
UIKIT_EXTERN NSString *const IntercomWindowDidShowNotification;
UIKIT_EXTERN NSString *const IntercomWindowWillHideNotification;
UIKIT_EXTERN NSString *const IntercomWindowDidHideNotification;

/*!
 ## Version 2.1 Deprecations
 */


typedef NS_ENUM(NSUInteger, ICMPresentationMode){
    ICMPresentationModeBottomLeft   = 0,
    ICMPresentationModeBottomRight  = 1,
    ICMPresentationModeTopLeft      = 2,
    ICMPresentationModeTopRight     = 3
};

typedef void(^ICMCompletion)(NSError *error) __attribute((deprecated));

+ (void)setApiKey:(NSString *)apiKey forAppId:(NSString *)appId securityOptions:(NSDictionary*) securityOptions __attribute((deprecated("Use method 'setSecureOptions:' instead")));

+ (void)beginSessionForUserWithEmail:(NSString *)email completion:(ICMCompletion)completion __attribute((deprecated("Use method 'registerUserWithEmail:' instead")));

+ (void)beginSessionForUserWithUserId:(NSString *)userId completion:(ICMCompletion)completion __attribute((deprecated("Use method 'registerUserWithUserId:' instead")));

+ (void)beginSessionForAnonymousUserWithCompletion:(ICMCompletion)completion __attribute((deprecated("Use method 'registerUnidentifiedUser' instead")));

+ (void)endSession __attribute((deprecated("Use method 'reset' to reset your local install instead")));

+ (void)updateUserWithAttributes:(NSDictionary *)attributes completion:(ICMCompletion)completion __attribute((deprecated("Use method 'updateUserWithAttributes:' instead")));

+ (void)logEventWithName:(NSString *)name completion:(ICMCompletion)completion __attribute((deprecated("Use method 'logEventWithName:' instead")));

+ (void)logEventWithName:(NSString *)name optionalMetaData:(NSDictionary *)metadata completion:(ICMCompletion)completion __attribute((deprecated("Use method 'logEventWithName:metaData:' instead")));

+ (void)checkForUnreadMessages __attribute((deprecated("This is no longer supported.")));

+ (void)setPresentationInsetOverScreen:(UIEdgeInsets)presentationInset __attribute((deprecated("Use method 'setPreviewPaddingX:y:' instead")));

+ (void)setPresentationMode:(ICMPresentationMode)presentationMode __attribute((deprecated("Use method 'setPreviewPosition:' instead")));

+ (void)setBaseColor:(UIColor *)color __attribute((deprecated("This is no longer supported.")));

+ (void)hideIntercomMessages:(BOOL)hidden  __attribute((deprecated("Use method 'setMessagesHidden:' instead")));

+ (void)presentMessageViewAsConversationList:(BOOL)showConversationList __attribute((deprecated("Use method 'presentConversationList & presentMessageComposer' instead")));

+ (void)setSessionListener:(id<IntercomSessionListener>)sessionListener __attribute((deprecated("This is no longer supported.")));

+ (void)registerForRemoteNotifications __attribute((deprecated("Use method 'setDeviceToken' instead.")));
@end
