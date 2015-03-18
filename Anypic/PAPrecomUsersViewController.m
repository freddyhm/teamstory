//
//  PAPrecomUsersViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/26/15.
//
//

#import "PAPrecomUsersViewController.h"
#import "PAPdiscoverTileView.h"
#import "PAPfirstPicViewController.h"

@interface PAPrecomUsersViewController ()
@property (strong, nonatomic) IBOutlet UIView *navBar;

@end

@implementation PAPrecomUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type": @"New Profile Screen 2"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"viewed_screen" action:@"new_profile_2" label:@"" value:@""];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"New Profile Screen 2"];
    
    PAPdiscoverTileView *discoverTileView = [[PAPdiscoverTileView alloc] initWithFrame:CGRectMake(0, self.navBar.frame.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [discoverTileView setFieldsForFirstLogin];
    [self.view addSubview:discoverTileView];
    
}

- (IBAction)nextButtonAction:(id)sender {
    PAPfirstPicViewController *firstPicViewController = [[PAPfirstPicViewController alloc] initWithNibName:@"PAPfirstPicViewController" bundle:nil];
    [self presentViewController:firstPicViewController animated:YES completion:nil];
}
@end
