//
//  PAPLoginSelectionViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 3/9/14.
//
//

#import "PAPLoginSelectionViewController.h"
#import "PAPLogInViewController.h"

@interface PAPLoginSelectionViewController ()

@end

@implementation PAPLoginSelectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-login.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_iphone4.png"]];
    }
    
    UIButton *joinButton = [[UIButton alloc] initWithFrame:CGRectMake(35.0f, [UIScreen mainScreen].bounds.size.height - 125.0f, 249.0f, 45.0f)];
    [joinButton setTitle:@"Join Teamstory" forState:UIControlStateNormal];
    [joinButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 3.0f, 2.0f, -3.0f)];
    joinButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    joinButton.layer.cornerRadius = 1.5f;
    [joinButton setBackgroundColor:[UIColor colorWithRed:91.0f/255.0f green:194.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
    [joinButton addTarget:self action:@selector(joinButton_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinButton];
    
    UIButton *signinButton = [[UIButton alloc] initWithFrame:CGRectMake(35.0f, [UIScreen mainScreen].bounds.size.height - 70.0f, 249.0f, 45.0f)];
    [signinButton setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.3f]];
    [signinButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [signinButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 3.0f, 2.0f, 3.0f)];
    [signinButton addTarget:self action:@selector(signinButton_action:) forControlEvents:UIControlEventTouchUpInside];
    signinButton.layer.cornerRadius = 1.5f;
    signinButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [self.view addSubview:signinButton];
}

- (void) joinButton_action:(id)sender {
    PAPLogInViewController *loginViewController = [[PAPLogInViewController alloc] init];
    [loginViewController setDelegate:self];
    loginViewController.fields = PFLogInFieldsFacebook | PFLogInFieldsTwitter;
    loginViewController.facebookPermissions = @[ @"user_about_me" ];
    
    [self presentViewController:loginViewController animated:YES completion:nil];
    
}

- (void) signinButton_action:(id)sender {
    
}


@end
