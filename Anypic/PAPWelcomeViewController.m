//
//  PAPWelcomeViewController.m
//  Teamstory
//
//

#import "PAPWelcomeViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "PAPHomeViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "PAPLoginInfoSheetViewController.h"

@implementation PAPWelcomeViewController

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        
    // set temp background to splash screen depending on iphone type
    self.view.backgroundColor = IS_WIDESCREEN ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h.png"]] : [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
    
    PFUser *user = [PFUser currentUser];
    
    // checking for new anonymous Users.
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
        return;
    }

    // If not logged in, present login view controller
    if (!user) {
        //[(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTutorialViewController];
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed.");
            } else {
                NSLog(@"Anonymous user logged in.");
                
                // present a tabBar.
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
            }
        }];
        return;
    }
    
    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if(!error){
            NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
            bool profileExist = [profilExist_num boolValue];
            
            if (user && profileExist == YES) {
                [[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
                // Present Teamstory UI
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
            } else {
                if (user && profileExist != YES) {
                    PAPLoginInfoSheetViewController *loginInfoSheetViewController = [[PAPLoginInfoSheetViewController alloc] initWithNibName:@"PAPLoginInfoSheetViewController" bundle:nil];
                    self.navigationController.navigationBarHidden = YES;
                    [self.navigationController pushViewController:loginInfoSheetViewController animated:NO];
                } else {
                    NSLog(@"User does not exist");
                }
            }
        }else{
            NSLog(@"%@", error);
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Logging you off and sending you back to main screen" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
            
            if([PFUser currentUser]){
                [PFUser logOut];
            }
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTutorialViewController];
        }
    }];
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
