//
//  PAPHomeViewController.m
//  Teamstory
//
//

#import "PAPHomeViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPFindFriendsViewController.h"
#import "SVProgressHUD.h"
#import "KonotorUI.h"
#import <Crashlytics/Crashlytics.h>

@interface PAPHomeViewController ()
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation PAPHomeViewController
@synthesize firstLaunch;
@synthesize settingsActionSheetDelegate;
@synthesize blankTimelineView;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // register name and email in case of crashes
    NSString *displayName = [[PFUser currentUser] objectForKey:@"displayName"];
    NSString *email = [[PFUser currentUser] objectForKey:@"email"];
    
    if(displayName != nil){
        [Crashlytics setUserName:displayName];
    }
    
    if(email != nil){
        [Crashlytics setUserEmail:email];
    }
        
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];

    // button image for feedback
    UIImageView *feedbackImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-feedback.png"]];
    UIBarButtonItem *promptTrigger = [[UIBarButtonItem alloc] initWithCustomView:feedbackImgView];
    feedbackImgView.userInteractionEnabled = YES;
    [feedbackImgView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promptFeedback:)]];
    
    UIView *navBarTitleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 94.0f, 30.0f)];
    [navBarTitleView setBackgroundColor:[UIColor clearColor]];
    
    UIButton *refresh_button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 94.0f, 30.0f)];
    [refresh_button addTarget:self action:@selector(userRefreshControl) forControlEvents:UIControlEventTouchUpInside];
    [navBarTitleView addSubview:refresh_button];
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    [navBarTitleView addSubview:logoView];

    self.navigationItem.titleView = navBarTitleView;
    
    self.navigationItem.rightBarButtonItem = promptTrigger;

    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake( 33.0f, 96.0f, 253.0f, 173.0f);
    [button setBackgroundImage:[UIImage imageNamed:@"HomeTimelineBlank.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
     */
}

-(void)userRefreshControl{
        NSLog(@"pressed");
    
    [self.tableView setContentOffset:CGPointMake(0.0f, -50.0f) animated:YES];
    [self loadObjects];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // analytics
    [PAPUtility captureScreenGA:@"Home"];
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult] & !self.firstLaunch) {
        self.tableView.scrollEnabled = NO;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        [self.tableView setShowsVerticalScrollIndicator:NO];
    }
}


#pragma mark - ()
/*
- (void)settingsButtonAction:(id)sender {
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile",@"Find Friends",@"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
*/

- (void)inviteFriendsButtonAction:(id)sender {
    PAPFindFriendsViewController *detailViewController = [[PAPFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)promptFeedback:(id)sender{
   [KonotorFeedbackScreen showFeedbackScreen];
}

@end
