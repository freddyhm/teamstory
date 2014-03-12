//
//  PAPWelcomeViewController.m
//  Teamstory
//
//

#import "PAPWelcomeViewController.h"
#import "AppDelegate.h"
#import "PAPProfileSettingViewController.h"

@implementation PAPWelcomeViewController


#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PFUser *user = [PFUser currentUser];

    // If not logged in, present login view controller
    if (!user) {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginSelectionController];
        return;
    }
    bool profileExist = user[@"profileExist"];
    
    if (user && profileExist == true) {
        [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
        // Present Teamstory UI
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
    } else {
        PAPProfileSettingViewController *profileViewController = [[PAPProfileSettingViewController alloc] init];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:profileViewController animated:NO];
    }
}

#pragma mark - ()

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist.");
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    PFUser *curr_user = [PFUser currentUser];

    if (curr_user) {
        if ([PFFacebookUtils isLinkedWithUser:curr_user]){
            
            // Check if user is missing a Facebook ID
            if ([PAPUtility userHasValidFacebookData:curr_user]) {
                // refresh Facebook friends on each launch
                    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
                                [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
                            }
                        } else {
                            if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
                                [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
                            }
                        }
                    }];
                } else {
                    NSLog(@"Current user is missing their Facebook ID");
                    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
                                [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
                            }
                        } else {
                            if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
                                [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
                            }
                        }
                    }];
                     
                }
        } else if ([PFTwitterUtils isLinkedWithUser:curr_user]) {
            curr_user[@"twitterId"] = [PFTwitterUtils twitter].userId;
            
            [curr_user saveEventually];
        }
    }
}

@end
