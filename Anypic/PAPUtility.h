//
//  PAPUtility.h
//  Teamstory
//
//

@interface PAPUtility : NSObject

+ (void)captureEventGA:(NSString *)eventCategory action:(NSString *)eventAction label:(NSString *)eventLabel;
+ (void)captureScreenGA:(NSString *)screen;
+ (void)updateSubscriptionToPost:(NSString *)postId forState:(NSString *)state;
+ (void)likePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)likeCommentInBackground:(id)comment block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikeCommentInBackground:(id)comment block:(void (^)(BOOL succeeded, NSError *error))completionBlock;


+ (void)processFacebookProfilePictureData:(NSData *)data;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (BOOL)userHasValidTwitterData:(PFUser *)user;
//+ (BOOL)userHasProfilePictures:(PFUser *)user;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)unfollowUsersEventually:(NSArray *)users;

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
//+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
//+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
//+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController;

+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy;
+ (PFQuery *)queryForActivitiesOnComment:(PFObject *)comment cachePolicy:(PFCachePolicy)cachePolicy;
@end
