//
//  PAPHomeViewController.m
//  Teamstory
//
//

#import "PAPHomeViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "FollowersFollowingViewController.h"
#import "SVProgressHUD.h"
#import "KonotorUI.h"
#import <Crashlytics/Crashlytics.h>
#import "PAPCache.h"
#import "PAPTabBarController.h"
#import "Mixpanel.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface PAPHomeViewController () {
    NSInteger scrollPosition;
    NSInteger currentScrollPosition;
    BOOL currentScrollDirectionDown;
    BOOL scrollDirectionDown;
}
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) UIView *blankTimelineView;
@property (nonatomic, strong) UIButton *notificationBar;
@property (nonatomic, strong) UIScrollView *inheritScrollView;
@property (nonatomic, strong) NSString *notificationContent;
@property (nonatomic, strong) PFObject *notificationPhoto;
@property (nonatomic, strong) UIButton *notificationExitButton;
@property (nonatomic, strong) UIImageView *notificationStar;
@property (nonatomic, strong) UIImageView *feedbackImgView;

@property NSNumber *konotorCount;
@end

@implementation PAPHomeViewController
@synthesize firstLaunch;
@synthesize settingsActionSheetDelegate;
@synthesize blankTimelineView;
@synthesize notificationBar;
@synthesize inheritScrollView;
@synthesize notificationContent;
@synthesize notificationPhoto;
@synthesize notificationExitButton;
@synthesize notificationStar;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // button image for feedback
    self.feedbackImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-feedback.png"]];
    UIBarButtonItem *promptTrigger = [[UIBarButtonItem alloc] initWithCustomView:self.feedbackImgView];
    self.feedbackImgView.userInteractionEnabled = YES;
    [self.feedbackImgView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promptFeedback:)]];
    
    // refresh feed buttons
    UIFont *feedFont = [UIFont systemFontOfSize:17.0f];
    
    UIButton *exploreBtn = [[UIButton alloc]initWithFrame:CGRectMake(80.0f, 10.0f, 70.0f, 20.0f)];
    [exploreBtn setTitle:@"Explore" forState:UIControlStateNormal];
    [exploreBtn.titleLabel setFont:feedFont];
    [exploreBtn addTarget:self action:@selector(refreshExploreFeed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *followingBtn = [[UIButton alloc]initWithFrame:CGRectMake(exploreBtn.frame.origin.x + exploreBtn.frame.size.width + 10.0f, exploreBtn.frame.origin.y, 80.0f, 20.0f)];
    [followingBtn setTitle:@"Following" forState:UIControlStateNormal];
    [followingBtn.titleLabel setFont:feedFont];
    [followingBtn addTarget:self action:@selector(refreshFollowingFeed) forControlEvents:UIControlEventTouchUpInside];

    [self.navigationController.navigationBar addSubview:exploreBtn];
    [self.navigationController.navigationBar addSubview:followingBtn];
    
    
   // UITapGestureRecognizer *tapLogo = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userRefreshControl:)];
    
   // [logoView addGestureRecognizer:tapLogo];
    //logoView.userInteractionEnabled = YES;
    
    self.navigationItem.rightBarButtonItem = promptTrigger;

    self.blankTimelineView = [[UIView alloc] initWithFrame:self.feed.bounds];
    
    // diabling notification bar for now.
    /*
    self.notificationBar = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 64.0f, 320.0f, 0.0f)];
    [self.notificationBar setBackgroundColor:[UIColor colorWithRed:251.0f/255.0f green:176.0f/255.0f blue:70.0f/255.0f alpha:1.0f]];
    [self.notificationBar addTarget:self action:@selector(notificationBarButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.notificationBar.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    self.notificationBar.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 30.0f, 0.0f, 30.0f);
    self.notificationBar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.notificationBar.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    self.notificationBar.hidden = YES;
    
    self.notificationExitButton = [[UIButton alloc] initWithFrame:CGRectMake(285.0f, 0.0f, 45.0f, 45.0f)];
    [self.notificationExitButton addTarget:self action:@selector(notificationExitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.notificationExitButton setBackgroundImage:[UIImage imageNamed:@"notif_close.png"] forState:UIControlStateNormal];
    self.notificationExitButton.hidden = YES;
    [self.notificationBar addSubview:self.notificationExitButton];
    
    self.notificationStar = [[UIImageView alloc] initWithFrame:CGRectMake(-9.0f, 0.0f, 45.0f, 45.0f)];
    [self.notificationStar setImage:[UIImage imageNamed:@"notif_star.png"]];
    self.notificationStar.hidden = YES;
    [self.notificationBar addSubview:self.notificationStar];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake( 33.0f, 96.0f, 253.0f, 173.0f);
    [button setBackgroundImage:[UIImage imageNamed:@"HomeTimelineBlank.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
     */
}

-(void)userRefreshControl:(id)sender{
    [self.feed scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [super loadObjects:nil isRefresh:YES fromSource:@"explore"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.notificationStar.hidden = YES;
    self.notificationExitButton.hidden = YES;

    // analytics
    [PAPUtility captureScreenGA:@"Home"];
    
    [[Mixpanel sharedInstance] track:@"Viewed Home Screen" properties:@{}];
    
    [self setUserInfoAnalytics];
    
    // fetch unread messages, show feedback screen
    self.konotorCount = [NSNumber numberWithInt:[Konotor getUnreadMessagesCount]];
    
    if([self.konotorCount intValue] > 0){
        [self.feedbackImgView setImage:[UIImage imageNamed:@"button-feedback-notify.png"]];
    }else{
        [self.feedbackImgView setImage:[UIImage imageNamed:@"button-feedback.png"]];
    }
    
    // disabling notification bar for now.
    /*
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notification"];
    [notificationQuery orderByDescending:@"createdAt"];
    
    [notificationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            notificationContent = [object objectForKey:@"Content"];
            NSString *notificationCachedResult = [[PAPCache sharedCache] notificationContent];
            
            if (![notificationCachedResult isEqualToString:notificationContent]) {
                [[[[UIApplication sharedApplication] delegate] window] addSubview:self.notificationBar];
                [self.notificationBar setTag:100];
                [self.notificationBar setTitle:nil forState:UIControlStateNormal];
                self.notificationBar.frame = CGRectMake(0.0f, 64.0f, 320.0f, 0.0f);
                currentScrollPosition = 0;
            }
            if ([object objectForKey:@"Photo"]) {
                PFQuery *notificationPhotoQuery = [PFQuery queryWithClassName:@"Photo"];
                [notificationPhotoQuery whereKey:@"objectId" equalTo:[[object objectForKey:@"Photo"] objectId]];
                
                [notificationPhotoQuery getFirstObjectInBackgroundWithBlock:^(PFObject *photoObject, NSError *error) {
                    if (!error) {
                        notificationPhoto = photoObject;
                    } else {
                        NSLog(@"%@", error);
                    }
                }];
            } else {
                notificationPhoto = nil;
            }
        } else {
            NSLog(@"%@", error);
        }
    }];
     */
}

#pragma mark - Datasource

- (BOOL)objectsDidLoad:(NSError *)error {
    
    BOOL didLoad = [super objectsDidLoad:error];
    
    if (self.objects.count == 0 && ![self.loadQuery hasCachedResult] & !self.firstLaunch) {
        self.feed.scrollEnabled = NO;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.feed.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.feed.tableHeaderView = nil;
        self.feed.scrollEnabled = YES;
        [self.feed setShowsVerticalScrollIndicator:NO];
    }
    
    return didLoad;
}


#pragma mark - UIScrollViewDelegate
/*
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [super scrollViewDidScroll:scrollView];
    
    // disabling notification bar for now.

    [self scrollViewWillBeginDragging:scrollView];
    self.notificationExitButton.hidden = YES;
    self.notificationStar.hidden = YES;
    
    if (scrollView.contentOffset.y > 0) {
         if (scrollView.contentOffset.y < scrollPosition) {
              currentScrollDirectionDown = NO;
             
             // Detect scrolling up.
             if (scrollDirectionDown == NO) {
               currentScrollPosition += 2.5;
                 self.notificationBar.hidden = NO;
             }
         } else if (scrollView.contentOffset.y > scrollPosition) {
              currentScrollDirectionDown = YES;
             // Detect scrolling down.
             if (currentScrollPosition == 0) {
                 
             } else {
                 if (scrollDirectionDown == YES) {
                     currentScrollPosition -= 2.5;
                 }
             }
         
         }
        
        if (currentScrollPosition < 0) {
            currentScrollPosition = 0;
        } else if (currentScrollPosition > 45) {
            currentScrollPosition = 45;
        }
        
        if (currentScrollPosition > 37) {
            self.notificationExitButton.hidden = NO;
            self.notificationStar.hidden = NO;
        }
        
        if (currentScrollPosition > 30) {
            [self.notificationBar setTitle:notificationContent forState:UIControlStateNormal];
        } else {
            [self.notificationBar setTitle:nil forState:UIControlStateNormal];
        }
        
        if (scrollView.contentOffset.y <= 45) {
            currentScrollPosition = 0;
            self.notificationExitButton.hidden = YES;
            self.notificationStar.hidden = YES;
            [self.notificationBar setTitle:nil forState:UIControlStateNormal];
            
            [UIView animateWithDuration:0.5 animations:^{
                self.notificationBar.frame = CGRectMake(0.0f, 64.0f, 320.0f, currentScrollPosition);
            }];
        }
        
        scrollPosition = scrollView.contentOffset.y;
        self.notificationBar.frame = CGRectMake(0.0f, 64.0f, 320.0f, currentScrollPosition);
    }
 
}
 
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (currentScrollDirectionDown == NO){
        // Detect scrolling down.
        scrollDirectionDown = NO;
    } else {
        scrollDirectionDown = YES;
    }
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (currentScrollDirectionDown == NO){
        // Detect scrolling down.
        scrollDirectionDown = NO;
    } else {
        scrollDirectionDown = YES;
    }
}
*/
#pragma mark - ()

-(void)setUserInfoAnalytics{
    
    // register name and email in case of crashes
    NSString *displayName = [[PFUser currentUser] objectForKey:@"displayName"];
    NSString *email = [[PFUser currentUser] objectForKey:@"email"];
    NSString *currentUserId = [[PFUser currentUser] objectId];
    NSString *industry = [[PFUser currentUser] objectForKey:@"industry"];
    
    // Mxpanel analytics identify: must be called before
    // people properties can be set
    [[Mixpanel sharedInstance] identify:currentUserId];

    if(displayName != nil){
        [Crashlytics setUserName:displayName];
        
        // mixpanel analytics - Sets user
        [[Mixpanel sharedInstance].people set:@{@"name": displayName}];
        
        // super property
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"Name": displayName}];
    }
    
    if(email != nil){
        [Crashlytics setUserEmail:email];
        
        // Mixpanel analytics - Sets more user info
        [[Mixpanel sharedInstance].people set:@{@"email": email}];
    }
    
    if(industry != nil){
        // Mixpanel analytics - Sets more user info
        [[Mixpanel sharedInstance].people set:@{@"industry": industry}];
            
        // super property
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"Industry": industry}];
    }
  /*
    if(createdAt != nil){
        // Mixpanel analytics - Sets more user info
        //[[Mixpanel sharedInstance].people set:@{@"created": createdAt}];
    }
   */
}

/*
- (void)settingsButtonAction:(id)sender {
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile",@"Find Friends",@"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
*/

- (void)refreshExploreFeed{
    [SVProgressHUD show];
    [super loadObjects:^(BOOL succeeded) {
        [SVProgressHUD dismiss];
    } isRefresh:YES fromSource:@"explore"];
}

- (void)refreshFollowingFeed{
    
    [SVProgressHUD show];
    [super loadObjects:^(BOOL succeeded) {
        [SVProgressHUD dismiss];
    } isRefresh:YES fromSource:@"following"];

}

- (void)inviteFriendsButtonAction:(id)sender {
    FollowersFollowingViewController *detailViewController = [[FollowersFollowingViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)promptFeedback:(id)sender{
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    [KonotorFeedbackScreen showFeedbackScreen];
}

-(void)notificationBarButton:(id)sender {
    [[PAPCache sharedCache] notificationCache:notificationContent];
    //[[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    
    if (notificationPhoto) {
        PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:notificationPhoto source:@"Notification"];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
    
}

-(void)notificationExitButtonAction:(id)sender {
    [[PAPCache sharedCache] notificationCache:notificationContent];
    //[[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
}

@end
