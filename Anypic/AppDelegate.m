//
//  AppDelegate.m
//  TeamStory
//


#import "AppDelegate.h"

#import "GAI.h"
#import "Konotor.h"
#import "KonotorEventHandler.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "PAPHomeViewController.h"
#import "PAPLogInViewController.h"
#import "PAPAccountViewController.h"
#import "PAPWelcomeViewController.h"
#import "PAPActivityFeedViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "discoverPageViewController.h"
#import "PAPwebviewViewController.h"
#import "PAPLoginTutorialViewController.h"
#import "PhotoTimelineViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "iRate.h"
#import "PAPprofileSetupViewController.h"
#import "Mixpanel.h"
#import "PAPMessageListViewController.h"
#import "PAPMessagingViewController.h"
#import "PAPMessageListCell.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "ParseFacebookUtils/PFFacebookUtils.h"
#import "Intercom.h"
#import <FlightRecorder/FlightRecorder.h>
#import "SVProgressHUD.h"
#import "AtMention.h"


@interface AppDelegate () {
    NSMutableData *_data;
    BOOL firstLaunch;
    BOOL navigation;
}


@property (nonatomic, strong) PAPHomeViewController *homeViewController;
@property (nonatomic, strong) PAPActivityFeedViewController *activityViewController;
@property (nonatomic, strong) PAPWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) PAPAccountViewController *accountViewController_tabBar;
@property (nonatomic, strong) PAPLogInViewController *loginviewcontroller;
@property (nonatomic, strong) discoverPageViewController *discoverViewController;
@property (nonatomic, strong) PhotoTimelineViewController *photoTimelineViewController;
@property (nonatomic, strong) PAPMessageListCell *messageListCell;
@property (nonatomic, strong) PAPMessagingViewController *messagingViewController;

@property (nonatomic, strong) NSDictionary *currentUserInfo;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSTimer *autoFollowTimer;
@property BOOL isKonotor;

@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;
@property (nonatomic, strong) PFUser *messageTargetUser;
@property (nonatomic, strong) PFObject *chatRoom;

@property (nonatomic, strong) NSString *userView;
@property (nonatomic, strong) UITableView *messageList;
@property (nonatomic, strong) PFObject *targetChatRoom;
@property (nonatomic, strong) PFUser *targetChatRoomUser;

@property (nonatomic, strong) UINavigationController *currentNavController;

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
static NSString *const MIXPANEL_TOKEN = @"093959a404024512d35ec784652d01fc";
static NSString *const INTERCOM_APP_ID = @"wegcp2zo";
static NSString *const INTERCOM_API_KEY = @"ios_sdk-3d95ebf6dd46972ddd320f375dde491b6a8bd768";
static NSString *const FLIGHT_RECORDER_ACCESS_KEY = @"dc3a7ccf-2213-4a39-8051-6c3e17edd816";
static NSString *const FLIGHT_RECORDER_SECRET_KEY = @"687ad781-d396-495b-8349-b44b22631327";
#else
static NSString *const GOOGLE_TRACKING_ID = @"UA-49381420-1";
static NSString *const KONOTOR_APP_ID = @"ab785be6-9398-4b6a-8ae6-4d83431edad9";
static NSString *const KONOTOR_APP_KEY = @"3784ef60-6e0f-48fc-9a6c-3ac71c127dcb";
static NSString *const PARSE_APP_ID = @"SPQlkxDYPDcVhbICHFzjwSsREHaSqKQIKwkijDaJ";
static NSString *const PARSE_CLIENT_KEY = @"WtgkZLYZ1UOlsbGMnfYtKCD6dQLMfy3tBsN2UKxA";
static NSString *const TWITTER_KEY = @"VGiCnk6P01PjqV13rm34Bw";
static NSString *const TWITTER_SECRET = @"agzbVGDyyuFvpZ4kJecoXoJYC4cTOZEVGjJIO0z9Q";
static NSString *const MIXPANEL_TOKEN = @"bdd5714ea8e6eccea911feb0a97e1b82";
static NSString *const INTERCOM_APP_ID = @"rtntztae";
static NSString *const INTERCOM_API_KEY = @"ios_sdk-7bcd17d996532a8658cd72694ad1a7fb37479039";
static NSString *const FLIGHT_RECORDER_ACCESS_KEY = @"491e25ad-4e58-4a7d-bee1-56be847ba74b";
static NSString *const FLIGHT_RECORDER_SECRET_KEY = @"bb15b7b3-0990-4eea-b531-17545f746ff3";
#endif

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 1;
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_TRACKING_ID];
    
    // Mixpanel analytics
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // Konotor setup
    [Konotor InitWithAppID:KONOTOR_APP_ID AppKey:KONOTOR_APP_KEY withDelegate:[KonotorEventHandler sharedInstance]];
    
    [Konotor setWelcomeMessage:@"Welcome to Teamstory! Thoughts or feedback? Chat with us here anytime"];

    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    
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

    // Intercom setup
    [Intercom setApiKey:INTERCOM_API_KEY forAppId:INTERCOM_APP_ID];
    
    // Intercom push notifications
    [Intercom registerForRemoteNotifications];
    
    // Set installation id for mixpanel and crashlytics analytics
    NSString *installationId = [[PFInstallation currentInstallation] objectId];
    
    if(installationId != nil){
        [Crashlytics setUserIdentifier:installationId];
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"InstallationObjId": installationId}];
    }
    
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
    
    [self cycleTheGlobalMailComposer];

    // handle push notifications
    [self handlePush:launchOptions userInfo:nil source:@"launch"];
    
    // load users for mention
    AtMention *one = [AtMention sharedAtMention];
    [one getAllUsers:^(NSArray *objects, BOOL succeeded, NSError *error) {}];
    
    // Flight recorder
    [[FlightRecorder sharedInstance] setAccessKey:FLIGHT_RECORDER_ACCESS_KEY secretKey:FLIGHT_RECORDER_SECRET_KEY];
    [[FlightRecorder sharedInstance] setShouldStartLocationManager:YES];
    [[FlightRecorder sharedInstance] startFlight];

    return YES;
}

