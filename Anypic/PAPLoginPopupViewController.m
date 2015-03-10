//
//  PAPLoginPopupViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/19/15.
//
//

#import "PAPLoginPopupViewController.h"
#import "AppDelegate.h"
#import "PAPLoginInfoSheetViewController.h"
#import "PAPwebviewViewController.h"

@interface PAPLoginPopupViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPWTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *emailTextView;
@property (strong, nonatomic) IBOutlet UIView *passwordTextView;
@property (strong, nonatomic) IBOutlet UIView *confirmPWTextView;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation PAPLoginPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextField.delegate = self;
    self.confirmPWTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.mainScrollView.delegate = self;
    
    self.emailTextView.layer.cornerRadius = 2.0f;
    self.passwordTextView.layer.cornerRadius = 2.0f;
    self.confirmPWTextView.layer.cornerRadius = 2.0f;
    self.twitterButton.layer.cornerRadius = 2.0f;
    self.signUpButton.layer.cornerRadius = 2.0f;
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tapOutside];
    
}
- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)twitterButtonAction:(id)sender {
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
- (IBAction)signUpButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    if (![self.passwordTextField.text isEqualToString:self.confirmPWTextField.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password confirmation failed" message:@"Passwords don't match!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (self.passwordTextField.text.length < 6) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Length" message:@"Please choose a password longer than 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (![self NSStringIsValidEmail:self.emailTextField.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect Email" message:@"Please enter a valid email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [SVProgressHUD show];
    
    PFUser *user = [PFUser user];
    user.username = self.emailTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.emailTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [self navigateToInfoSheet];
        } else {
            if ([error code] == 203) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                message:@"Email you've entered is already being used"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSString *errorMessage = [error localizedDescription];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }
    }];
}

- (void) navigateToInfoSheet {
    PAPLoginInfoSheetViewController *loginInfoSheetController = [[PAPLoginInfoSheetViewController alloc] initWithNibName:@"PAPLoginInfoSheetViewController" bundle:nil];
    [self presentViewController:loginInfoSheetController animated:YES completion:nil];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint scrollPoint;
    
    float offsetValue = 20.0f;
    
    if (self.emailTextField == textField) {
        scrollPoint = CGPointMake(0, self.emailTextView.frame.origin.y - offsetValue);
    } else if (self.passwordTextField == textField) {
        scrollPoint = CGPointMake(0, self.passwordTextView.frame.origin.y - offsetValue);
    } else if (self.confirmPWTextField == textField) {
        scrollPoint = CGPointMake(0, self.confirmPWTextView.frame.origin.y - offsetValue);
    }
    
    [self.mainScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.mainScrollView setContentOffset:CGPointZero animated:YES];
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)privacyButtonAction:(id)sender {
    PAPwebviewViewController *webViewController = [[PAPwebviewViewController alloc] initWithWebsite:@"http://teamstoryapp.com/privacy.html"];
    UINavigationController *postNavController = [[UINavigationController alloc]initWithRootViewController:webViewController];
    postNavController.navigationBarHidden = NO;
    [self presentViewController:postNavController animated:YES completion:nil];
}

- (IBAction)termsButtonAction:(id)sender {
    PAPwebviewViewController *webViewController = [[PAPwebviewViewController alloc] initWithWebsite:@"http://teamstoryapp.com/terms.html"];
    UINavigationController *postNavController = [[UINavigationController alloc]initWithRootViewController:webViewController];
    postNavController.navigationBarHidden = NO;
    [self presentViewController:postNavController animated:YES completion:nil];
}

@end
