//
//  PAPConstants.h
//  Teamstory
//
//

typedef enum {
	PAPHomeTabBarItemIndex = 0,
    PAPPerksTabBarItemIndex = 1,
	PAPMessageTabBarItemIndex = 2,
	PAPActivityTabBarItemIndex = 3,
    PAPProfileTabBarItemIndex = 4
} PAPTabBarControllerViewControllerIndex;

/*
typedef enum {
	PAPHomeTabBarItemIndex = 0,
	PAPEmptyTabBarItemIndex = 1,
	PAPActivityTabBarItemIndex = 2,
} PAPTabBarControllerViewControllerIndex;
*/

// Define an array of Facebook Ids for accounts to auto-follow on signup
#define kPAPAutoFollowAccountFacebookIds @[ ]

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#pragma mark - NSUserDefaults
extern NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kPAPUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs

extern NSString *const kPAPLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const PAPUtilityUserFollowingChangedNotification;
extern NSString *const PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification;
extern NSString *const PAPProfileSettingViewControllerUserChangedProfile;

#pragma mark - User Info Keys
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey;

#pragma mark - Custom Album Name
extern NSString *const CustomAlbumName;

#pragma mark - Installation Class

// Field keys
extern NSString *const kPAPInstallationUserKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kPAPActivityClassKey;

// Field keys
extern NSString *const kPAPActivityTypeKey;
extern NSString *const kPAPActivityFromUserKey;
extern NSString *const kPAPActivityToUserKey;
extern NSString *const kPAPActivityForCommentKey;
extern NSString *const kPAPActivityContentKey;
extern NSString *const kPAPActivityPhotoKey;

// Type values
extern NSString *const kPAPActivityTypeLike;
extern NSString *const kPAPActivityTypePosted;
extern NSString *const kPAPActivityTypeLikeComment;
extern NSString *const kPAPActivityTypeFollow;
extern NSString *const kPAPActivityTypeComment;
extern NSString *const kPAPActivityTypeJoined;


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kPAPUserDisplayNameKey;
extern NSString *const kPAPUserFacebookIDKey;
extern NSString *const kPAPUserTwitterIDKey;
extern NSString *const kPAPUserPhotoIDKey;
extern NSString *const kPAPUserProfilePicSmallKey;
extern NSString *const kPAPUserProfilePicMediumKey;
extern NSString *const kPAPUserFacebookFriendsKey;
extern NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey;


#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kPAPPhotoClassKey;

// Field keys
extern NSString *const kPAPPhotoPictureKey;
extern NSString *const kPAPPhotoThumbnailKey;
extern NSString *const kPAPPhotoUserKey;
extern NSString *const kPAPPhotoOpenGraphIDKey;
extern NSString *const kPAPPhotoType;

#pragma mark - Cached Comment Attributes
extern NSString *const kPAPCommentAttributesIsLikedByCurrentUserKey;
extern NSString *const kPAPCommentAttributesLikeCountKey;

#pragma mark - Cached Photo Attributes
// keys
extern NSString *const kPAPPhotoAttributesIsLikedByCurrentUserKey;
extern NSString *const kPAPPhotoAttributesLikeCountKey;
extern NSString *const kPAPPhotoAttributesLikersKey;
extern NSString *const kPAPPhotoAttributesCommentCountKey;
extern NSString *const kPAPPhotoAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kPAPUserAttributesPhotoCountKey;
extern NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kPAPPushPayloadPayloadTypeKey;
extern NSString *const kPAPPushPayloadPayloadTypeActivityKey;

extern NSString *const kPAPPushPayloadActivityPostKey;
extern NSString *const kPAPPushPayloadActivityTypeKey;
extern NSString *const kPAPPushPayloadActivityLikeKey;
extern NSString *const kPAPPushPayloadActivityLikeCommentKey;
extern NSString *const kPAPPushPayloadActivityCommentKey;
extern NSString *const kPAPPushPayloadActivityFollowKey;

extern NSString *const kPAPPushPayloadFromUserObjectIdKey;
extern NSString *const kPAPPushPayloadToUserObjectIdKey;
extern NSString *const kPAPPushPayloadPhotoObjectIdKey;
extern NSString *const kPAPPushPayloadChatRoomObjectIdKey;