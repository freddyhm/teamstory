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
    UIButton *emailLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];

    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"intro_iphone5.png"]];
        [emailLogin setFrame:CGRectMake( 12.5f, 505.0f, 295.0f, 45.0f)];
        [registerButton setFrame:CGRectMake( 12.5f, 455.0f, 295.0f, 45.0f)];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"intro_iphone4.png"]];
        [emailLogin setFrame:CGRectMake( 12.5f, 420.0f, 295.0f, 45.0f)];
        [registerButton setFrame:CGRectMake( 12.5f, 370.0f, 295.0f, 45.0f)];
    }
    
    //[backButtonTest setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [emailLogin addTarget:self action:@selector(emailLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [emailLogin setBackgroundImage:[UIImage imageNamed:@"loginbutton.png"] forState:UIControlStateNormal];
    //[backButtonTest setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
    [self.logInView addSubview:emailLogin];
    
    [registerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[registerButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [registerButton addTarget:self action:@selector(registerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setBackgroundImage:[UIImage imageNamed:@"registerbutton.png"] forState:UIControlStateNormal];
    //[backButtonTest setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
    [self.logInView addSubview:registerButton];

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
        [self.logInView.facebookButton setFrame:CGRectMake(12.5f, 405.0f, 295.0f, 45.0f)];
    } else {
        [self.logInView.facebookButton setFrame:CGRectMake(12.5f, 321.0f, 295.0f, 45.0f)];
    }
    [self.logInView.facebookButton setTitle:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"fbbutton.png"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"fbbutton.png"] forState:UIControlStateHighlighted];
    
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


@end
