//
//  ProfileSettingViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-02-15.
//
//

#import "ProfileSettingViewController.h"

@interface ProfileSettingViewController ()


@property (nonatomic, strong) PFUser *user;

@end

@implementation ProfileSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [PFUser currentUser];
    
    // creating another method to call later for the freshing purpose.
    [self refreshView];
}

-(void)viewDidAppear:(BOOL)animated{
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Edit Profile"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"edit_profile_screen" action:@"viewed_edit_profile" label:@"" value:@""];
    
    [SVProgressHUD show];
    
   // if(email_user != nil && [SVProgressHUD isVisible]){
     //   [SVProgressHUD dismiss];
   // }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshView {
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
