//
//  PAPUtility.h
//  Teamstory
//
//

@interface PAPUtility : NSObject


+ (void)captureScreenGA:(NSString *)screen;
+ (void)posted:(id)post;
+ (UIImage *)resizeImage:(UIImage *)image width:(int)w height:(int)h;
+ (void)updateSubscriptionToPost:(PFObject *)post forState:(NSString *)state;


+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikeCommentInBackground:(id)comment block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)likePhotoInBackground:(id)photo setNavigationController:(UINavigationController *)navController block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)likeCommentInBackground:(id)comment setNavigationController:(UINavigationController *)navController photo:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock;


+ (void)processFacebookProfilePictureData:(NSData *)data;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (BOOL)userHasValidTwitterData:(PFUser *)user;
//+ (BOOL)userHasProfilePictures:(PFUser *)user;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserEventually:(PFUser *)user setNavigationController:(UINavigationController *)navController block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)unfollowUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded))completionBlock;
//+ (void)unfollowUsersEventually:(NSArray *)users;
//+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
//+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
//+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
//+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController;

+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy;
+ (PFQuery *)queryForActivitiesOnComment:(PFObject *)comment cachePolicy:(PFCachePolicy)cachePolicy;

@end
