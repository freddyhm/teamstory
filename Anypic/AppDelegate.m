//
//  AppDelegate.m
//  TeamStory
//


#import "AppDelegate.h"

#import "GAI.h"
#import <Appsee/Appsee.h>
#import "Konotor.h"
#import "KonotorEventHandler.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "PAPHomeViewController.h"
#import "PAPLogInViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPAccountViewController.h"
#import "PAPWelcomeViewController.h"
#import "PAPActivityFeedViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "PAPProfileSettingViewController.h"
#import "discoverPageViewController.h"
#import "PAPwebviewViewController.h"
#import "PAPLoginSelectionViewController.h"
#import "PAPLoginTutorialViewController.h"
#import "PAPprofileApprovalViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "iRate.h"



@interface AppDelegate () {
    NSMutableData *_data;
    BOOL firstLaunch;
}


@property (nonatomic, strong) PAPHomeViewController *homeViewController;
@property (nonatomic, strong) PAPActivityFeedViewController *activityViewController;
@property (nonatomic, strong) PAPWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) PAPProfileSettingViewController *profileSettingViewController;
@property (nonatomic, strong) PAPAccountViewController *accountViewController_tabBar;
@property (nonatomic, strong) PAPLogInViewController *loginviewcontroller;
@property (nonatomic, strong) discoverPageViewController *discoverViewController;


@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSTimer *autoFollowTimer;
@property BOOL isKonotor;
@property NSNumber *konotorCount;

@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;
@end

@implementation AppDelegate

@synthesize window;
@synthesize navController;
@synthesize tabBarController;
@synthesize networkStatus;

@synthesize homeViewController;
@synthesize activityViewController;
@synthesize welcomeViewController;
@synthesize profileSettingViewController;
@synthesize accountViewController_tabBar;
@synthesize loginviewcontroller;
@synthesize discoverViewController;

@synthesize autoFollowTimer;

@synthesize hostReach;
@synthesize internetReach;
@synthesize wifiReach;

// Environment keys

