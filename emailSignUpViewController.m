//
//  emailSignUpViewController.m
//  Anypic
//
//  Created by Tobok Lee on 12/16/13.
//
//

#import "emailSignUpViewController.h"
#define SUCCESSFUL 1

@interface emailSignUpViewController ()

@end

@implementation emailSignUpViewController

@synthesize signUpEmailTextField;
@synthesize signUpPWTextField;
@synthesize signUpPWTextField_confirm;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro2-iphone5.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro2-iphone4.png"]];
        
        CGRect signUpEmailTextField_frame = CGRectMake( 55.0f, 200.0f, 220.0f, 40.0f);
        signUpEmailTextField = [[UITextField alloc] initWithFrame:signUpEmailTextField_frame];
        [signUpEmailTextField setBackgroundColor:[UIColor whiteColor]];
        [signUpEmailTextField setFont:[UIFont systemFontOfSize:13]];
        //emailTextField.borderStyle = UITextBorderStyleRoundedRect;
        signUpEmailTextField.placeholder = @"Email";
        signUpEmailTextField.userInteractionEnabled = YES;
        signUpEmailTextField.delegate = self;
        signUpEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
        [signUpEmailTextField resignFirstResponder];
        [self.view addSubview:signUpEmailTextField];
        
        CGRect signUpPWTextField_frame = CGRectMake( 55.0f, 300.0f, 220.0f, 40.0f);
        signUpPWTextField = [[UITextField alloc] initWithFrame:signUpPWTextField_frame];
        [signUpPWTextField setBackgroundColor:[UIColor whiteColor]];
        [signUpPWTextField setFont:[UIFont systemFontOfSize:13]];
        //pwTextField.borderStyle = UITextBorderStyleRoundedRect;
        signUpPWTextField.placeholder = @"Password";
        signUpPWTextField.userInteractionEnabled = YES;
        signUpPWTextField.delegate = self;
        signUpPWTextField.secureTextEntry = YES;
        signUpPWTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
        [signUpPWTextField resignFirstResponder];
        [self.view addSubview:signUpPWTextField];
        
        CGRect signUpPWTextField_confirm_frame = CGRectMake( 55.0f, 400.0f, 220.0f, 40.0f);
        signUpPWTextField_confirm = [[UITextField alloc] initWithFrame:signUpPWTextField_confirm_frame];
        [signUpPWTextField_confirm setBackgroundColor:[UIColor whiteColor]];
        [signUpPWTextField_confirm setFont:[UIFont systemFontOfSize:13]];
        //pwTextField.borderStyle = UITextBorderStyleRoundedRect;
        signUpPWTextField_confirm.placeholder = @"Confirm Password";
        signUpPWTextField_confirm.userInteractionEnabled = YES;
        signUpPWTextField_confirm.delegate = self;
        signUpPWTextField_confirm.secureTextEntry = YES;
        signUpPWTextField_confirm.autocapitalizationType = UITextAutocapitalizationTypeNone;
        //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
        [signUpPWTextField_confirm resignFirstResponder];
        [self.view addSubview:signUpPWTextField_confirm];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectMake( 10.0f, self.view.bounds.size.height - 33.0f, 52.0f, 32.0f)];
        [cancelButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:0.7] forState:UIControlStateNormal];
        [[cancelButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
        [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
        //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
        [self.view addSubview:cancelButton];
        
        UIButton *signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [signUpButton setFrame:CGRectMake( self.view.bounds.size.width - 60.0f, self.view.bounds.size.height - 33.0f, 52.0f, 32.0f)];
        [signUpButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:0.7] forState:UIControlStateNormal];
        [[signUpButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
        [signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [signUpButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
        [signUpButton addTarget:self action:@selector(signUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
        //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
        [self.view addSubview:signUpButton];
        
        UIImageView *logo = [[UIImageView alloc] initWithImage:nil];
        [logo setImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
        [logo setFrame:CGRectMake(40.0f, 50.0f, 260.0f, 60.0f)];
        [self.view addSubview:logo];
        
        
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


- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    int movementDistance = 0; // tweak as needed
    float movementDuration = 0.3f; // tweak as needed
    
    if (textField == signUpEmailTextField) {
        movementDistance = 0; // tweak as needed
    }
    else if (textField == signUpPWTextField) {
        movementDistance = 100; // tweak as needed
    }
    else if (textField == signUpPWTextField_confirm) {
        movementDistance = 180; // tweak as needed
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
        [signUpEmailTextField resignFirstResponder];
    } else if (textField == signUpPWTextField) {
        [signUpPWTextField resignFirstResponder];
    } else {
        [signUpPWTextField_confirm resignFirstResponder];
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SUCCESSFUL) {
        if (buttonIndex == 0) {
            [self.parentViewController dismissModalViewControllerAnimated:YES];
        }
    }
}

@end
