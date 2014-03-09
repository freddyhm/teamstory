//
//  PAPLogInViewController.m
//  Teamstory
//
//

#import "PAPLogInViewController.h"
#import "emailLoginViewController.h"
#import "AppDelegate.h"
#import "emailSignUpViewController.h"


@implementation PAPLogInViewController
@synthesize emailLoginNavController;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //UIButton *emailLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];

    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"intro_iphone4.png"]];
    }
    /*
    [emailLogin addTarget:self action:@selector(emailLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [emailLogin setBackgroundImage:[UIImage imageNamed:@"loginbutton.png"] forState:UIControlStateNormal];
    [self.logInView addSubview:emailLogin];
    
    [registerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[registerButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [registerButton addTarget:self action:@selector(registerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setBackgroundImage:[UIImage imageNamed:@"registerbutton.png"] forState:UIControlStateNormal];
    [self.logInView addSubview:registerButton];
    
 */
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIColor *color = [UIColor colorWithRed:134.0f/255.0f green:134.0f/255.0f blue:134.0f/255.0f alpha:1.0f];
    
    UITextField *user_email = [[UITextField alloc] initWithFrame:CGRectMake(35.0f, 310.0f, 250.0f, 45.0f)];
    user_email.layer.cornerRadius = 1.5f;
    user_email.leftView = paddingView;
    user_email.leftViewMode = UITextFieldViewModeAlways;
    user_email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [user_email setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
    user_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Thin" size:10.0f]}];
    [self.logInView addSubview:user_email];
    
    UITextField *user_pw = [[UITextField alloc] initWithFrame:CGRectMake(35.0f, 365.0f, 250.0f, 45.0f)];
    user_pw.layer.cornerRadius = 1.5f;
    user_pw.placeholder = @"Password";
    [user_pw setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
    [user_pw setFont:[UIFont systemFontOfSize:15]];
    user_pw.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:@"HelveticaNeue-Thin"}];
    user_pw.userInteractionEnabled = YES;
    user_pw.leftView = paddingView2;
    user_pw.leftViewMode = UITextFieldViewModeAlways;
    user_pw.delegate = self;
    user_pw.secureTextEntry = YES;
    [user_pw resignFirstResponder];
    [self.logInView addSubview:user_pw];
    
    UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(35.0f, [UIScreen mainScreen].bounds.size.height - 50.0f, 50.0f, 15.0f)];
    [back_button setBackgroundImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
    [back_button addTarget:self action:@selector(back_button_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.logInView addSubview:back_button];

    [self.logInView setLogo:nil];
    
    self.fields = PFLogInFieldsUsernameAndPassword;
    self.logInView.usernameField.placeholder = @"Enter your email";
    
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
        [self.logInView.facebookButton setFrame:CGRectMake(12.5f, 321.0f, 110.0f, 110.0f)];
        [self.logInView.twitterButton setFrame:CGRectMake(12.5, 200.0f, 110.0f, 110.0f)];
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

- (void)registerButtonAction:(id)sender {
    emailSignUpViewController *signUpController = [[emailSignUpViewController alloc] init];
    
    UINavigationController *signUpNav = [[UINavigationController alloc] initWithRootViewController:signUpController];
    signUpNav.navigationBarHidden = YES;
    [self presentViewController:signUpNav animated:YES completion:nil];
}


- (void)emailLoginAction:(id)sender {
    emailLoginViewController *emailLoginController = [[emailLoginViewController alloc] init];
    UINavigationController *emailNav = [[UINavigationController alloc] initWithRootViewController:emailLoginController];
    emailNav.navigationBarHidden = YES;
    [self presentViewController:emailNav animated:YES completion:nil];
}

- (void)back_button_action:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
