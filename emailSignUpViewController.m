//
//  emailSignUpViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 12/16/13.
//
//

#import "emailSignUpViewController.h"
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
    
    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"register_iphone5.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"register_iphone4.png"]];
    }
    
    signUpEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake( 35.0f, self.view.bounds.size.height - 280.0f, 250.0f, 50.0f)];
    signUpPWTextField = [[UITextField alloc] initWithFrame:CGRectMake( 35.0f, self.view.bounds.size.height - 210.0f, 250.0f, 50.0f)];
    signUpPWTextField_confirm = [[UITextField alloc] initWithFrame:CGRectMake( 35.0f, self.view.bounds.size.height - 140.0f, 250.0f, 50.0f)];
    [cancelButton setFrame:CGRectMake( 29.0f, self.view.bounds.size.height - 75.0f, 52.0f, 32.0f)];
    [signUpButton setFrame:CGRectMake( self.view.bounds.size.width - 99.0f, self.view.bounds.size.height - 75.0f, 70.0f, 32.0f)];
    [policy setFrame:CGRectMake(35.0f, self.view.bounds.size.height - 40.0f, 252.0f, 23.0f)];

    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    
    [policy setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [policy setBackgroundImage:[UIImage imageNamed:@"privacy.png"] forState:UIControlStateNormal];
    [policy addTarget:self action:@selector(policyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:policy];
    
    [signUpEmailTextField setBackgroundColor:[UIColor whiteColor]];
    [signUpEmailTextField setFont:[UIFont systemFontOfSize:13]];
    //emailTextField.borderStyle = UITextBorderStyleRoundedRect;
    signUpEmailTextField.placeholder = @"Email";
    signUpEmailTextField.leftView = paddingView;
    signUpEmailTextField.leftViewMode = UITextFieldViewModeAlways;
    signUpEmailTextField.userInteractionEnabled = YES;
    signUpEmailTextField.delegate = self;
    signUpEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [signUpEmailTextField resignFirstResponder];
    [self.view addSubview:signUpEmailTextField];
    
    [signUpPWTextField setBackgroundColor:[UIColor whiteColor]];
    [signUpPWTextField setFont:[UIFont systemFontOfSize:13]];
    //pwTextField.borderStyle = UITextBorderStyleRoundedRect;
    signUpPWTextField.placeholder = @"Password";
    signUpPWTextField.userInteractionEnabled = YES;
    signUpPWTextField.leftView = paddingView2;
    signUpPWTextField.leftViewMode = UITextFieldViewModeAlways;
    signUpPWTextField.delegate = self;
    signUpPWTextField.secureTextEntry = YES;
    signUpPWTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [signUpPWTextField resignFirstResponder];
    [self.view addSubview:signUpPWTextField];
    
    [signUpPWTextField_confirm setBackgroundColor:[UIColor whiteColor]];
    [signUpPWTextField_confirm setFont:[UIFont systemFontOfSize:13]];
    //pwTextField.borderStyle = UITextBorderStyleRoundedRect;
    signUpPWTextField_confirm.placeholder = @"Confirm Password";
    signUpPWTextField_confirm.userInteractionEnabled = YES;
    signUpPWTextField_confirm.delegate = self;
    signUpPWTextField_confirm.leftView = paddingView3;
    signUpPWTextField_confirm.leftViewMode = UITextFieldViewModeAlways;
    signUpPWTextField_confirm.secureTextEntry = YES;
    signUpPWTextField_confirm.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [signUpPWTextField_confirm resignFirstResponder];
    [self.view addSubview:signUpPWTextField_confirm];
    
    [cancelButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:0.7] forState:UIControlStateNormal];
    [[cancelButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0]];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[signUpButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0]];
    [signUpButton setTitle:@"Register" forState:UIControlStateNormal];
    [signUpButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [signUpButton addTarget:self action:@selector(signUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUpButton];
    
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


- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    int movementDistance = 0; // tweak as needed
    float movementDuration = 0.3f; // tweak as needed
    
    if (textField == signUpEmailTextField) {
        movementDistance = 170; // tweak as needed
    }
    else if (textField == signUpPWTextField) {
        movementDistance = 170; // tweak as needed
    }
    else if (textField == signUpPWTextField_confirm) {
        movementDistance = 170; // tweak as needed
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
    
}

-(void)signUpButtonAction:(id)sender {
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
                    // Hooray! Let them use the app now.
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Signed Up Successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.tag = SUCCESSFUL;
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                } else {
                    NSString *errorString = [error userInfo][@"error"];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                }
            }];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Password and confirmation password don't match!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
    } else {
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
        [signUpPWTextField_confirm becomeFirstResponder];
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SUCCESSFUL) {
        if (buttonIndex == 0) {
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