#if DEBUG
static NSString *const GOOGLE_TRACKING_ID = @"UA-49381420-2";
static NSString *const KONOTOR_APP_ID = @"7043fe2f-cb83-403e-b9af-3c6de2fd4752";
static NSString *const KONOTOR_APP_KEY = @"e57e4508-47b6-4ecf-b0ee-8c657a855b3d";
static NSString *const PARSE_APP_ID = @"0tEtPoPtsvPu1lCPzBeU032Cz3Byemcp5lr25gIU";
static NSString *const PARSE_CLIENT_KEY = @"ZRnM7JXOlbSyOQuosXWG6SlrDNCY22C84hpqyi0l";
static NSString *const TWITTER_KEY = @"VGiCnk6P01PjqV13rm34Bw";
static NSString *const TWITTER_SECRET = @"agzbVGDyyuFvpZ4kJecoXoJYC4cTOZEVGjJIO0z9Q";
#else
static NSString *const GOOGLE_TRACKING_ID = @"UA-49381420-1";
static NSString *const APPSEE = @"ee2b6679635f492dbc1d36a14fe196ae";
static NSString *const KONOTOR_APP_ID = @"ab785be6-9398-4b6a-8ae6-4d83431edad9";
static NSString *const KONOTOR_APP_KEY = @"3784ef60-6e0f-48fc-9a6c-3ac71c127dcb";
static NSString *const PARSE_APP_ID = @"SPQlkxDYPDcVhbICHFzjwSsREHaSqKQIKwkijDaJ";
static NSString *const PARSE_CLIENT_KEY = @"WtgkZLYZ1UOlsbGMnfYtKCD6dQLMfy3tBsN2UKxA";
static NSString *const TWITTER_KEY = @"VGiCnk6P01PjqV13rm34Bw";
static NSString *const TWITTER_SECRET = @"agzbVGDyyuFvpZ4kJecoXoJYC4cTOZEVGjJIO0z9Q";
#endif

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 1;
    
    // Optional: set Logger to VERBOSE for debug information.
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_TRACKING_ID];
    
    // Appsee setup only for release
    #if RELEASE
        [Appsee start:APPSEE];
    #endif
    
    // Konotor setup
    [Konotor InitWithAppID:KONOTOR_APP_ID AppKey:KONOTOR_APP_KEY withDelegate:[KonotorEventHandler sharedInstance]];
    
    //[Konotor setUnreadWelcomeMessage:@"Welcome to Teamstory! How can we make your experience more kickass?"];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    // ****************************************************************************
    // Parse initialization
        [Parse setApplicationId:PARSE_APP_ID
                      clientKey:PARSE_CLIENT_KEY];
        [PFFacebookUtils initializeFacebook];
        [PFTwitterUtils initializeWithConsumerKey:TWITTER_KEY
                                   consumerSecret:TWITTER_SECRET];
    // ****************************************************************************
    
    // Track app open
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Crash analytics
    [Crashlytics startWithAPIKey:@"9075de9af4f252529090970cd8c2f7e426771d92"];

    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    // Set up our app's global UIAppearance
    [self setupAppearance];

    // Use Reachability to monitor connectivity
    [self monitorReachability];

    self.welcomeViewController = [[PAPWelcomeViewController alloc] init];

    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;

    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
    

    
    // handle push notifications
    [self handlePush:launchOptions userInfo:nil source:@"launch"];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    // konotor notifications setup
    [Konotor addDeviceToken:newDeviceToken];
    [PFPush storeDeviceToken:newDeviceToken];
    
    [[PFInstallation currentInstallation] setDeviceTokenFromData:newDeviceToken];
    [[PFInstallation currentInstallation] saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
    if ([error code] != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    NSString *pushSrc = [userInfo objectForKey:@"source"];
    
    // handle type of notification
    if ([pushSrc isEqualToString:@"konotor"]){
        
        self.isKonotor = YES;
        
        // app is in foreground
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [Konotor handleRemoteNotification:userInfo withShowScreen:NO];

        }else{

            [Konotor handleRemoteNotification:userInfo withShowScreen:YES];
            [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        }
        
    }else{
    
        // app is in foreground
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            if ([PFUser currentUser]) {
                
                // set activity and icon badge value
                if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
                    
                    UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
                    
                    NSString *currentBadgeValue = tabBarItem.badgeValue;
                    
                    if (currentBadgeValue && currentBadgeValue.length > 0 && application.applicationIconBadgeNumber != 0) {
                        
                        // activity bar
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                        NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                        tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
                        
                        // icon value
                        application.applicationIconBadgeNumber = [newBadgeValue intValue];
                    } else {
                        tabBarItem.badgeValue = @"1";
                        application.applicationIconBadgeNumber = 1;
                    }
                }
            }
        }else{
            [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
            [self handlePush:nil userInfo:userInfo source:@"background"];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // initiate konotor
    [Konotor newSession];
    
    self.konotorCount = [NSNumber numberWithInt:[Konotor getUnreadMessagesCount]];
    
    // syncs icon badge with tab bar badge, resets icon badge back to 0
    if (application.applicationIconBadgeNumber != 0) {
        
        if(application.applicationIconBadgeNumber == 1 && [self.konotorCount intValue] > 0){
            
            application.applicationIconBadgeNumber = 1;
            application.applicationIconBadgeNumber = 0;
            
            [KonotorFeedbackScreen showFeedbackScreen];
             self.konotorCount = 0;
        }else{
            
            // check if tab controllers and activity tab exist
            if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
                
                UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *newBadgeValue = [NSNumber numberWithInteger:application.applicationIconBadgeNumber];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
                
                // get current selected tab
                NSUInteger selectedtabIndex = self.tabBarController.selectedIndex;
                
                // notify activity controller of new notification (didreceivenot. is not called from background)
                [self.activityViewController notificationSetup:(int)application.applicationIconBadgeNumber source:@"background"];
                
                // current view is activity, clear the badge
                if(selectedtabIndex == PAPActivityTabBarItemIndex){
                    [self.activityViewController setActivityBadge:nil];
                }
            }
        }
    }
    
    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    [[FBSession activeSession] handleDidBecomeActive];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:aTabBarController.viewControllers[PAPEmptyTabBarItemIndex]];
}


#pragma mark - PFLoginViewController

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![self shouldProceedToMainInterface:user]) {
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.navController.view animated:YES];
        self.hud.labelText = NSLocalizedString(@"Loading", nil);
        self.hud.dimBackground = YES;
    }
    
    NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
    bool profileExist = [profilExist_num boolValue];
    
    NSNumber *accessGrant_num = [[PFUser currentUser] objectForKey: @"accessGrant"];
    bool access_grant = [accessGrant_num boolValue];
    
    
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]){
        [[PFUser currentUser] setObject:[PFTwitterUtils twitter].userId forKey:@"twitterID"];
        
        if (profileExist != true || access_grant != true) {
            if (profileExist != true) {
                PAPProfileSettingViewController *profileSettingView = [[PAPProfileSettingViewController alloc] init];
                self.navController.navigationBarHidden = YES;
                [self.navController pushViewController:profileSettingView animated:NO];
                return;
            }
            
            PAPprofileApprovalViewController *profileApprovalViewController = [[PAPprofileApprovalViewController alloc] init];
            [self.navController pushViewController:profileApprovalViewController animated:YES];
        }
    } else if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self.hud hide:YES];
                
                if (profileExist != true || access_grant != true) {
                    if (profileExist != true) {
                        NSString *email = result[@"email"];
                        if (email && [email length] != 0) {
                            [user setObject:email forKey:@"email"];
                        }
                        
                        [user saveInBackground];
                        
                        PAPProfileSettingViewController *profileSettingView = [[PAPProfileSettingViewController alloc] init];
                        self.navController.navigationBarHidden = YES;
                        [self.navController pushViewController:profileSettingView animated:NO];
                        return;
                    }
                    
                    PAPprofileApprovalViewController *profileApprovalViewController = [[PAPprofileApprovalViewController alloc] init];
                    [self.navController pushViewController:profileApprovalViewController animated:YES];
                } else {
                    [self facebookRequestDidLoad:result];
                }
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [PAPUtility processFacebookProfilePictureData:_data];
}


