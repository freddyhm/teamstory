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
@property (nonatomic, strong) UIImageView *feedIndicator;
@property (nonatomic, strong) UIView *emptyPlaceholder;
@property (nonatomic, strong) UIImageView *emptyPlaceholderMessage;
@property (nonatomic, strong) UIButton *emptyPlaceholderBtn;
@property (nonatomic, strong) UIButton *feedbackBtn;
@property (nonatomic, strong) UIButton *logoBtn;
@property (nonatomic, strong) UIButton *exploreBtn;
@property (nonatomic, strong) UIButton *followingBtn;
@property (nonatomic, strong) UIFont *feedFontDeselected;
@property (nonatomic, strong) UIFont *feedFontSelected;
@property (nonatomic, strong) UIView *switchWhiteOverlay;
@property BOOL firstRun;
@property BOOL isOpeningFeedback;
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
    
    // set analytics and first run flag
    [self setUserInfoAnalytics];
    self.firstRun = YES;
    self.isOpeningFeedback = NO;
    
    // button image for feedback
    UIImage *feedbackImg = [UIImage imageNamed:@"button-feedback.png"];
    self.feedbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(282, 6, feedbackImg.size.width, feedbackImg.size.height)];
    [self.feedbackBtn addTarget:self action:@selector(promptFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [self.feedbackBtn setImage:feedbackImg forState:UIControlStateNormal];

    // feed title ui
    self.feedFontSelected = [UIFont boldSystemFontOfSize:15.0f];
    self.feedFontDeselected = [UIFont systemFontOfSize:15.0f];
    
    // timeline logo
    UIImage *logoImg = [UIImage imageNamed:@"timelineLogo.png"];
    self.logoBtn = [[UIButton alloc]initWithFrame:CGRectMake(15.0f, 10.0f, logoImg.size.width, logoImg.size.height)];
    [self.logoBtn setBackgroundImage:logoImg forState:UIControlStateNormal];
    [self.logoBtn addTarget:self action:@selector(refreshCurrentFeed) forControlEvents:UIControlEventTouchUpInside];
    
    // timeline top nav buttons
    self.exploreBtn = [[UIButton alloc]initWithFrame:CGRectMake(80.0f, 10.0f, 70.0f, 20.0f)];
    [self.exploreBtn setTitle:@"Explore" forState:UIControlStateNormal];
    [self.exploreBtn addTarget:self action:@selector(switchFeedSource:) forControlEvents:UIControlEventTouchUpInside];
  
    self.followingBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.exploreBtn.frame.origin.x + self.exploreBtn.frame.size.width + 10.0f, self.exploreBtn.frame.origin.y, 80.0f, 20.0f)];
    [self.followingBtn setTitle:@"Following" forState:UIControlStateNormal];
    [self.followingBtn.titleLabel setFont:self.feedFontDeselected];
    [self.followingBtn addTarget:self action:@selector(switchFeedSource:) forControlEvents:UIControlEventTouchUpInside];
    
    // triangle indicator image
    UIImage *indicatorImg = [UIImage imageNamed:@"triangle.png"];
    self.feedIndicator = [[UIImageView alloc]initWithImage:indicatorImg];
    [self.feedIndicator setFrame:CGRectMake(110.0f, 37.0f, indicatorImg.size.width, indicatorImg.size.height)];

    [self.navigationController.navigationBar addSubview:self.logoBtn];
    [self.navigationController.navigationBar addSubview:self.exploreBtn];
    [self.navigationController.navigationBar addSubview:self.followingBtn];
    [self.navigationController.navigationBar addSubview:self.feedbackBtn];
    
    /* empty case placeholder, hidden by default */
    
    // empty placeholder message and icon
    UIImage *placeHolderImg = [UIImage imageNamed:@"following_empty.png"];
    self.emptyPlaceholderMessage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, placeHolderImg.size.width, placeHolderImg.size.height)];
    [self.emptyPlaceholderMessage setImage:placeHolderImg];
    
    // empty placeholder button
    UIImage *placeHolderBtnImg = [UIImage imageNamed:@"btn_following_discover.png"];
    self.emptyPlaceholderBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.emptyPlaceholderMessage.frame.size.height + 10.0f , placeHolderBtnImg.size.width, placeHolderBtnImg.size.height)];
    [self.emptyPlaceholderBtn setImage:placeHolderBtnImg forState:UIControlStateNormal];
    [self.emptyPlaceholderBtn addTarget:self action:@selector(emptyPlaceHolderBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    // empty placeholder view
    self.emptyPlaceholder = [[UIView alloc]initWithFrame:CGRectMake(45.0f, self.view.frame.size.height/4, self.emptyPlaceholderBtn.frame.size.width,self.emptyPlaceholderMessage.frame.size.height + self.emptyPlaceholderBtn.frame.size.height)];
    
    [self.emptyPlaceholder addSubview:self.emptyPlaceholderMessage];
    [self.emptyPlaceholder addSubview:self.emptyPlaceholderBtn];
    [self.emptyPlaceholder  setHidden:YES];
    
    
    [super.feed addSubview:self.emptyPlaceholder];
    
    // white switch overlay
    self.switchWhiteOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.switchWhiteOverlay setBackgroundColor:[UIColor whiteColor]];
    self.switchWhiteOverlay.layer.opacity = 0.6;
    [self.switchWhiteOverlay setHidden:YES];
    [self.view addSubview:self.switchWhiteOverlay];
    
    // stream selected by default
    [self switchSelectedButton:@"explore"];
    
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

- (void)viewWillDisappear:(BOOL)animated{
    
    // do not hide buttons if we're opening feedback system
    if(!self.isOpeningFeedback){
        [self setNavBarButtonsHidden:YES];
    }else{
        // reset flag
        self.isOpeningFeedback = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self setNavBarButtonsHidden:NO];
    
    self.notificationStar.hidden = YES;
    self.notificationExitButton.hidden = YES;

    // analytics
    [PAPUtility captureScreenGA:@"Home"];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Home"}];
    
    // fetch unread messages, show feedback screen
    self.konotorCount = [NSNumber numberWithInt:[Konotor getUnreadMessagesCount]];
    
    if([self.konotorCount intValue] > 0){
        [self.feedbackBtn.imageView setImage:[UIImage imageNamed:@"button-feedback-notify.png"]];
    }else{
        [self.feedbackBtn.imageView setImage:[UIImage imageNamed:@"button-feedback.png"]];
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
    
    // add the feed indicator on first run so it appears after view appears, does not work in viewdidappear
    if(self.firstRun){
        [self.navigationController.navigationBar addSubview:self.feedIndicator];
        self.firstRun = NO;
    }
    
    BOOL didLoad = [super objectsDidLoad:error];
    
    if (super.objects.count == 0 && ![super.loadQuery hasCachedResult] & !self.firstLaunch) {
        
        [self.feedIndicator setHidden:YES];
        [self.emptyPlaceholder setHidden:NO];
        
        super.feed.scrollEnabled = NO;
    } else {
        
        [self.feedIndicator setHidden:NO];
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
    
    // get user info for analytics
    NSString *displayName = [[PFUser currentUser] objectForKey:@"displayName"] != nil ? [[PFUser currentUser] objectForKey:@"displayName"] : @"";
    NSString *currentUserObjectId = [[PFUser currentUser] objectId] != nil ? [[PFUser currentUser] objectId] : @"";
    
    NSLog(@"%@", displayName);
    NSString *email = [[PFUser currentUser] objectForKey:@"email"] != nil ? [[PFUser currentUser] objectForKey:@"email"] : @"";
    NSString *industry = [[PFUser currentUser] objectForKey:@"industry"] != nil ? [[PFUser currentUser] objectForKey:@"industry"] : @"";
    NSDate *createdAt = [[PFUser currentUser] createdAt];
    
    // Mxpanel analytics identify: must be called before
    // people properties can be set
    [[Mixpanel sharedInstance] identify:currentUserObjectId];
    
    // info for crashes
    [Crashlytics setUserName:displayName];
    [Crashlytics setUserEmail:email];
    
    // mixpanel analytics - Sets user
    [[Mixpanel sharedInstance].people set:@{@"name": displayName, @"email": email, @"industry": industry, @"created": createdAt, @"userObjId": currentUserObjectId}];
    
    // super properties
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"Name": displayName}];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"Industry": industry}];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"Email": email}];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"UserObjId": currentUserObjectId}];
}

