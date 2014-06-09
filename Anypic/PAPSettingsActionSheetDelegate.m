//
//  PAPSettingsActionSheetDelegate.m
//  Teamstory
//
//

#import "PAPSettingsActionSheetDelegate.h"
#import "PAPFindFriendsViewController.h"
#import "PAPAccountViewController.h"
#import "AppDelegate.h"
#import "PAPProfileSettingViewController.h"
#import "PAPwebviewViewController.h"
#import "PAPNotificationViewController.h"


// ActionSheet button indexes
typedef enum {
	kPAPSettingsProfile = 0,
    kPAPAboutThisVersion,
    kPAPPrivacyPolicy,
    kPAPTermsofUse,
    kPAPSettingsLogout,
    kPAPNotification,
    kPAPSettingsNumberOfButtons
} kPAPSettingsActionSheetButtons;
 
@implementation PAPSettingsActionSheetDelegate

@synthesize navController;

#if DEBUG
static NSString *const kevin_account = @"wKx1GsCnSq";
static NSString *const justin_account = @"WUZTy3Ayxy";
static NSString *const freddy_account = @"4Su2vXzhFq";
#else
static NSString *const kevin_account = @"3KiW2NoGuT";
static NSString *const justin_account = @"vB648p1bT1";
static NSString *const freddy_account = @"rblDQcdZcY";
#endif

#pragma mark - Initialization

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        }
    }
}

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        navController = navigationController;
    }
    return self;
}

- (id)init {
    return [self initWithNavigationController:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.navController) {
        [NSException raise:NSInvalidArgumentException format:@"navController cannot be nil"];
        return;
    }
    
    switch ((kPAPSettingsActionSheetButtons)buttonIndex) {
        case kPAPSettingsProfile:
        {
            PAPProfileSettingViewController *profileViewController = [[PAPProfileSettingViewController alloc] init];
            profileViewController.hidesBottomBarWhenPushed = YES;
            [navController pushViewController:profileViewController animated:YES];
            break;
        }
            /*
        case kPAPSettingsFindFriends:
        {
            PAPFindFriendsViewController *findFriendsVC = [[PAPFindFriendsViewController alloc] init];
            [navController pushViewController:findFriendsVC animated:YES];
            break;
        }
             */
        case kPAPSettingsLogout:
        {
            // Log out user and present the login view controller
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            break;
        }
        case kPAPPrivacyPolicy:
        {
            PAPwebviewViewController *webviewController = [[PAPwebviewViewController alloc] initWithWebsite:@"http://teamstoryapp.com/privacy"];
            webviewController.hidesBottomBarWhenPushed = YES;
            [navController pushViewController:webviewController animated:YES];
            break;
        }
        case kPAPTermsofUse:
        {
            PAPwebviewViewController *webviewController = [[PAPwebviewViewController alloc] initWithWebsite:@"http://teamstoryapp.com/terms"];
            webviewController.hidesBottomBarWhenPushed = YES;
            [navController pushViewController:webviewController animated:YES];
            break;
        }
        case kPAPAboutThisVersion:
        {
            PAPwebviewViewController *webviewController = [[PAPwebviewViewController alloc] initWithWebsite:@"http://teamstoryapp.com/version"];
            webviewController.hidesBottomBarWhenPushed = YES;
            [navController pushViewController:webviewController animated:YES];
            break;
        }
        case kPAPNotification:
        {
            if ([[[PFUser currentUser] objectId] isEqualToString:kevin_account] || [[[PFUser currentUser] objectId] isEqualToString:justin_account] || [[[PFUser currentUser] objectId] isEqualToString:freddy_account]) {
                
                PAPNotificationViewController *notificationController = [[PAPNotificationViewController alloc] init];
                notificationController.hidesBottomBarWhenPushed = YES;
                [navController pushViewController:notificationController animated:YES];
            }

            break;
        }
        default:
            break;
    }
}

@end
