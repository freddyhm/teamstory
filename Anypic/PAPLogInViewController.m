//
//  PAPLogInViewController.m
//  Teamstory
//
//

#import "PAPLogInViewController.h"
#import "AppDelegate.h"
#import "emailSignUpViewController.h"
#import "SVProgressHUD.h"
#import "PAPprofileSetupViewController.h"
#import "Mixpanel.h"
//#import "FlightRecorder.h"

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"intro_bg.png"]];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIColor *color = [UIColor colorWithRed:134.0f/255.0f green:134.0f/255.0f blue:134.0f/255.0f alpha:1.0f];
    
    if ([self.login_type isEqualToString:@"signIn"]) {
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Sign In"}];
        
        // flightrecorder event analytics
     //   [[FlightRecorder sharedInstance] trackEventWithCategory:@"sign_in_screen" action:@"viewing_sign_in" label:@"" value:@""];

        
        // flightrecorder analytics
    //    [[FlightRecorder sharedInstance] trackPageView:@"Sign In"];
        
        UIImage *dividerImage = [UIImage imageNamed:@"intro_divider.png"];
        UIImageView *divider = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, [UIScreen mainScreen].bounds.size.height - 190.0f, dividerImage.size.width, dividerImage.size.height)];
        divider.image = dividerImage;
        [self.logInView addSubview:divider];
        
        UIFont *defaultFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0f];
        user_email = [[UITextField alloc] init];
        user_email.layer.cornerRadius = 1.5f;
        user_email.leftView = paddingView;
        [user_email setFont:[UIFont systemFontOfSize:15]];
        user_email.leftViewMode = UITextFieldViewModeAlways;
        user_email.delegate = self;
        user_email.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [user_email setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
        user_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:defaultFont}];
        [self.logInView addSubview:user_email];
        
        user_pw = [[UITextField alloc] init];
        user_pw.layer.cornerRadius = 1.5f;
        user_pw.placeholder = @"Password";
        [user_pw setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
        [user_pw setFont:[UIFont systemFontOfSize:15]];
        user_pw.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:defaultFont}];
        user_pw.userInteractionEnabled = YES;
        user_pw.leftView = paddingView2;
        user_pw.returnKeyType = UIReturnKeyNext;
        user_pw.leftViewMode = UITextFieldViewModeAlways;
        user_pw.delegate = self;
        user_pw.secureTextEntry = YES;
        [user_pw resignFirstResponder];
        [self.logInView addSubview:user_pw];
        
        UIButton *forgotSomething = [[UIButton alloc] init];
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont boldSystemFontOfSize:12.0f], NSFontAttributeName,
                               [UIColor whiteColor], NSForegroundColorAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont systemFontOfSize:12.0f], NSFontAttributeName,
                                  [UIColor whiteColor], NSForegroundColorAttributeName,nil];
        const NSRange range = NSMakeRange(0, 17);
        
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:@"Forgot Something? Reset your password"
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:range];
        
        [forgotSomething setAttributedTitle:attributedText forState:UIControlStateNormal];
        [forgotSomething addTarget:self action:@selector(forgotSomethingAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.logInView addSubview:forgotSomething];
        
        float screenOffset;
        if ([UIScreen mainScreen].bounds.size.height == 480) {
            screenOffset = 0.0f;
        } else {
            screenOffset = 50.0f;
        }
        
        UIImage *logoViewImage = [UIImage imageNamed:@"welcome_back.png"];
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(160.0f - logoViewImage.size.width / 2, 100.0f + screenOffset, logoViewImage.size.width, logoViewImage.size.height)];
        logoView.image = logoViewImage;
        [self.logInView addSubview:logoView];
        
        forgotSomething.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 45.0f, 320.0f, 15.0f);
        user_pw.frame = CGRectMake(15.0f, [UIScreen mainScreen].bounds.size.height - 110.0f, 290.0f, 50.0f);
        user_email.frame = CGRectMake(15.0f, [UIScreen mainScreen].bounds.size.height - 170.0f, 290.0f, 50.0f);
    } else {
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Register"}];
        
        // flightrecorder event analytics
       // [[FlightRecorder sharedInstance] trackEventWithCategory:@"register_screen" action:@"viewing_register" label:@"" value:@""];
        
        // flightrecorder analytics
      //  [[FlightRecorder sharedInstance] trackPageView:@"Register"];
        
        float screenOffset;
        if ([UIScreen mainScreen].bounds.size.height == 480) {
            screenOffset = 0.0f;
        } else {
            screenOffset = 30.0f;
        }
        
        UIImage *emailButton = [UIImage imageNamed:@"btn_email.png"];
        UIButton *emailSignIn = [[UIButton alloc] initWithFrame:CGRectMake(15.0f, [UIScreen mainScreen].bounds.size.height - (emailButton.size.height + 15.0f), emailButton.size.width, emailButton.size.height)];
        [emailSignIn setBackgroundImage:[UIImage imageNamed:@"btn_email.png"] forState:UIControlStateNormal];
        [emailSignIn setBackgroundImage:[UIImage imageNamed:@"btn_email_select.png"] forState:UIControlStateSelected];
        [emailSignIn addTarget:self action:@selector(emailSignIn_button:) forControlEvents:UIControlEventTouchUpInside];
        [self.logInView addSubview:emailSignIn];
        
        UIImage *logoViewImage = [UIImage imageNamed:@"join_teamstory.png"];
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(160.0f - logoViewImage.size.width / 2, 170.0f + screenOffset, logoViewImage.size.width, logoViewImage.size.height)];
        logoView.image = logoViewImage;
        [self.logInView addSubview:logoView];
    }
    
    UIImage *back_buttonImage = [UIImage imageNamed:@"btn-back.png"];
    UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(15.0f, 30.0f, back_buttonImage.size.width, back_buttonImage.size.height)];
    [back_button setImage:back_buttonImage forState:UIControlStateNormal];
    [back_button addTarget:self action:@selector(back_button_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.logInView addSubview:back_button];

    [self.logInView setLogo:nil];
    
    //self.fields = PFLogInFieldsUsernameAndPassword;
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
    
    UIImage *facebookButton = [UIImage imageNamed:@"btn_facebook.png"];
    UIImage *twitterButton = [UIImage imageNamed:@"btn_twitter.png"];
    UIImage *emailButton = [UIImage imageNamed:@"btn_email.png"];
    
    if ([self.login_type isEqualToString:@"signIn"]) {
        [self.logInView.facebookButton setFrame:CGRectMake(15.0f, [UIScreen mainScreen].bounds.size.height - (facebookButton.size.height + 205.0f), facebookButton.size.width, facebookButton.size.height)];
        [self.logInView.twitterButton setFrame:CGRectMake(165.5, [UIScreen mainScreen].bounds.size.height - (twitterButton.size.height + 205.0f), facebookButton.size.width, facebookButton.size.height)];
    } else {
        [self.logInView.facebookButton setFrame:CGRectMake(15.0f, [UIScreen mainScreen].bounds.size.height - (facebookButton.size.height + 25.0f + emailButton.size.height), facebookButton.size.width, facebookButton.size.height)];
        [self.logInView.twitterButton setFrame:CGRectMake(165.5, [UIScreen mainScreen].bounds.size.height - (twitterButton.size.height + 25.0f + emailButton.size.height), facebookButton.size.width, facebookButton.size.height)];
    }
    
    [self.logInView.facebookButton setTitle:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setBackgroundImage:facebookButton forState:UIControlStateNormal];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"btn_facebook_select.png"] forState:UIControlStateHighlighted];
    
    [self.logInView.twitterButton setTitle:nil forState:UIControlStateNormal];
    [self.logInView.twitterButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.twitterButton setBackgroundImage:twitterButton forState:UIControlStateNormal];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"btn_twitter_select.png"] forState:UIControlStateHighlighted];
    
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
    int movementDistance = 200; // tweak as needed
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
                                                    NSNumber *profileBoolNum = [user objectForKey: @"profileExist"];
                                                    bool profileExist = [profileBoolNum boolValue];
                                                    
                                                    if (profileExist == true) {
                                                        NSLog(@"Logged In Sucessfully");
                                                        [SVProgressHUD dismiss];
                                                        [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
                                                        return;
                                                        
                                                    } else if (profileExist != true) {
                                                        PAPprofileSetupViewController *profileSettingsViewController = [[PAPprofileSetupViewController alloc] init];
                                                        [self.navigationController pushViewController:profileSettingsViewController animated:YES];
                                                    }
                                                    
                                                } else {
                                                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wrong Email" message:@"Please check your email address or password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                    alert.alertViewStyle = UIAlertViewStyleDefault;
                                                    [alert show];
                                                    [SVProgressHUD dismiss];
                                                }
                                            }];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
    }
    return YES;
}

#pragma mark - UIAlertView Delegate
/*
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
        
        [self dismissKeyboard];
    }
}
*/

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