/*
- (void)settingsButtonAction:(id)sender {
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile",@"Find Friends",@"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
*/

- (void)inviteFriendsButtonAction:(id)sender {
    FollowersFollowingViewController *detailViewController = [[FollowersFollowingViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)promptFeedback:(id)sender{
    self.isOpeningFeedback = YES;
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

- (void)emptyPlaceHolderBtnAction{
    
    // go to discover index
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark - Switch Feed

- (void)refreshCurrentFeed{
    
    // get current feed from parent
    NSString *currentFeed = [super getFeedSourceType];
    
    // if empty will crash when trying to scroll
    if(super.objects.count != 0){
        // scroll to the top animated and refresh current feed
        [super.feed scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [super loadObjects:nil isRefresh:YES fromSource:currentFeed];
}

- (void)setNavBarButtonsHidden:(BOOL)isHidden{
    
    // hides set of timeline nav bar buttons
    [self.logoBtn setHidden:isHidden];
    [self.exploreBtn setHidden:isHidden];
    [self.followingBtn setHidden:isHidden];
    
    if(super.objects.count != 0){
        [self.feedIndicator setHidden:isHidden];
    }
    
    [self.feedbackBtn setHidden:isHidden];
}

- (void)switchSelectedButton:(NSString *)source{
    
    
    
    // change opacity and font based on selected and deselected
    if([source isEqualToString:@"explore"]){
        
        if(!self.firstRun){
            
            // mixpanel analytics
            [[Mixpanel sharedInstance] track:@"Viewed Timeline Feed" properties:@{@"Feed" : @"Explore"}];
        }
        
        self.exploreBtn.titleLabel.font = self.feedFontSelected;
        self.followingBtn.titleLabel.font = self.feedFontDeselected;
        
        self.exploreBtn.layer.opacity = 1.0;
        self.followingBtn.layer.opacity = 0.8;
        
    }else if([source isEqualToString:@"following"]){
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Viewed Timeline Feed" properties:@{@"Feed" : @"Following"}];
        
        self.followingBtn.titleLabel.font = self.feedFontSelected;
        self.exploreBtn.titleLabel.font = self.feedFontDeselected;
        
        self.followingBtn.layer.opacity = 1.0;
        self.exploreBtn.layer.opacity = 0.8;
    }
    
}

- (void)switchFeedSource:(id)sender{
    
    // get button title
    NSString *selectedFeedSource = @"";
    UIButton *tappedBtn = (UIButton *)sender;
    selectedFeedSource = [tappedBtn.titleLabel.text lowercaseString];
    
    // switch button ui
    [self switchSelectedButton:selectedFeedSource];
    
    NSString *currentFeedSource = [super getFeedSourceType];
    NSIndexPath *lastViewdIndexPath = [super getIndexPathForFeed:selectedFeedSource];

    // make sure selected feed is different than current so we can switch instead of refreshing
    if(![currentFeedSource isEqualToString:selectedFeedSource]){
        
        [self.switchWhiteOverlay setHidden:NO];
        [SVProgressHUD show];
        
        // get direction of triangle
        float triangleMove = 0;
        if([selectedFeedSource isEqualToString:@"explore"]){
            triangleMove = -84.0f;
        }else if([selectedFeedSource isEqualToString:@"following"]){
            triangleMove = 84.0f;
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

            [self.switchWhiteOverlay setHidden:YES];
            [SVProgressHUD dismiss];
            
            if(super.objects.count != 0){
                // scroll to last viewed index path
                [super.feed scrollToRowAtIndexPath:lastViewdIndexPath
                                  atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            
        } isRefresh:YES fromSource:selectedFeedSource];
        
    }else{
        [self refreshCurrentFeed];
    }
}



-(void)notificationExitButtonAction:(id)sender {
    [[PAPCache sharedCache] notificationCache:notificationContent];
    //[[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
}



@end
