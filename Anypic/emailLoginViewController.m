//
//  emailLoginViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 12/12/13.
//
//

#import "emailLoginViewController.h"
#import "PAPLogInViewController.h"
#import "AppDelegate.h"
#import "emailSignUpViewController.h"
#import "PAPProfileSettingViewController.h"
#import "PAPWelcomeViewController.h"

@interface emailLoginViewController ()
@property (nonatomic, strong) PAPWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *pwForgotButton;
@end

@implementation emailLoginViewController

@synthesize emailTextField;
@synthesize pwTextField;
@synthesize welcomeViewController;
@synthesize navController;
@synthesize window;
@synthesize cancelButton;
@synthesize loginButton;
@synthesize pwForgotButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pwForgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_iphone5.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_iphone4.png"]];
        
        emailTextField = [[UITextField alloc] initWithFrame:CGRectMake( 35.0f, 320.0f, 250.0f, 50.0f)];
        pwTextField = [[UITextField alloc] initWithFrame:CGRectMake( 35.0f, 390.0f, 250.0f, 50.0f)];
        [cancelButton setFrame:CGRectMake( 20.0f, self.view.bounds.size.height - 36.0f, 70.0f, 32.0f)];
        [loginButton setFrame:CGRectMake( 236.0f, self.view.bounds.size.height - 36.0f, 52.0f, 32.0f)];
        [pwForgotButton setFrame:CGRectMake( (self.view.bounds.size.width / 2 ) - 38.0f, self.view.bounds.size.height - 36.0f, 80.0f, 32.0f)];
    }
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIColor *color = [UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:0.9];
    
    [emailTextField setBackgroundColor:[UIColor whiteColor]];
    [emailTextField setFont:[UIFont systemFontOfSize:15]];
    emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:@"HelveticaNeue-Thin"}];
    emailTextField.userInteractionEnabled = YES;
    emailTextField.leftView = paddingView;
    emailTextField.leftViewMode = UITextFieldViewModeAlways;
    emailTextField.delegate = self;
    emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [emailTextField resignFirstResponder];
    [self.view addSubview:emailTextField];
    
    [pwTextField setBackgroundColor:[UIColor whiteColor]];
    [pwTextField setFont:[UIFont systemFontOfSize:15]];
    pwTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:@"HelveticaNeue-Thin"}];
    pwTextField.userInteractionEnabled = YES;
    pwTextField.leftView = paddingView2;
    pwTextField.leftViewMode = UITextFieldViewModeAlways;
    pwTextField.delegate = self;
    pwTextField.secureTextEntry = YES;
    pwTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [pwTextField resignFirstResponder];
    [self.view addSubview:pwTextField];
    
    [cancelButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:0.8] forState:UIControlStateNormal];
    [[cancelButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0]];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
    //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:cancelButton];
    
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[loginButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0]];
    [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [loginButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
    //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:loginButton];

    [pwForgotButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:0.8] forState:UIControlStateNormal];
    [[pwForgotButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0]];
    [pwForgotButton setTitle:@"Need Help?" forState:UIControlStateNormal];
    [pwForgotButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [pwForgotButton addTarget:self action:@selector(forgotPasswordAction:) forControlEvents:UIControlEventTouchUpInside];
    //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
    //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:pwForgotButton];

    
    
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
    [emailTextField resignFirstResponder];
    [pwTextField resignFirstResponder];
}


- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    int movementDistance = 210; // tweak as needed
    float movementDuration = 0.3f; // tweak as needed
    
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
    emailSignUpViewController *signUpController = [[emailSignUpViewController alloc] init];
    
    UINavigationController *signUpNav = [[UINavigationController alloc] initWithRootViewController:signUpController];
    signUpNav.navigationBarHidden = YES;
    [self presentViewController:signUpNav animated:YES completion:nil];
    
    //UINavigationController *navigationController = [(AppDelegate*)[[UIApplication sharedApplication] delegate] navController];
    //[navigationController pushViewController:signUpController animated:YES];
    
}

-(void)loginButtonAction:(id)sender {
    [emailTextField resignFirstResponder];
    [pwTextField resignFirstResponder];
    
    NSString *userEmail = self.emailTextField.text;
    NSString *userPW = self.pwTextField.text;
    
    [PFUser logInWithUsernameInBackground:userEmail password:userPW
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {

                                            NSNumber *profileBoolNum = [user objectForKey: @"profileExist"];
                                            bool profileExist = [profileBoolNum boolValue];
                                            
                                            if (profileExist == true) {
                                                NSLog(@"Logged In Sucessfully");
                                                [PFUser user];
                                                [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
                                                return;
                                                
                                            } else {
                                                NSLog(@"Profile Setting page");
                                                
                                                PAPProfileSettingViewController *accountViewController = [[PAPProfileSettingViewController alloc] init];
                                                
                                                UINavigationController *profileSettingNav = [[UINavigationController alloc] initWithRootViewController:accountViewController];
                                                //profileSettingNav.navigationBarHidden = YES;
                                                [self presentViewController:profileSettingNav animated:YES completion:nil];
                                            }
                                            
                                        } else {
                                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wrong Email" message:@"Please check your email address or password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                            alert.alertViewStyle = UIAlertViewStyleDefault;
                                            [alert show];
                                        }
                                    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Return Key Pressed");
    if (textField == emailTextField) {
        [pwTextField becomeFirstResponder];
    } else {
        [pwTextField resignFirstResponder];
    }
    
    return YES;
}


//reset password
-(void)forgotPasswordAction:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password" message:@"Enter your email" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
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
                
                [PFUser requestPasswordResetForEmailInBackground:input block:^(BOOL succeeded, NSError *error) {
                    if (succeeded == TRUE){
                        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Reset Password" message:@"You will receive an email with a link to reset your password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [successAlert show];
                        
                    }else{
                        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Missing User" message:@"No user account is linked to this email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [failureAlert show];
                    }
                }];
            }else{
                
                UIAlertView *notEmailFormat = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Make sure you enter a valid email address" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [notEmailFormat show];
            }
        }
        
        [self dismissKeyboard];
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


@end
