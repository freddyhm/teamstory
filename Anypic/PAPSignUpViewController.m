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
@property (strong, nonatomic) IBOutlet UIView *emailTextView;
@property (strong, nonatomic) IBOutlet UIView *passwordTextView;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIButton *signInWithEmailButton;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;


@end

@implementation PAPSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextView.layer.cornerRadius = 2.0f;
    self.passwordTextView.layer.cornerRadius = 2.0f;
    self.signInButton.layer.cornerRadius = 2.0f;
    self.signInWithEmailButton.layer.cornerRadius = 2.0f;
    
    self.emailTextField.delegate = self;
    self.pwTextField.delegate = self;
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
}

- (IBAction)signInButtonAction:(id)sender {
    [SVProgressHUD show];
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        [SVProgressHUD dismiss];
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
    [SVProgressHUD show];
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_location"];
    
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
    [SVProgressHUD dismiss];
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
                
                UIAlertView *successfulAlertView = [[UIAlertView alloc] initWithTitle:@"Successful" message:@"Email Sent!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [successfulAlertView show];
            } else {
                UIAlertView *notEmailFormat = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Make sure you enter a valid email address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [notEmailFormat show];
                }
            }

         [self.view endEditing:YES];
    }
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma UITextViewDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint scrollPoint;
    
    float offsetValue = 20.0f;
    
    if (self.emailTextField == textField) {
        scrollPoint = CGPointMake(0, self.emailTextView.frame.origin.y - offsetValue);
    } else if (self.pwTextField == textField) {
        scrollPoint = CGPointMake(0, self.passwordTextView.frame.origin.y - offsetValue);
    }
    
    [self.mainScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.mainScrollView setContentOffset:CGPointZero animated:YES];
}

@end
