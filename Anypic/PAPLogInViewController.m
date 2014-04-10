//
//  PAPLogInViewController.m
//  Teamstory
//
//

#import "PAPLogInViewController.h"
#import "emailLoginViewController.h"
#import "AppDelegate.h"
#import "emailSignUpViewController.h"
#import "SVProgressHUD.h"
#import "PAPprofileApprovalViewController.h"
#import "PAPProfileSettingViewController.h"

@interface PAPLogInViewController()
@property (nonatomic, strong) UITextField *user_email;
@property (nonatomic, strong) UITextField *user_pw;
@property (nonatomic, strong) NSString *login_type;

@end

@implementation PAPLogInViewController
@synthesize emailLoginNavController;
@synthesize user_email;
@synthesize user_pw;
@synthesize login_type;



- (id)initWithLoginType:(NSString *)loginType{
    self = [super init];
    if (self) {
        self.login_type = loginType;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro.png"]];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIColor *color = [UIColor colorWithRed:134.0f/255.0f green:134.0f/255.0f blue:134.0f/255.0f alpha:1.0f];
    
    if ([self.login_type isEqualToString:@"signIn"]) {
        user_email = [[UITextField alloc] init];
        user_email.layer.cornerRadius = 1.5f;
        user_email.leftView = paddingView;
        [user_email setFont:[UIFont systemFontOfSize:15]];
        user_email.leftViewMode = UITextFieldViewModeAlways;
        user_email.delegate = self;
        user_email.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [user_email setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
        user_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:@"HelveticaNeue-Thin"}];
        [self.logInView addSubview:user_email];
        
        user_pw = [[UITextField alloc] init];
        user_pw.layer.cornerRadius = 1.5f;
        user_pw.placeholder = @"Password";
        [user_pw setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
        [user_pw setFont:[UIFont systemFontOfSize:15]];
        user_pw.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:@"HelveticaNeue-Thin"}];
        user_pw.userInteractionEnabled = YES;
        user_pw.leftView = paddingView2;
        user_pw.returnKeyType = UIReturnKeyNext;
        user_pw.leftViewMode = UITextFieldViewModeAlways;
        user_pw.delegate = self;
        user_pw.secureTextEntry = YES;
        [user_pw resignFirstResponder];
        [self.logInView addSubview:user_pw];
        
        UIButton *forgotSomething = [[UIButton alloc] init];
        [forgotSomething setTitle:@"Forgot Something?" forState:UIControlStateNormal];
        [[forgotSomething titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0f]];
        [forgotSomething addTarget:self action:@selector(forgotSomethingAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.logInView addSubview:forgotSomething];
        
        if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
            forgotSomething.frame = CGRectMake(85.0f, [UIScreen mainScreen].bounds.size.height - 140.0f, 150.0f, 15.0f);
            user_pw.frame = CGRectMake(35.0f, 365.0f, 250.0f, 45.0f);
            user_email.frame = CGRectMake(35.0f, 310.0f, 250.0f, 45.0f);
        } else {
            forgotSomething.frame = CGRectMake(85.0f, [UIScreen mainScreen].bounds.size.height - 120.0f, 150.0f, 15.0f);
            user_pw.frame = CGRectMake(35.0f, 300.0f, 250.0f, 45.0f);
            user_email.frame = CGRectMake(35.0f, 245.0f, 250.0f, 45.0f);
        }
    } else {
        UIButton *emailSignIn = [[UIButton alloc] initWithFrame:CGRectMake(187.0f, [UIScreen mainScreen].bounds.size.height - 220.0f, 50.0f, 20.0f)];
        [emailSignIn setTitle:@"email." forState:UIControlStateNormal];
        [[emailSignIn titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
        [emailSignIn addTarget:self action:@selector(emailSignIn_button:) forControlEvents:UIControlEventTouchUpInside];
        [self.logInView addSubview:emailSignIn];
        
        UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, [UIScreen mainScreen].bounds.size.height - 220.0f, 125.0f, 20.0f)];
        [emailLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0f]];
        [emailLabel setText:@"or join using your"];
        [emailLabel setTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
        [self.logInView addSubview:emailLabel];
    }
    
    UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(35.0f, [UIScreen mainScreen].bounds.size.height - 50.0f, 50.0f, 15.0f)];
    [back_button setBackgroundImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
    [back_button addTarget:self action:@selector(back_button_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.logInView addSubview:back_button];

    [self.logInView setLogo:nil];
    
    self.fields = PFLogInFieldsUsernameAndPassword;
    self.logInView.usernameField.placeholder = @"Enter your email";
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        [self.logInView.facebookButton setFrame:CGRectMake(35.0f, 157.0f, 110.0f, 110.0f)];
        [self.logInView.twitterButton setFrame:CGRectMake(175.5, 157.0f, 110.0f, 110.0f)];
    } else {
        [self.logInView.facebookButton setFrame:CGRectMake(35.5f, 100.0f, 110.0f, 110.0f)];
        [self.logInView.twitterButton setFrame:CGRectMake(175.5, 100.0f, 110.0f, 110.0f)];
    }
    
    [self.logInView.facebookButton setTitle:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"icon-fblogin.png"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"icon-fblogin.png"] forState:UIControlStateHighlighted];
    
    [self.logInView.twitterButton setTitle:nil forState:UIControlStateNormal];
    [self.logInView.twitterButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"icon-twitterlogin.png"] forState:UIControlStateNormal];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"icon-twitterlogin.png"] forState:UIControlStateHighlighted];
    
}