#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginSelectionController {
    PAPLoginSelectionViewController *loginSelectionViewController = [[PAPLoginSelectionViewController alloc] init];
    [self.navController pushViewController:loginSelectionViewController animated:YES];
}

- (void)presentTutorialViewController {
    PAPLoginTutorialViewController *loginTutorialViewController = [[PAPLoginTutorialViewController alloc] init];
    [self.navController pushViewController:loginTutorialViewController animated:YES];
}

-(void)settingRootViewAsTabBarController {
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
    [self presentTabBarController];
}

- (void)presentTabBarController {
    NSLog(@"Welcome TeamStory");
    NSInteger imageOffset = 6.0f;
    
    self.tabBarController = [[PAPTabBarController alloc] init];
    self.homeViewController = [[PAPHomeViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController = [[PAPActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    self.accountViewController_tabBar = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    self.discoverViewController = [[discoverPageViewController alloc] initWithStyle:UITableViewStylePlain];
    
    // special user setting function for accountviewcontroller.
    [accountViewController_tabBar setUser:[PFUser currentUser]];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *perksNavigationController = [[UINavigationController alloc] initWithRootViewController:self.discoverViewController];
    UINavigationController *accountNavigationController = [[UINavigationController alloc] initWithRootViewController:self.accountViewController_tabBar];

    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] init];
    [homeTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"IconHomeSelected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"IconHome.png"]];
    homeTabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0.0f, -imageOffset, 0.0f);
    
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] init];
    [activityFeedTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"IconActivitySelected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"IconActivity.png"]];
    activityFeedTabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0.0f, -imageOffset, 0.0f);

    
    UITabBarItem *perksTabBarItem = [[UITabBarItem alloc] init];
    [perksTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"IconDiscoverSelected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"IconDiscover.png"]];
    perksTabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0.0f, -imageOffset, 0.0f);

    
    UITabBarItem *accountTabBarItem = [[UITabBarItem alloc] init];
    [accountTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"IconProfileSelected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"IconProfile.png"]];
    accountTabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0.0f, -imageOffset, 0.0f);
    
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    [perksNavigationController setTabBarItem:perksTabBarItem];
    [accountNavigationController setTabBarItem:accountTabBarItem];


    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[ homeNavigationController, perksNavigationController, emptyNavigationController, activityFeedNavigationController, accountNavigationController ];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
        
    // Download user's profile picture
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    
    // syncs icon badge with tab bar badge if value is not 0 and controllers present (only on launch)
    if ([UIApplication sharedApplication].applicationIconBadgeNumber != 0) {
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
            
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            NSNumber *newBadgeValue = [NSNumber numberWithInteger:[UIApplication sharedApplication].applicationIconBadgeNumber];
            tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            
            // notify activity of new notification (didreceivenot. is not called in launch)
            [self.activityViewController notificationSetup:(int)[UIApplication sharedApplication].applicationIconBadgeNumber source:@"launch"];
        }
    }
}

- (void)logOut {
    // clear cache
    [[PAPCache sharedCache] clear];

    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginSelectionController];
    
    self.homeViewController = nil;
    self.activityViewController = nil;
}


#pragma mark - ()

- (void)setupAppearance {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.498f green:0.388f blue:0.329f alpha:1.0f]];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                UITextAttributeTextColor: [UIColor whiteColor],
                          UITextAttributeTextShadowColor: [UIColor colorWithWhite:0.0f alpha:0.750f],
                         UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)]
     }];
     
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"BackgroundNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];

    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                UITextAttributeTextColor: [UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0f],
                          UITextAttributeTextShadowColor: [UIColor colorWithWhite:0.0f alpha:0.750f],
                         UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)]
     } forState:UIControlStateNormal];
     
 
    
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:32.0f/255.0f green:19.0f/255.0f blue:16.0f/255.0f alpha:1.0f]];    
}

- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:ReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostName:@"api.parse.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions userInfo:(NSDictionary *)userInfo source:(NSString *)source {
    

    // handle notification payload based on source (launching or background)
    NSDictionary *remoteNotificationPayload;
    
    if([source isEqualToString:@"launch"]){
        remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
    }else if([source isEqualToString:@"background"]){
        remoteNotificationPayload = userInfo;
    }
    
    if (remoteNotificationPayload) {
        
        NSString *notificationSource = [userInfo objectForKey:@"source"];
        NSString *typeOfNotification = [userInfo objectForKey:@"t"];
        
        if([notificationSource isEqualToString:@"konotor"]){
            self.isKonotor = YES;
            [Konotor handleRemoteNotification:remoteNotificationPayload withShowScreen:YES];
        }
    
        if (![PFUser currentUser]) {
            return;
        }
        
        // call activity notification setup and reset badges
        [self.activityViewController notificationSetup:(int)[UIApplication sharedApplication].applicationIconBadgeNumber source:@"notification background"];
        [self.activityViewController setActivityBadge:nil];
        
    
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            
            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId] notificationType:typeOfNotification];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                    
                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
                    accountViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
        
    }
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    if ([PFFacebookUtils isLinkedWithUser:user]) {
        if ([PAPUtility userHasValidFacebookData:[PFUser currentUser]]) {
            [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
            [self presentTabBarController];

            [self.navController dismissViewControllerAnimated:YES completion:nil];
            return YES;
        }
    } else if ([PFTwitterUtils isLinkedWithUser:user]){
        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        [self presentTabBarController];
        
        [self.navController dismissViewControllerAnimated:YES completion:nil];
        return YES;

    }
    
    return NO;
}

- (BOOL)handleActionURL:(NSURL *)url {
    if ([[url host] isEqualToString:kPAPLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    } else {
        if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
            if (photoObjectId && photoObjectId.length > 0) {
                [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId] notificationType:nil];
                return YES;
            }
        }
    }

    return NO;
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);

    networkStatus = [curReach currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        NSLog(@"Network not reachable.");
    }
    
    if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
        // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
        // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
        [self.homeViewController loadObjects];
    }
}

- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto notificationType:(NSString *)type {
    
    // get photo from objects in homeviewcontroller
    NSArray *homeObjects = self.homeViewController.objects;
    for (int i = 0; i < homeObjects.count; i++) {
        PFObject *photo = (PFObject *)homeObjects[i];
        if ([photo.objectId isEqualToString:targetPhoto.objectId]) {
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:PAPHomeTabBarItemIndex];
    
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            PAPPhotoDetailsViewController *detailViewController;
            
            if([type isEqualToString:kPAPActivityTypeComment]){
                detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:object source:@"notificationComment"];
            }else{
                detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:object source:@"notification"];
            }
           
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];
}


- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[PAPCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if (![user objectForKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey]) {
                self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                firstLaunch = YES;
                
                [user setObject:@YES forKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey];
                NSError *error = nil;
                
                // find common Facebook friends already using Teamstory
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookIds];
                
                // auto-follow Parse employees
                PFQuery *autoFollowAccountsQuery = [PFUser query];
                [autoFollowAccountsQuery whereKey:kPAPUserFacebookIDKey containedIn:kPAPAutoFollowAccountFacebookIds];
                
                // combined query
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:autoFollowAccountsQuery,facebookFriendsQuery, nil]];
                
                NSArray *TeamstoryFriends = [query findObjects:&error];
                
                if (!error) {
                    [TeamstoryFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        PFObject *joinActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
                        [joinActivity setObject:user forKey:kPAPActivityFromUserKey];
                        [joinActivity setObject:newFriend forKey:kPAPActivityToUserKey];
                        [joinActivity setObject:kPAPActivityTypeJoined forKey:kPAPActivityTypeKey];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        // make sure our join activity is always earlier than a follow
                        [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [PAPUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                // This block will be executed once for each friend that is followed.
                                // We need to refresh the timeline when we are following at least a few friends
                                // Use a timer to avoid refreshing innecessarily
                                if (self.autoFollowTimer) {
                                    [self.autoFollowTimer invalidate];
                                }
                                
                                self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                            }];
                        }];
                    }];
                }
                
                if (![self shouldProceedToMainInterface:user]) {
                    [self logOut];
                    return;
                }
                
                if (!error) {
                    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                    if (TeamstoryFriends.count > 0) {
                        self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                        self.hud.dimBackground = YES;
                        self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                    } else {
                        [self.homeViewController loadObjects];
                    }
                }
            }
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        self.hud.labelText = NSLocalizedString(@"Creating Profile", nil);
        
        
        if (user) {
            /*
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:kPAPUserDisplayNameKey];
            } else {
                [user setObject:@"Someone" forKey:kPAPUserDisplayNameKey];
            }
            */
            
            NSString *email = result[@"email"];
            if (email && [email length] != 0) {
                [user setObject:email forKey:@"email"];
            }
            
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:kPAPUserFacebookIDKey];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
        }
    }
}

@end
