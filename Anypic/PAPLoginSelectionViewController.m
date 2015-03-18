//
//  PAPLoginSelectionViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/19/15.
//
//

#import "PAPLoginSelectionViewController.h"
#import "PAPLoginPopupViewController.h"
#import "PAPSignUpViewController.h"
#import "AppDelegate.h"

@interface PAPLoginSelectionViewController ()
@property (strong, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UILabel *signInLabel;
@property (strong, nonatomic) IBOutlet UIButton *memberButton;

@end

@implementation PAPLoginSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Intro"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"intro_screen" action:@"viewing_intro" label:@"" value:@""];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"Intro"];
    
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        self.signInLabel.frame = CGRectMake(0.0f, 20.0f, [UIScreen mainScreen].bounds.size.width, 23.0f);
        self.joinButton.frame = CGRectMake(30.0f, 60.0f, 260.0f, 40.0f);
        self.memberButton.frame = CGRectMake(0.0f, 110.0f, [UIScreen mainScreen].bounds.size.width, 30.0f);
    }
    
    self.joinButton.layer.cornerRadius = 2.0f;
    self.joinButton.clipsToBounds = YES;
}

- (IBAction)joinButtonAction:(id)sender {
    PAPLoginPopupViewController *popupViewController = [[PAPLoginPopupViewController alloc] initWithNibName:@"PAPLoginPopupViewController" bundle:nil];
    [self presentViewController:popupViewController animated:YES completion:nil];
}

- (IBAction)memberButtonAction:(id)sender {
    PAPSignUpViewController *signUpViewController = [[PAPSignUpViewController alloc] initWithNibName:@"PAPSignUpViewController" bundle:nil];
    [self presentViewController:signUpViewController animated:YES completion:nil];
}

- (IBAction)cancelButtonAction:(id)sender {
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
}
@end
