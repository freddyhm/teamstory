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

// ActionSheet button indexes
typedef enum {
	kPAPSettingsProfile = 0,
    kPAPTermsandPolicy,
    kPAPAboutThisVersion,
    kPAPSettingsLogout,
    kPAPSettingsNumberOfButtons
} kPAPSettingsActionSheetButtons;
 
@implementation PAPSettingsActionSheetDelegate

@synthesize navController;

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
        case kPAPTermsandPolicy:
        {
            PAPwebviewViewController *webviewController = [[PAPwebviewViewController alloc] init];
            webviewController.hidesBottomBarWhenPushed = YES;
            [navController pushViewController:webviewController animated:YES];
            break;
        }
        case kPAPAboutThisVersion:
        {
        }
        default:
            break;
    }
}

@end
