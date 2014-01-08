//
//  emailLoginViewController.m
//  Anypic
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
@end

@implementation emailLoginViewController

@synthesize emailTextField;
@synthesize pwTextField;
@synthesize welcomeViewController;
@synthesize navController;
@synthesize window;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro2-iphone5.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro2-iphone4.png"]];
        
        CGRect emailTextField_frame = CGRectMake( 55.0f, 340.0f, 220.0f, 40.0f);
        emailTextField = [[UITextField alloc] initWithFrame:emailTextField_frame];
        [emailTextField setBackgroundColor:[UIColor whiteColor]];
        [emailTextField setFont:[UIFont systemFontOfSize:13]];
        //emailTextField.borderStyle = UITextBorderStyleRoundedRect;
        emailTextField.placeholder = @"Email";
        emailTextField.userInteractionEnabled = YES;
        emailTextField.delegate = self;
        emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
        [emailTextField resignFirstResponder];
        [self.view addSubview:emailTextField];
        
        CGRect pwTextField_frame = CGRectMake( 55.0f, 400.0f, 220.0f, 40.0f);
        pwTextField = [[UITextField alloc] initWithFrame:pwTextField_frame];
        [pwTextField setBackgroundColor:[UIColor whiteColor]];
        [pwTextField setFont:[UIFont systemFontOfSize:13]];
        //pwTextField.borderStyle = UITextBorderStyleRoundedRect;
        pwTextField.placeholder = @"Password";
        pwTextField.userInteractionEnabled = YES;
        pwTextField.delegate = self;
        pwTextField.secureTextEntry = YES;
        pwTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
        [pwTextField resignFirstResponder];
        [self.view addSubview:pwTextField];
        
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
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton setFrame:CGRectMake( self.view.bounds.size.width - 60.0f, self.view.bounds.size.height - 33.0f, 52.0f, 32.0f)];
        [loginButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:0.7] forState:UIControlStateNormal];
        [[loginButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
        [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
        [loginButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
        [loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
        //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
        [self.view addSubview:loginButton];
        
        /*
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
         */
        
        UIButton *pwForgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pwForgotButton setFrame:CGRectMake( (self.view.bounds.size.width / 2 ) - 90.0f, self.view.bounds.size.height - 33.0f, 200.0f, 32.0f)];
        [pwForgotButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:0.7] forState:UIControlStateNormal];
        [[pwForgotButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
        [pwForgotButton setTitle:@"Forgot Your Password?" forState:UIControlStateNormal];
        [pwForgotButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
        [pwForgotButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
        //[cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
        [self.view addSubview:pwForgotButton];
        
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
    [emailTextField resignFirstResponder];
    [pwTextField resignFirstResponder];
}


- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
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
    [self presentModalViewController:signUpNav animated:YES];
    
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
                                                [self presentModalViewController:profileSettingNav animated:YES];
                                            }
                                            
                                        } else {
                                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please check your email address or password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                            alert.alertViewStyle = UIAlertViewStyleDefault;
                                            [alert show];
                                        }
                                    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Return Key Pressed");
    if (textField == emailTextField) {
        [emailTextField resignFirstResponder];
    } else {
        [pwTextField resignFirstResponder];
    }
    
    return YES;
}




@end
