//
//  emailSignUpViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 12/16/13.
//
//

#import "emailSignUpViewController.h"
#import "PAPwebviewViewController.h"
#import "AppDelegate.h"
#import "PAPProfileSettingViewController.h"

#define SUCCESSFUL 1

@interface emailSignUpViewController ()

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *signUpButton;
@property (nonatomic, strong) UIButton *policy;

@end

@implementation emailSignUpViewController

@synthesize signUpEmailTextField;
@synthesize signUpPWTextField;
@synthesize signUpPWTextField_confirm;
@synthesize cancelButton;
@synthesize signUpButton;
@synthesize policy;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    policy = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro.png"]];

    
    UILabel *mainLabel = [[UILabel alloc] init];
    [mainLabel setText:@"Sign up with email"];
    [mainLabel setTextAlignment:NSTextAlignmentCenter];
    [mainLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0f]];
    [mainLabel setTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
    [self.view addSubview:mainLabel];
    
    signUpEmailTextField = [[UITextField alloc] init];
    signUpPWTextField = [[UITextField alloc] init];
    signUpPWTextField_confirm = [[UITextField alloc] init];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    
    [policy setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [policy setBackgroundImage:[UIImage imageNamed:@"privacy.png"] forState:UIControlStateNormal];
    [policy addTarget:self action:@selector(policyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:policy];
    
    [signUpEmailTextField setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
    [signUpEmailTextField setFont:[UIFont systemFontOfSize:13]];
    signUpEmailTextField.placeholder = @"Email";
    signUpEmailTextField.layer.cornerRadius = 1.5f;
    signUpEmailTextField.leftView = paddingView;
    signUpEmailTextField.leftViewMode = UITextFieldViewModeAlways;
    signUpEmailTextField.userInteractionEnabled = YES;
    signUpEmailTextField.delegate = self;
    signUpEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [signUpEmailTextField resignFirstResponder];
    [self.view addSubview:signUpEmailTextField];
    
    [signUpPWTextField setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
    [signUpPWTextField setFont:[UIFont systemFontOfSize:13]];
    //pwTextField.borderStyle = UITextBorderStyleRoundedRect;
    signUpPWTextField.placeholder = @"Password";
    signUpPWTextField.userInteractionEnabled = YES;
    signUpPWTextField.layer.cornerRadius = 1.5f;
    signUpPWTextField.leftView = paddingView2;
    signUpPWTextField.leftViewMode = UITextFieldViewModeAlways;
    signUpPWTextField.delegate = self;
    signUpPWTextField.secureTextEntry = YES;
    signUpPWTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [signUpPWTextField resignFirstResponder];
    [self.view addSubview:signUpPWTextField];
    
    [signUpPWTextField_confirm setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
    [signUpPWTextField_confirm setFont:[UIFont systemFontOfSize:13]];
    //pwTextField.borderStyle = UITextBorderStyleRoundedRect;
    signUpPWTextField_confirm.placeholder = @"Confirm Password";
    signUpPWTextField_confirm.userInteractionEnabled = YES;
    signUpPWTextField_confirm.layer.cornerRadius = 1.5f;
    signUpPWTextField_confirm.delegate = self;
    signUpPWTextField_confirm.leftView = paddingView3;
    signUpPWTextField_confirm.leftViewMode = UITextFieldViewModeAlways;
    signUpPWTextField_confirm.secureTextEntry = YES;
    signUpPWTextField_confirm.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [signUpPWTextField_confirm resignFirstResponder];
    [self.view addSubview:signUpPWTextField_confirm];
    
    
    [signUpButton setBackgroundColor:[UIColor colorWithRed:91.0f/255.0f green:194.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    signUpButton.layer.cornerRadius = 1.5f;
    [[signUpButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    [signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signUpButton addTarget:self action:@selector(signUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUpButton];
    
    UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(35.0f, [UIScreen mainScreen].bounds.size.height - 50.0f, 50.0f, 15.0f)];
    [back_button setBackgroundImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
    [back_button addTarget:self action:@selector(back_button_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back_button];
    
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        signUpEmailTextField.frame = CGRectMake( 35.0f, self.view.bounds.size.height - 385.0f, 250.0f, 45.0f);
        signUpPWTextField.frame = CGRectMake( 35.0f, self.view.bounds.size.height - 330.0f, 250.0f, 45.0f);
        signUpPWTextField_confirm.frame = CGRectMake( 35.0f, self.view.bounds.size.height - 275.0f, 250.0f, 45.0f);
        [signUpButton setFrame:CGRectMake( 35.0f, self.view.bounds.size.height - 220.0f, 250.0f, 45.0f)];
        [policy setFrame:CGRectMake(35.0f, self.view.bounds.size.height - 130.0f, 252.0f, 23.0f)];
        mainLabel.frame = CGRectMake(0.0f, 100.0f, 320.0f, 30.0f);
    } else {
        signUpEmailTextField.frame = CGRectMake( 35.0f, self.view.bounds.size.height - 355.0f, 250.0f, 45.0f);
        signUpPWTextField.frame = CGRectMake( 35.0f, self.view.bounds.size.height - 300.0f, 250.0f, 45.0f);
        signUpPWTextField_confirm.frame = CGRectMake( 35.0f, self.view.bounds.size.height - 245.0f, 250.0f, 45.0f);
        [signUpButton setFrame:CGRectMake( 35.0f, self.view.bounds.size.height - 190.0f, 250.0f, 45.0f)];
        [policy setFrame:CGRectMake(35.0f, self.view.bounds.size.height - 105.0f, 252.0f, 23.0f)];
        mainLabel.frame = CGRectMake(0.0f, 60.0f, 320.0f, 30.0f);
    }
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // If there is text in the text field
    if (textField.text.length + (string.length - range.length) > 0) {
        // Set textfield font
        textField.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    } else {
        // Set textfield placeholder font (or so it appears)
        textField.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    }
    
    return YES;
}


-(void)dismissKeyboard {
    [signUpEmailTextField resignFirstResponder];
    [signUpPWTextField resignFirstResponder];
    [signUpPWTextField_confirm resignFirstResponder];

}


- (void)back_button_action:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    int movementDistance = 0; // tweak as needed
    float movementDuration = 0.3f; // tweak as needed
    
    if (textField == signUpEmailTextField) {
        movementDistance = 100; // tweak as needed
    }
    else if (textField == signUpPWTextField) {
        movementDistance = 100; // tweak as needed
    }
    else if (textField == signUpPWTextField_confirm) {
        movementDistance = 100; // tweak as needed
    }
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField: textField up: NO];
}

- (void)policyButtonAction:(id)sender {
    PAPwebviewViewController *webViewController = [[PAPwebviewViewController alloc] initWithWebsite:@"http://teamstoryapp.com/privacy"];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:webViewController animated:YES];
}

-(void)signUpButtonAction:(id)sender {
    [SVProgressHUD show];
    NSString *userNewEmail = self.signUpEmailTextField.text;
    NSString *userPW = self.signUpPWTextField.text;
    NSString *userPW_confirm = self.signUpPWTextField_confirm.text;
    
    NSLog(@"%@", userNewEmail);
    NSLog(@"%@", userPW);
    NSLog(@"%@", userPW_confirm);
    
    if (userNewEmail.length > 0 || userPW.length > 0 || userPW_confirm.length > 0) {
        if ([userPW isEqualToString:userPW_confirm]) {
            PFUser *user = [PFUser user];
            user.username = userNewEmail;
            user[@"email"] = userNewEmail;
            user.password = userPW;
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [SVProgressHUD dismiss];
                    // Hooray! Let them use the app now.
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Signed Up Successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.tag = SUCCESSFUL;
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                } else {
                    [SVProgressHUD dismiss];
                    NSString *errorString = [error userInfo][@"error"];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Password and confirmation password don't match!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
    } else {
        [SVProgressHUD dismiss];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out all the fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Return Key Pressed");
    if (textField == signUpEmailTextField) {
        [signUpPWTextField becomeFirstResponder];
    } else if (textField == signUpPWTextField) {
        [signUpPWTextField_confirm becomeFirstResponder];
    } else {
        [signUpPWTextField_confirm resignFirstResponder];
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SUCCESSFUL) {
        if (buttonIndex == 0) {
            PAPProfileSettingViewController *profileSettingsViewController = [[PAPProfileSettingViewController alloc] init];
            [self.navigationController pushViewController:profileSettingsViewController animated:YES];
        }
    }
}

@end
