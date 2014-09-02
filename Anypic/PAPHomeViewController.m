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
@property (nonatomic, strong) UIButton *notificationBar;
@property (nonatomic, strong) UIScrollView *inheritScrollView;
@property (nonatomic, strong) NSString *notificationContent;
@property (nonatomic, strong) PFObject *notificationPhoto;
@property (nonatomic, strong) UIButton *notificationExitButton;
@property (nonatomic, strong) UIImageView *notificationStar;
@property (nonatomic, strong) UIImageView *feedbackImgView;
@property (nonatomic, strong) UIImageView *feedIndicator;
@property (nonatomic, strong) UILabel *emptyPlaceholder;

@property NSNumber *konotorCount;
@end

@implementation PAPHomeViewController
@synthesize firstLaunch;
@synthesize settingsActionSheetDelegate;
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
    
    // refresh feed
    UIFont *feedFont = [UIFont systemFontOfSize:17.0f];
    UIImage *logoImg = [UIImage imageNamed:@"logoNavigationBar.png"];
    UIButton *logoBtn = [[UIButton alloc]initWithFrame:CGRectMake(10.0f, 10.0f, logoImg.size.width, logoImg.size.height)];
    [logoBtn setBackgroundImage:logoImg forState:UIControlStateNormal];
    [logoBtn addTarget:self action:@selector(refreshCurrentFeed) forControlEvents:UIControlEventTouchUpInside];
    
    // top nav buttons
    UIButton *exploreBtn = [[UIButton alloc]initWithFrame:CGRectMake(80.0f, 10.0f, 70.0f, 20.0f)];
    [exploreBtn setTitle:@"Explore" forState:UIControlStateNormal];
    [exploreBtn.titleLabel setFont:feedFont];
    [exploreBtn addTarget:self action:@selector(switchFeedSource:) forControlEvents:UIControlEventTouchUpInside];
  
    UIButton *followingBtn = [[UIButton alloc]initWithFrame:CGRectMake(exploreBtn.frame.origin.x + exploreBtn.frame.size.width + 10.0f, exploreBtn.frame.origin.y, 80.0f, 20.0f)];
    [followingBtn setTitle:@"Following" forState:UIControlStateNormal];
    [followingBtn.titleLabel setFont:feedFont];
    [followingBtn addTarget:self action:@selector(switchFeedSource:) forControlEvents:UIControlEventTouchUpInside];
    
    // swipe gestures left & right
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftFeedSource)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightFeedSource)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // triangle indicator image
    UIImage *indicatorImg = [UIImage imageNamed:@"triangle.png"];
    self.feedIndicator = [[UIImageView alloc]initWithImage:indicatorImg];
    [self.feedIndicator setFrame:CGRectMake(115.0f, 37.0f, indicatorImg.size.width, indicatorImg.size.height)];

    [self.navigationController.navigationBar addSubview:logoBtn];
    [self.navigationController.navigationBar addSubview:exploreBtn];
    [self.navigationController.navigationBar addSubview:followingBtn];
    [self.navigationController.navigationBar addSubview:self.feedIndicator];
    
    // Empty case placeholder, hidden by default
    self.emptyPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/3, self.view.frame.size.width, 40.0f)];
    self.emptyPlaceholder.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    [self.emptyPlaceholder setText:@"Uh Oh! Get to know more startups :)"];
    self.emptyPlaceholder.textAlignment = NSTextAlignmentCenter;
    [self.emptyPlaceholder setTextColor:[UIColor colorWithRed:178.0f/255.0f green:184.0f/255.0f blue:189.0f/255.0f alpha:1.0f]];
    self.emptyPlaceholder.hidden = YES;
    
    [super.feed addSubview:self.emptyPlaceholder];
    [super.feed addGestureRecognizer:leftSwipe];
    [super.feed addGestureRecognizer:rightSwipe];
    [super.feed setUserInteractionEnabled:YES];
    
    self.navigationItem.rightBarButtonItem = promptTrigger;
    
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
    
     */
}

-(void)refreshCurrentFeed{
    
    // get current feed from parent
    NSString *currentFeed = [super getFeedSourceType];
    
    // if empty will crash when trying to scroll
    if(super.objects.count > 0){
        // scroll to the top animated and refresh current feed
        [super.feed scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [super loadObjects:nil isRefresh:YES fromSource:currentFeed];
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
    
    if (super.objects.count == 0 && ![super.loadQuery hasCachedResult] & !self.firstLaunch) {
        
        super.feed.backgroundView = nil;
        [self.emptyPlaceholder setHidden:NO];
        
        super.feed.scrollEnabled = NO;
    } else {
        
        super.feed.backgroundView = super.texturedBackgroundView;
        [self.emptyPlaceholder setHidden:YES];
        
        super.feed.tableHeaderView = nil;
        super.feed.scrollEnabled = YES;
        [super.feed setShowsVerticalScrollIndicator:NO];
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

- (void)swipeLeftFeedSource{
    [self switchFeedSource:@"following"];

}

- (void)swipeRightFeedSource{
    [self switchFeedSource:@"explore"];
}

- (void)switchFeedSource:(id)sender{
    
    NSString *selectedFeedSource = @"";
    
    if([sender isKindOfClass:[NSString class]]){
        selectedFeedSource = sender;
    }else{
        UIButton *tappedBtn = (UIButton *)sender;
         selectedFeedSource = [tappedBtn.titleLabel.text lowercaseString];
    }
    
    NSString *currentFeedSource = [super getFeedSourceType];
    NSIndexPath *lastViewdIndexPath = [super getIndexPathForFeed:selectedFeedSource];

    
    // make sure selected feed is different than current so we can switch instead of refreshing
    if(![currentFeedSource isEqualToString:selectedFeedSource]){
        
        [SVProgressHUD show];
        
        // get direction of triangle
        float triangleMove = 0;
        if([selectedFeedSource isEqualToString:@"explore"]){
            triangleMove = -70.0f;
        }else if([selectedFeedSource isEqualToString:@"following"]){
            triangleMove = 70.0f;
        }
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             // update triangle's frame
                             [self.feedIndicator setFrame:CGRectMake(self.feedIndicator.frame.origin.x + triangleMove, self.feedIndicator.frame.origin.y, self.feedIndicator.frame.size.width, self.feedIndicator.frame.size.height)];
                         }
                         completion:nil];
        
        [super loadObjects:^(BOOL succeeded) {
            [SVProgressHUD dismiss];
            
            if(super.objects.count != 0){
                // scroll to last viewed index path
                [super.feed scrollToRowAtIndexPath:lastViewdIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            
        } isRefresh:YES fromSource:selectedFeedSource];
        
    }else{
        [self refreshCurrentFeed];
    }
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
