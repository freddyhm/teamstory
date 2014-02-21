//
//  PAPWelcomeViewController.m
//  Teamstory
//
//

#import "PAPWelcomeViewController.h"
#import "AppDelegate.h"

@implementation PAPWelcomeViewController


#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PFUser *user = [PFUser currentUser];

    // If not logged in, present login view controller
    if (!user) {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
    }
    bool profileExist = user[@"profileExist"];
    
    if (user && profileExist == true) {
        // Present Teamstory UI
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
        
        // Refresh current user with server side data -- checks if user is still valid and so on
        [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
    } else {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentAccountViewController];
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

    // Check if user is missing a Facebook ID
    if ([PAPUtility userHasValidFacebookData:[PFUser currentUser]]) {
        // User has Facebook ID.
        
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
}

@end