-(void)cycleTheGlobalMailComposer {
    // we are cycling the damned GlobalMailComposer... due to horrible iOS issue
    self.mc = nil;
    self.mc = [[MFMailComposeViewController alloc] init];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // mixpanel notification setup
    [[Mixpanel sharedInstance].people addPushDeviceToken:newDeviceToken];
    
    // konotor notifications setup
    [Konotor addDeviceToken:newDeviceToken];
    
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
    NSString *notificationType = [userInfo objectForKey:kPAPPushPayloadPayloadTypeKey];
    NSString *currentObjectId = [userInfo objectForKey:@"aid"];
    NSString *targetUserObjectId = [userInfo objectForKey:kPAPPushPayloadFromUserObjectIdKey];
    
    // handle type of notification
    if ([pushSrc isEqualToString:@"konotor"]){
        self.isKonotor = YES;
        
        [[PFUser currentUser] incrementKey:@"messagingBadge"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageButton" object:nil];
        }];
        
        // app is in foreground
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [Konotor handleRemoteNotification:userInfo withShowScreen:NO];
        }else{
            [Konotor handleRemoteNotification:userInfo withShowScreen:YES];
            [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        }
        
    } else if ([notificationType isEqualToString:@"m"]) {
        self.currentUserInfo = userInfo;
        
        NSNumber *currentMessageBadgeNumber;
        NSNumber *newMessageBadgeNumber;
        currentMessageBadgeNumber = [[PFUser currentUser] objectForKey:@"messagingBadge"];
        
        if ([currentMessageBadgeNumber intValue] > 0) {
            newMessageBadgeNumber = [NSNumber numberWithInt:[currentMessageBadgeNumber intValue] + 1];
        } else {
            newMessageBadgeNumber = [NSNumber numberWithInt:1];
        }
        
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            if ([PFUser currentUser]) {
                self.messageListCell = [[PAPMessageListCell alloc] init];
                self.messagingViewController = [[PAPMessagingViewController alloc] init];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageButton" object:nil];
                
                if ([self.userView isEqual:@"messagingScreen"] && [[self.targetChatRoomUser objectId] isEqualToString:targetUserObjectId]) {
                    [SVProgressHUD dismiss];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableView" object:currentObjectId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageListView" object:nil];
                } else if ([self.userView isEqualToString:@"messagingListViewScreen"]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateListViewQuery" object:nil];
                } else {
                    [KonotorUtility showToastWithString:@"New message received" forMessageID:@"messaging"];
                }
            }
        } else {
            [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
            [self handlePush:nil userInfo:userInfo source:@"background"];
        }
    } else {
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
                        
                        [[PFUser currentUser] incrementKey:@"activityBadge"];
                        [[PFUser currentUser] saveInBackground];
                        
                        // icon value
                        application.applicationIconBadgeNumber = [newBadgeValue intValue];
                    } else {
                        
                        // get current selected tab
                        NSUInteger selectedtabIndex = self.tabBarController.selectedIndex;
                        
                        // add badge value only if current screen isn't activity (image sizing issue)
                        if(selectedtabIndex != PAPActivityTabBarItemIndex){
                            tabBarItem.badgeValue = @"1";
                        }
                        
                        application.applicationIconBadgeNumber = 1;
                        
                        [[PFUser currentUser] setObject:[NSNumber numberWithInt:1] forKey:@"activityBadge"];
                        [[PFUser currentUser] saveInBackground];
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
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSNumber *activityBadgeNumber = [[PFUser currentUser] objectForKey:@"activityBadge"];
        
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
        
    // syncs icon badge with tab bar badge, resets icon badge back to 0
    if (application.applicationIconBadgeNumber != 0) {

            // check if tab controllers and activity tab exist
            if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
                
                UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
                
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                
                if ([activityBadgeNumber intValue] > 0) {
                    tabBarItem.badgeValue = [numberFormatter stringFromNumber:activityBadgeNumber];
                } else {
                    tabBarItem.badgeValue = nil;
                }
                
                // get current selected tab
                NSUInteger selectedtabIndex = self.tabBarController.selectedIndex;
                
                // current view is activity, clear the badge
                if(selectedtabIndex == PAPActivityTabBarItemIndex){
                    [self.activityViewController setActivityBadge:nil];
                    [self.activityViewController loadObjects];
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageButton" object:nil];
        
        // Clears out all notifications from Notification Center.
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        [[FBSession activeSession] handleDidBecomeActive];
        
        // initiate konotor
        [Konotor newSession];
    }
    }];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    PAPTabBarController *tabBar = (PAPTabBarController *)aTabBarController;
    UINavigationController *selectedNav = (UINavigationController *)viewController;
    
    // get selected controller and current controller
    BOOL isHomeViewSelected = [[[selectedNav viewControllers] objectAtIndex:0] isKindOfClass:[PAPHomeViewController class]];
    BOOL isCurrentViewHome = (int)self.tabBarController.selectedIndex == 0 ? YES : NO;
    
    // scroll to top and refresh if source and destination are the same
    if(isHomeViewSelected && isCurrentViewHome){
        [[[selectedNav viewControllers] objectAtIndex:0] refreshCurrentFeed];
    }

    /* This is a fail-safe: PAPTabBarController's "Handle outside tap gesture" should handle this before it reaches this method. Hiding and showing the tabbar is affecting this function so fail-safe is used. */
    
    // check if tab bar post menu is present, do not change tabs if so
    if(!tabBar.postMenu.hidden){
        return false;
    }else{
        // The empty UITabBarItem behind our Camera button should not load a view controller
        return ![viewController isEqual:aTabBarController.viewControllers[PAPEmptyTabBarItemIndex]];
    }
}


