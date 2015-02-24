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

@interface PAPSignUpViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *pwTextField;

@end

@implementation PAPSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
            
        }
    }];
}

- (IBAction)signInEmailButtonAction:(id)sender {
    [self userLoginWithEmail];
}

- (IBAction)forgotPWButtonAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password" message:@"Enter your email" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)signedUpWithFacebookAction:(id)sender {
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wrong Email" message:@"Please check your email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
                                                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wrong Email" message:@"Please check your email address or password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                alert.alertViewStyle = UIAlertViewStyleDefault;
                                                [alert show];
                                            }
                                        }];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
