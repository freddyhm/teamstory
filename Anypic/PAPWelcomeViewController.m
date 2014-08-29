//
//  PAPWelcomeViewController.m
//  Teamstory
//
//

#import "PAPWelcomeViewController.h"
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "PAPLoginTutorialViewController.h"
#import "PAPHomeViewController.h"
#import "PAPprofileSetupViewController.h"
#import "Mixpanel.h"

@implementation PAPWelcomeViewController

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        
    // set temp background to splash screen depending on iphone type
    self.view.backgroundColor = IS_WIDESCREEN ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h.png"]] : [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
    
    PFUser *user = [PFUser currentUser];

    // If not logged in, present login view controller
    if (!user) {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTutorialViewController];
        return;
    }

    // Show spinning indicator while user is being refreshed
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD show];
    
    
    [user refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
       [SVProgressHUD dismissQuickly];
        [SVProgressHUD setForegroundColor:[UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
    
        if(!error){
            NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
            bool profileExist = [profilExist_num boolValue];
            
            if (user && profileExist == YES) {
                [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
                // Present Teamstory UI
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
            } else {
                if (user && profileExist != YES) {
                    
                    // analytics
                    [PAPUtility captureScreenGA:@"New Profile"];
                
                    PAPprofileSetupViewController *profileSetupViewController = [[PAPprofileSetupViewController alloc] init];
                    self.navigationController.navigationBarHidden = YES;
                    [self.navigationController pushViewController:profileSetupViewController animated:NO];
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
