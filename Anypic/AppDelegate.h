//
//  AppDelegate.h
//  Teamstory
//
//

#import "PAPTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, UITabBarControllerDelegate, PFLogInViewControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) PAPTabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, readonly) int networkStatus;

- (BOOL)isParseReachable;

- (void)presentTabBarController;
- (void)presentLoginSelectionController;
- (void)presentTutorialViewController;

- (void)setUserCurrentScreen:(NSString *)currentScreen setTargetRoom:(PFObject *)targetRoom;

- (void)logOut;
- (void)settingRootViewAsTabBarController;

- (void)facebookRequestDidLoad:(id)result;
- (void)facebookRequestDidFailWithError:(NSError *)error;



@end
