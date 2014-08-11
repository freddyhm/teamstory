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
#import "PAPprofileSetupViewController.h"

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"intro_bg.png"]];

    
    UIImage *signUpImage = [UIImage imageNamed:@"signup.png"];
    UIImageView *signUpIV = [[UIImageView alloc] initWithFrame:CGRectMake(160.0f - signUpImage.size.width / 2, 100.0f, signUpImage.size.width, signUpImage.size.height)];
    [signUpIV setImage:signUpImage];
    [self.view addSubview:signUpIV];
    
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
    
    UIFont *defaultFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0f];
    UIColor *color = [UIColor colorWithRed:134.0f/255.0f green:134.0f/255.0f blue:134.0f/255.0f alpha:1.0f];
    
    [signUpEmailTextField setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
    [signUpEmailTextField setFont:[UIFont systemFontOfSize:15]];
    signUpEmailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:defaultFont}];
    signUpEmailTextField.layer.cornerRadius = 1.5f;
    signUpEmailTextField.leftView = paddingView;
    signUpEmailTextField.leftViewMode = UITextFieldViewModeAlways;
    signUpEmailTextField.userInteractionEnabled = YES;
    signUpEmailTextField.delegate = self;
    signUpEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [signUpEmailTextField resignFirstResponder];
    [self.view addSubview:signUpEmailTextField];
    
    [signUpPWTextField setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
    [signUpPWTextField setFont:[UIFont systemFontOfSize:15]];
    //pwTextField.borderStyle = UITextBorderStyleRoundedRect;
    signUpPWTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:defaultFont}];
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
    
    [signUpPWTextField_confirm setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
    [signUpPWTextField_confirm setFont:[UIFont systemFontOfSize:15]];
    //pwTextField.borderStyle = UITextBorderStyleRoundedRect;
    signUpPWTextField_confirm.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password Confirm" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:defaultFont}];
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
    [signUpButton addTarget:self action:@selector(chagneBGcolor:) forControlEvents:UIControlEventTouchDown];
    [signUpButton addTarget:self action:@selector(signUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUpButton];
    
    UIImage *back_buttonImage = [UIImage imageNamed:@"btn-back.png"];
    UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(15.0f, 30.0f, back_buttonImage.size.width, back_buttonImage.size.height)];
    [back_button setBackgroundImage:back_buttonImage forState:UIControlStateNormal];
    [back_button addTarget:self action:@selector(back_button_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back_button];
    
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        signUpEmailTextField.frame = CGRectMake( 15.0f, self.view.bounds.size.height - 350.0f, 290.0f, 50.0f);
        signUpPWTextField.frame = CGRectMake( 15.0f, self.view.bounds.size.height - 290.0f, 290.0f, 50.0f);
        signUpPWTextField_confirm.frame = CGRectMake( 15.0f, self.view.bounds.size.height - 230.0f, 290.0f, 50.0f);
        [signUpButton setFrame:CGRectMake( 15.0f, self.view.bounds.size.height - 170.0f, 290.0f, 50.0f)];
        [policy setFrame:CGRectMake(35.0f, self.view.bounds.size.height - 75.0f, 252.0f, 23.0f)];
    } else {
        signUpEmailTextField.frame = CGRectMake( 35.0f, self.view.bounds.size.height - 330.0f, 250.0f, 45.0f);
        signUpPWTextField.frame = CGRectMake( 35.0f, self.view.bounds.size.height - 275.0f, 250.0f, 45.0f);
        signUpPWTextField_confirm.frame = CGRectMake( 35.0f, self.view.bounds.size.height - 220.0f, 250.0f, 45.0f);
        [signUpButton setFrame:CGRectMake( 35.0f, self.view.bounds.size.height - 165.0f, 250.0f, 45.0f)];
        [policy setFrame:CGRectMake(35.0f, self.view.bounds.size.height - 80.0f, 252.0f, 23.0f)];
    }
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
}


-(void)dismissKeyboard {
    [signUpEmailTextField resignFirstResponder];
    [signUpPWTextField resignFirstResponder];
    [signUpPWTextField_confirm resignFirstResponder];

}

-(void)chagneBGcolor:(id) sender {
    signUpButton.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:164.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
}


- (void)back_button_action:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    float offset;
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        offset  = 50.0f;
    } else {
        offset = 0.0f;
    }
    int movementDistance = 0; // tweak as needed
    float movementDuration = 0.3f; // tweak as needed
    
    if (textField == signUpEmailTextField) {
        movementDistance = 180 - offset; // tweak as needed
    }
    else if (textField == signUpPWTextField) {
        movementDistance = 180 - offset; // tweak as needed
    }
    else if (textField == signUpPWTextField_confirm) {
        movementDistance = 180 - offset; // tweak as needed
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
    [signUpButton setBackgroundColor:[UIColor colorWithRed:91.0f/255.0f green:194.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
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
                [SVProgressHUD dismiss];
                
                if (!error) {
                    // Hooray! Let them use the app now.
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Successful" message:@"Your email has been registered" delegate:self cancelButtonTitle:@"Next" otherButtonTitles:nil, nil];
                    alert.tag = SUCCESSFUL;
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                } else {
                    NSDictionary *userInfo = [error userInfo];
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Password and confirmation password don't match!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
    } else {
        [SVProgressHUD dismiss];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out all the fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
            PAPprofileSetupViewController *profileSetupViewController = [[PAPprofileSetupViewController alloc] init];
            [self.navigationController pushViewController:profileSetupViewController animated:YES];
        }
    }
}

@end
