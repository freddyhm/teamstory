//
//  PAPLogInViewController.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
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

    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLogin-568h.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLogin.png"]];
        //[self.logInView.logInButton setFrame:CGRectMake(60.0f, 390.0f, 200.0f, 40.0f)];
        //[self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"button-email.png"] forState:UIControlStateNormal];
        //[self.logInView addSubview:self.logInView.logInButton];
        
        
        UIButton *emailLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        [emailLogin setFrame:CGRectMake( 60.0f, 370.0f, 200.0f, 40.0f)];
        //[backButtonTest setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
        [emailLogin addTarget:self action:@selector(emailLoginAction:) forControlEvents:UIControlEventTouchUpInside];
        [emailLogin setBackgroundImage:[UIImage imageNamed:@"button-email.png"] forState:UIControlStateNormal];
        //[backButtonTest setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
        [self.logInView addSubview:emailLogin];
        
        UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [registerButton setFrame:CGRectMake( 60.0f, 420.0f, 200.0f, 40.0f)];
        [registerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [[registerButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
        [registerButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [registerButton addTarget:self action:@selector(registerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //[registerButton setBackgroundImage:[UIImage imageNamed:@"button-email.png"] forState:UIControlStateNormal];
        //[backButtonTest setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
        [self.logInView addSubview:registerButton];
        
        
        
    }

    [self.logInView setLogo:nil];
    
    self.fields = PFLogInFieldsUsernameAndPassword;
    self.logInView.usernameField.placeholder = @"Enter your email";
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    //[self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    //[self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateNormal];
    //[self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"buttonFacebook.png"] forState:UIControlStateNormal];
    //[self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"buttonFacebookSelected.png"] forState:UIControlStateHighlighted];

    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        [self.logInView.facebookButton setFrame:CGRectMake(60.0f, 400.0f, 200.0f, 40.0f)];
    } else {
        //[self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"button-email.png"] forState:UIControlStateNormal];
        [self.logInView.facebookButton setFrame:CGRectMake(60.0f, 320.0f, 200.0f, 40.0f)];
        
        [self.logInView.logInButton setFrame:CGRectMake(60.0f, 390.0f, 200.0f, 40.0f)];
        [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"button-email.png"] forState:UIControlStateNormal];
        //[self.logInView addSubview:self.logInView.logInButton];

    }
    
  
}

- (void)registerButtonAction:(id)sender {
    emailSignUpViewController *signUpController = [[emailSignUpViewController alloc] init];
    
    UINavigationController *signUpNav = [[UINavigationController alloc] initWithRootViewController:signUpController];
    signUpNav.navigationBarHidden = YES;
    [self presentModalViewController:signUpNav animated:YES];
}

- (void)emailLoginAction:(id)sender {
    /*
    UIViewController *emailLoginController = [[emailLoginViewController alloc] init];
    //emailLoginNavController = self.navigationController;
    [self.logInView addSubview:emailLoginController.view];
    
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.3f];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[emailLoginController.view layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
     */
    //[(AppDelegate*)[[UIApplication sharedApplication] delegate] presentEmailLoginViewControllerAnimated:YES];
    //return;
    emailLoginViewController *emailLoginController = [[emailLoginViewController alloc] init];
    UINavigationController *emailNav = [[UINavigationController alloc] initWithRootViewController:emailLoginController];
    emailNav.navigationBarHidden = YES;
    [self presentModalViewController:emailNav animated:YES];
    //NSLog(@"%@", self.navigationController);
}


@end
