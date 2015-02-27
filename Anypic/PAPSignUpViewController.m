//
//  PAPSignUpViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/23/15.
//
//

#import "PAPSignUpViewController.h"
#import "PAPLoginInfoSheetViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface PAPSignUpViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *pwTextField;


@end

@implementation PAPSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)signInButtonAction:(id)sender {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            [self navigateToInfoSheet];
        } else {
            NSLog(@"User logged in with Twitter!");
            NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
            bool profileExist = [profilExist_num boolValue];
            
            if (user && profileExist != YES) {
                PAPLoginInfoSheetViewController *loginInfoSheetViewController = [[PAPLoginInfoSheetViewController alloc] initWithNibName:@"PAPLoginInfoSheetViewController" bundle:nil];
                self.navigationController.navigationBarHidden = YES;
                [self presentViewController:loginInfoSheetViewController animated:YES completion:nil];
            } else if (user && profileExist == YES) {
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
            }
        }
    }];
}

- (IBAction)signInEmailButtonAction:(id)sender {
    [self userLoginWithEmail];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)forgotPWButtonAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password" message:@"Enter your email" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)signedUpWithFacebookAction:(id)sender {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [SVProgressHUD dismiss]; // Hide loading indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
        }
    }];
    
    [SVProgressHUD dismiss]; // Show loading indicator until login is finished
}

- (void) navigateToInfoSheet {
    PAPLoginInfoSheetViewController *loginInfoSheetController = [[PAPLoginInfoSheetViewController alloc] initWithNibName:@"PAPLoginInfoSheetViewController" bundle:nil];
    [self presentViewController:loginInfoSheetController animated:YES completion:nil];
}

-(void) userLoginWithEmail {
    [SVProgressHUD show];
    
    [self.view endEditing:YES];
    
    NSString *userEmail = self.emailTextField.text;
    NSString *userPW = self.pwTextField.text;
    
    // checking for email address in advance.
    if (![self NSStringIsValidEmail:self.emailTextField.text]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wrong Email" message:@"Please check your email address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return;
    }
    
    if ([(AppDelegate*)[[UIApplication sharedApplication] delegate] isParseReachable]) {
        [PFUser logInWithUsernameInBackground:userEmail password:userPW
                                        block:^(PFUser *user, NSError *error) {
                                            [SVProgressHUD dismiss];
                                            
                                            if (user) {
                                                NSNumber *profileBoolNum = [user objectForKey: @"profileExist"];
                                                bool profileExist = [profileBoolNum boolValue];
                                                
                                                // logged in successfully
                                                if (profileExist == true) {
                                                    [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
                                                    return;
                                                } else if (profileExist != true) {
                                                    // still needs to sign up
                                                    PAPLoginInfoSheetViewController *loginInfoSheetViewController = [[PAPLoginInfoSheetViewController alloc] init];
                                                    [self.navigationController presentViewController:loginInfoSheetViewController animated:YES completion:nil];
                                                }
                                            } else {
                                                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wrong Email" message:@"Please check your email address or password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                alert.alertViewStyle = UIAlertViewStyleDefault;
                                                [alert show];
                                            }
                                        }];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


#pragma mark - UIAlertView Delegate
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 
    NSString *alertTitle = [alertView title];

    // specific action based on active alert
    if([alertTitle isEqualToString:@"Forgot Password"]){

        NSString *input = [[alertView textFieldAtIndex:0] text];

        // button response
        if(buttonIndex != 0){

            // check if email is properly formatted
            if([self NSStringIsValidEmail:input]){
                [PFUser requestPasswordResetForEmailInBackground:input];
            } else {
                UIAlertView *notEmailFormat = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Make sure you enter a valid email address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [notEmailFormat show];
                }
            }

         [self.view endEditing:YES];
    }
}

@end