#pragma mark - PFLoginViewController

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    [self shouldProceedToMainInterface:user];
    NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
    bool profileExist = [profilExist_num boolValue];
    
    
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]){
        [[PFUser currentUser] setObject:[PFTwitterUtils twitter].userId forKey:@"twitterID"];
        
        if (profileExist != true) {
            PAPprofileSetupViewController *profileSetupViewController = [[PAPprofileSetupViewController alloc] init];
            self.navController.navigationBarHidden = YES;
            [self.navController pushViewController:profileSetupViewController animated:NO];
            return;
        }
            
        [self settingRootViewAsTabBarController];
        
    } else if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
            
                if (profileExist != true) {
                    NSString *email = result[@"email"];
                    if (email && [email length] != 0) {
                        [user setObject:email forKey:@"email"];
                        [user setObject:email forKey:@"username"];
                    }
                    
                    [user saveInBackground];
                    
                    PAPprofileSetupViewController *profileSettingView = [[PAPprofileSetupViewController alloc] init];
                    self.navController.navigationBarHidden = YES;
                    [self.navController pushViewController:profileSettingView animated:NO];
                    return;
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
    PAPLoginTutorialViewController *loginSelectionViewController = [[PAPLoginTutorialViewController alloc] init];
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
    self.homeViewController = [[PAPHomeViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController = [[PAPActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    self.accountViewController_tabBar = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];

    self.discoverViewController = [[discoverPageViewController alloc] init];
   

    
    // special user setting function for accountviewcontroller.
    [accountViewController_tabBar setUser:[PFUser currentUser]];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *perksNavigationController = [[UINavigationController alloc] initWithRootViewController:self.discoverViewController];
    UINavigationController *accountNavigationController = [[UINavigationController alloc] initWithRootViewController:self.accountViewController_tabBar];

    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] init];
    
    [homeTabBarItem setImage:[[UIImage imageNamed:@"nav_home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [homeTabBarItem setSelectedImage:[[UIImage imageNamed:@"IconHomeSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    homeTabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0.0f, -imageOffset, 0.0f);
    
    
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] init];
    
    [activityFeedTabBarItem setImage:[[UIImage imageNamed:@"nav_activity.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [activityFeedTabBarItem setSelectedImage:[[UIImage imageNamed:@"IconActivitySelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    activityFeedTabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0.0f, -imageOffset, 0.0f);

    
    UITabBarItem *perksTabBarItem = [[UITabBarItem alloc] init];
    
    [perksTabBarItem setImage:[[UIImage imageNamed:@"nav_discover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [perksTabBarItem setSelectedImage:[[UIImage imageNamed:@"IconDiscoverSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
   
    perksTabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0.0f, -imageOffset, 0.0f);

    
    UITabBarItem *accountTabBarItem = [[UITabBarItem alloc] init];

    [accountTabBarItem setImage:[[UIImage imageNamed:@"nav_profile.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [accountTabBarItem setSelectedImage:[[UIImage imageNamed:@"IconProfileSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    accountTabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0.0f, -imageOffset, 0.0f);
    
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    [perksNavigationController setTabBarItem:perksTabBarItem];
    [accountNavigationController setTabBarItem:accountTabBarItem];


    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[ homeNavigationController, perksNavigationController, emptyNavigationController, activityFeedNavigationController, accountNavigationController ];
    
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];

    // Download user's profile picture
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    
    // syncs icon badge with tab bar badge if value is not 0 and controllers present (only on launch)
    // syncs icon badge with tab bar badge, resets icon badge back to 0
        
    // check if tab controllers and activity tab exist
    if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
        
        UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        NSNumber *newBadgeValue = [[PFUser currentUser] objectForKey:@"activityBadge"];
        if ([newBadgeValue integerValue] > 0) {
            tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
        }
        
        // get current selected tab
        NSUInteger selectedtabIndex = self.tabBarController.selectedIndex;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageButton" object:nil];
        
        // current view is activity, clear the badge
        if(selectedtabIndex == PAPActivityTabBarItemIndex){
            [self.activityViewController setActivityBadge:nil];
            [self.activityViewController loadObjects];
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

- (void)setUserCurrentScreen:(NSString *)currentScreen setTargetRoom:(PFObject *)targetRoom setTargetUser:(PFUser *)user setNavigationController:(UINavigationController *)navigationController{
    self.userView = currentScreen;
    self.targetChatRoom = targetRoom;
    self.targetChatRoomUser = user;
    self.currentNavController = navigationController;
}

- (void)setupAppearance {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.498f green:0.388f blue:0.329f alpha:1.0f]];
    
    NSDictionary *navBarAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};

    [[UINavigationBar appearance] setTitleTextAttributes:navBarAttributes];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"OriginalBackgroundNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *barButtonItemAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
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
        NSString *activityTypeNotification = [userInfo objectForKey:@"t"];
        NSString *photoId = [userInfo objectForKey:@"pid"];
        NSString *activityId = [userInfo objectForKey:@"aid"];
        NSString *toUserId = [userInfo objectForKey:kPAPPushPayloadFromUserObjectIdKey];
        
        NSString *messageRoomId = [userInfo objectForKey:kPAPPushPayloadChatRoomObjectIdKey];
        NSString *notificationType = [userInfo objectForKey:kPAPPushPayloadPayloadTypeKey];
        
        if ([notificationType isEqualToString:@"m"]) {
            [self navigateToChatRoomWithNotificationWithTargetUser:toUserId setRoomInfo:messageRoomId];
            return;
        }
        
        if([notificationSource isEqualToString:@"konotor"]){
            self.isKonotor = YES;
            [Konotor handleRemoteNotification:remoteNotificationPayload withShowScreen:YES];
        }
    
        if (![PFUser currentUser]) {
            return;
        }
        
        // add to read list as read and reset badge
        [self.activityViewController addActivityToReadList:activityId postId:photoId customAttributes:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"read",@"status", nil]];
        [self.activityViewController setActivityBadge:nil];
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            
            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId] notificationType:activityTypeNotification];
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
                    
                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];

                    accountViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
        
    }
}