- (void)emailSignIn_button:(id)sender{
    emailSignUpViewController *emailSignUpViewCtrl = [[emailSignUpViewController alloc] init];
    [self.navigationController pushViewController:emailSignUpViewCtrl animated:YES];
}

- (void)forgotSomethingAction:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password" message:@"Enter your email" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)back_button_action:(id)sender{
    NSLog(@"%@", self.navigationController);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dismissKeyboard {
    [user_pw resignFirstResponder];
    [user_email resignFirstResponder];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    int movementDistance = 130; // tweak as needed
    float movementDuration = 0.2f; // tweak as needed
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == user_email) {
        [user_pw becomeFirstResponder];
    } else {
        
        [SVProgressHUD show];
        
        [user_pw resignFirstResponder];
        [user_email resignFirstResponder];
        
        NSString *userEmail = self.user_email.text;
        NSString *userPW = self.user_pw.text;
        
        if ([(AppDelegate*)[[UIApplication sharedApplication] delegate] isParseReachable]) {
            [PFUser logInWithUsernameInBackground:userEmail password:userPW
                                            block:^(PFUser *user, NSError *error) {
                                                if (user) {
                                              //      [user refresh];
                                                    NSNumber *profileBoolNum = [user objectForKey: @"profileExist"];
                                                    bool profileExist = [profileBoolNum boolValue];
                                                    
                                                    NSNumber *accessGrantNum = [user objectForKey: @"accessGrant"];
                                                    bool accessGrant = [accessGrantNum boolValue];
                                                    
                                                    if (profileExist == true && accessGrant == true) {
                                                        NSLog(@"Logged In Sucessfully");
                                                        [SVProgressHUD dismiss];
                                                        [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
                                                        return;
                                                        
                                                    } else if (profileExist == true && accessGrant != true){
                                                        PAPprofileApprovalViewController *approvalViewController = [[PAPprofileApprovalViewController alloc] init];
                                                        [self.navigationController pushViewController:approvalViewController animated:YES];
                                                    } else if (profileExist != true) {
                                                        PAPProfileSettingViewController *profileSettingsViewController = [[PAPProfileSettingViewController alloc] init];
                                                        [self.navigationController pushViewController:profileSettingsViewController animated:YES];
                                                    }
                                                    
                                                } else {
                                                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wrong Email" message:@"Please check your email address or password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                    alert.alertViewStyle = UIAlertViewStyleDefault;
                                                    [alert show];
                                                    [SVProgressHUD dismiss];
                                                }
                                            }];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
    }
    return YES;
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
