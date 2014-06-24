//
//  PAPHomeViewController.m
//  Teamstory
//
//

#import "PAPHomeViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "followersFollowingViewController.h"
#import "SVProgressHUD.h"
#import "KonotorUI.h"
#import <Crashlytics/Crashlytics.h>
#import "PAPCache.h"
#import "PAPTabBarController.h"

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
    
    notificationBar = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 64.0f, 320.0f, 0.0f)];
    [notificationBar setBackgroundColor:[UIColor colorWithRed:251.0f/255.0f green:176.0f/255.0f blue:70.0f/255.0f alpha:1.0f]];
    [notificationBar addTarget:self action:@selector(notificationBarButton:) forControlEvents:UIControlEventTouchUpInside];
    [notificationBar.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    notificationBar.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 30.0f, 0.0f, 30.0f);
    notificationBar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [notificationBar.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    notificationBar.hidden = YES;
    [notificationBar setTag:100];
    
    notificationExitButton = [[UIButton alloc] initWithFrame:CGRectMake(285.0f, 0.0f, 45.0f, 45.0f)];
    [notificationExitButton addTarget:self action:@selector(notificationExitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [notificationExitButton setBackgroundImage:[UIImage imageNamed:@"notif_close.png"] forState:UIControlStateNormal];
    notificationExitButton.hidden = YES;
    [notificationBar addSubview:notificationExitButton];
    
    notificationStar = [[UIImageView alloc] initWithFrame:CGRectMake(-9.0f, 0.0f, 45.0f, 45.0f)];
    [notificationStar setImage:[UIImage imageNamed:@"notif_star.png"]];
    notificationStar.hidden = YES;
    [notificationBar addSubview:notificationStar];
    
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake( 33.0f, 96.0f, 253.0f, 173.0f);
    [button setBackgroundImage:[UIImage imageNamed:@"HomeTimelineBlank.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
     */
}

-(void)userRefreshControl{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [self loadObjects];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // analytics
    [PAPUtility captureScreenGA:@"Home"];
    
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notification"];
    [notificationQuery orderByDescending:@"createdAt"];
    
    [notificationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            notificationContent = [object objectForKey:@"Content"];
            NSString *notificationCachedResult = [[PAPCache sharedCache] notificationContent];
            
            if (![notificationCachedResult isEqualToString:notificationContent]) {
                [[[[UIApplication sharedApplication] delegate] window] addSubview:notificationBar];
                [notificationBar setTitle:nil forState:UIControlStateNormal];
                notificationBar.frame = CGRectMake(0.0f, 64.0f, 320.0f, 0.0f);
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


#pragma mark - UIScrollViewDelegate

// see if scrolling near end, refresh when decelerating if so
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >= (scrollView.contentSize.height * 0.78)) {
        [self loadNextPage];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL isHome = [[self.navigationController.viewControllers lastObject] isKindOfClass:PAPHomeViewController.class];
    
    // make sure pull-to-refresh set only for home
    if(isHome){
        if(scrollView.contentOffset.y <= -100){
            
            if(![SVProgressHUD isVisible]){
                CGFloat hudOffset = IS_WIDESCREEN ? -160.0f : -120.0f;
                [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0.0f, hudOffset)];
                [SVProgressHUD show];
            }
        }else{
            if([SVProgressHUD isVisible]){
                [SVProgressHUD dismiss];
                [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0.0f, 0.0f)];
            }
        }
    }
    
    [self scrollViewWillBeginDragging:scrollView];
    notificationExitButton.hidden = YES;
    notificationStar.hidden = YES;
    
    if (scrollView.contentOffset.y > 0) {
         if (scrollView.contentOffset.y < scrollPosition) {
              currentScrollDirectionDown = NO;
             
             // Detect scrolling up.
             if (scrollDirectionDown == NO) {
               currentScrollPosition += 2.5;
                 notificationBar.hidden = NO;
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
            notificationExitButton.hidden = NO;
            notificationStar.hidden = NO;
        }
        
        if (currentScrollPosition > 30) {
            [notificationBar setTitle:notificationContent forState:UIControlStateNormal];
        } else {
            [notificationBar setTitle:nil forState:UIControlStateNormal];
        }
        
        if (scrollView.contentOffset.y <= 45) {
            currentScrollPosition = 0;
            notificationExitButton.hidden = YES;
            [notificationBar setTitle:nil forState:UIControlStateNormal];
            
            [UIView animateWithDuration:0.5 animations:^{
                notificationBar.frame = CGRectMake(0.0f, 64.0f, 320.0f, currentScrollPosition);
            }];
        }
        
        scrollPosition = scrollView.contentOffset.y;
        notificationBar.frame = CGRectMake(0.0f, 64.0f, 320.0f, currentScrollPosition);
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

#pragma mark - ()
/*
- (void)settingsButtonAction:(id)sender {
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile",@"Find Friends",@"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
*/

- (void)inviteFriendsButtonAction:(id)sender {
    followersFollowingViewController *detailViewController = [[followersFollowingViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)promptFeedback:(id)sender{
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    [KonotorFeedbackScreen showFeedbackScreen];
}

-(void)notificationBarButton:(id)sender {
    [[PAPCache sharedCache] notificationCache:notificationContent];
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    
    if (notificationPhoto) {
        PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:notificationPhoto source:@"Notification"];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
    
}

-(void)notificationExitButtonAction:(id)sender {
    [[PAPCache sharedCache] notificationCache:notificationContent];
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
}

@end