- (void) navigateToChatRoomWithNotificationWithTargetUser:(NSString *)targetUserId setRoomInfo:(NSString *)roomInfoId {
    navigation = NO;
    
    self.messageTargetUser = nil;
    self.chatRoom = nil;
    
    PFQuery *targetUser = [PFUser query];
    targetUser.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [targetUser whereKey:@"objectId" equalTo:targetUserId];
    [targetUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.messageTargetUser = (PFUser *)object;
        [self navigateToChatRoom];
    }];
    
    PFQuery *chatRoomQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    chatRoomQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [chatRoomQuery whereKey:@"objectId" equalTo:roomInfoId];
    [chatRoomQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.chatRoom = object;
        [self navigateToChatRoom];
    }];
}

-(void) navigateToChatRoom {
    if (self.messageTargetUser != nil && self.chatRoom != nil && navigation == NO) {
        navigation = YES;
        UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
        self.tabBarController.selectedViewController = homeNavigationController;
        NSString *userNumber;
        
        PFObject *currentObject = self.chatRoom;
        NSNumber *offSetBadgeNumber;
        
        if ([[[self.chatRoom objectForKey:@"userOne"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            userNumber = @"userTwo";
        } else {
            userNumber = @"userOne";
        }
        
        if ([userNumber isEqualToString:@"userOne"]) {
            offSetBadgeNumber = [currentObject objectForKey:@"userTwoBadge"];
            [currentObject setObject:[NSNumber numberWithInt:0] forKey:@"userTwoBadge"];
        } else {
            offSetBadgeNumber = [currentObject objectForKey:@"userOneBadge"];
            [currentObject setObject:[NSNumber numberWithInt:0] forKey:@"userOneBadge"];
        }
        
        [currentObject saveInBackground];
        
        if ([[[PFUser currentUser] objectForKey:@"messagingBadge"] intValue] - [offSetBadgeNumber intValue] < 0 ) {
            [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"messagingBadge"];
        } else {
            [[PFUser currentUser] setObject:[NSNumber numberWithInt:[[[PFUser currentUser] objectForKey:@"messagingBadge"] intValue] - [offSetBadgeNumber intValue]] forKey:@"messagingBadge"];
        }
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageButton" object:nil];
        }];
        
        if ([PFInstallation currentInstallation].badge - [offSetBadgeNumber intValue] < 0) {
            [[PFInstallation currentInstallation] setBadge:0];
        } else {
            [[PFInstallation currentInstallation] setBadge:[PFInstallation currentInstallation].badge - [offSetBadgeNumber intValue]];
        }
        [[PFInstallation currentInstallation] saveInBackground];
        
        [self.currentNavController popToRootViewControllerAnimated:NO];
        
        PAPMessageListViewController *messageListViewController = [[PAPMessageListViewController alloc] init];
        PAPMessagingViewController *messagingViewController = [[PAPMessagingViewController alloc] init];
        [messagingViewController setTargetUser:self.messageTargetUser setUserNumber:userNumber];
        [messagingViewController setRoomInfo:self.chatRoom];
        messageListViewController.hidesBottomBarWhenPushed = YES;
        messagingViewController.hidesBottomBarWhenPushed = YES;
        
        [CATransaction begin];
        [homeNavigationController pushViewController:messageListViewController animated:NO];
        [SVProgressHUD dismiss];
        [CATransaction setCompletionBlock:^{
            [SVProgressHUD dismiss];
            [homeNavigationController pushViewController:messagingViewController animated:NO];
        }];
        [CATransaction commit];
    }
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects:nil isRefresh:NO fromSource:@"explore"];
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
    
    /*
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
     */

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
        [self.homeViewController loadObjects:nil isRefresh:NO fromSource:@"explore"];
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
            NSString *sourceType;
            
            if([type isEqualToString:kPAPPushPayloadActivityCommentKey]){
                sourceType = @"notificationComment";
            }else if([type isEqualToString:kPAPPushPayloadActivityLikeCommentKey]){
                sourceType = @"notificationLikeComment";
            }else if ([type isEqualToString:kPAPPushPayloadActivityLikeKey]){
                sourceType = @"notificationLike";
            }else if([type isEqualToString:kPAPPushPayloadActivityPostKey]){
                sourceType = @"notificationPost";
            }
            
            detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:object source:sourceType];
            
            // hides tab bar so we can add custom keyboard
            detailViewController.hidesBottomBarWhenPushed = YES;

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
                        [self.homeViewController loadObjects:nil isRefresh:NO fromSource:@"explore"];
                    }
                }
            }
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        
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
                [user setObject:email forKey:@"username"];
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

- (void)navigateToCurrentMessagingRoom {
    if (self.currentUserInfo != NULL) {
        NSLog(@"currentUserInfo: %@", self.currentUserInfo);
        NSString *toUserId = [self.currentUserInfo objectForKey:kPAPPushPayloadFromUserObjectIdKey];
        NSString *messageRoomId = [self.currentUserInfo objectForKey:kPAPPushPayloadChatRoomObjectIdKey];
        [self navigateToChatRoomWithNotificationWithTargetUser:toUserId setRoomInfo:messageRoomId];
    }
}

@end
