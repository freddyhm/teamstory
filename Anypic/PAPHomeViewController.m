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
#import <FlightRecorder/FlightRecorder.h>
#import "PAPMessageListViewController.h"
#import "AtMention.h"
#import "ActivityPointViewController.h"
#import "PAPLoginSelectionViewController.h"

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
@property (nonatomic, strong) UIButton *logoBtn;
@property (nonatomic, strong) UIButton *exploreBtn;
@property (nonatomic, strong) UIButton *followingBtn;
@property (nonatomic, strong) UIFont *feedFontDeselected;
@property (nonatomic, strong) UIFont *feedFontSelected;
@property (nonatomic, strong) UIView *switchWhiteOverlay;
@property (nonatomic, strong) UIImage *feedbackImg;
@property (nonatomic, strong) UIImage *feedbackImgBadge;
@property (nonatomic, strong) NSNumber *konotorCount;
@property (nonatomic, strong) UILabel *activityPoints;
@property (nonatomic, strong) NSNumber *prevPointCount;
@property BOOL firstRun;
@property BOOL isOpeningFeedback;
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
    
    // load activity points for current user
    [[ActivityPointSystem sharedActivityPointSystem] getActivityPointsOnFirstRun];
    
    // button image for feedback
    self.feedbackImg = [UIImage imageNamed:@"btn_main_invite.png"];
    self.feedbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(282, 7, self.feedbackImg.size.width, self.feedbackImg.size.height)];
    [self.feedbackBtn setBackgroundImage:self.feedbackImg forState:UIControlStateNormal];
    [self.feedbackBtn addTarget:self action:@selector(promptFeedback:) forControlEvents:UIControlEventTouchUpInside];

    // feed title ui
    self.feedFontSelected = [UIFont boldSystemFontOfSize:15.0f];
    self.feedFontDeselected = [UIFont systemFontOfSize:15.0f];
    
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    // create activity points label
    self.activityPoints = [[UILabel alloc] initWithFrame:CGRectMake(13.0f, 10.0f, 30.0f, 22.0f)];
    [self.activityPoints setTextColor:teamStoryColor];
    self.activityPoints.textAlignment = NSTextAlignmentCenter;
    self.activityPoints.adjustsFontSizeToFitWidth = YES;
    [self.activityPoints setFont:[UIFont boldSystemFontOfSize:10.0f]];
    [self.activityPoints setUserInteractionEnabled:YES];
    self.activityPoints.backgroundColor = [UIColor whiteColor];
    self.activityPoints.layer.cornerRadius = 11.0f;
    self.activityPoints.clipsToBounds = YES;
    
    // add tap gesture to activity points label
    UITapGestureRecognizer *tapActivity = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedActivityPoints)];
    [self.activityPoints addGestureRecognizer:tapActivity];
    
    // set activity count
    NSNumber *initActivityPointCount = [[AtMention sharedAtMention] activityPoints];
    self.activityPoints.text = [initActivityPointCount stringValue];
    
    // flag to track and trigger animation
    self.prevPointCount = initActivityPointCount;
    
    //[self.logoBtn setBackgroundImage:logoImg forState:UIControlStateNormal];
    //[self.logoBtn addTarget:self action:@selector(refreshCurrentFeed) forControlEvents:UIControlEventTouchUpInside];
    
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

    //[self.navigationController.navigationBar addSubview:self.logoBtn];
    [self.navigationController.navigationBar addSubview:self.activityPoints];
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
    
    // google analytics
    [PAPUtility captureScreenGA:@"Home"];

    
    // refresh activity points
    [self getActivityPoints];

    [self setNavBarButtonsHidden:NO];
    
    
    self.notificationStar.hidden = YES;
    self.notificationExitButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMessageButton:)
                                                 name:@"updateMessageButton"
                                               object:nil];
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Home"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"home_screen" action:@"viewing_home" label:@"" value:@""];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"Home"];
    
    [self refreshBadge];
}

- (void) updateMessageButton:(NSNotification *)notification {
    [self refreshBadge];
}

- (void) refreshBadge {
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if ([[[PFUser currentUser] objectForKey:@"messagingBadge"] intValue] > 0) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPMessageTabBarItemIndex] tabBarItem];
            NSNumber *messagingBadgeNumber = [[PFUser currentUser] objectForKey:@"messagingBadge"];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            
            if ([messagingBadgeNumber intValue] > 0) {
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:messagingBadgeNumber];
            } else {
                tabBarItem.badgeValue = nil;
            }
            
            // get current selected tab
            NSUInteger selectedtabIndex = self.tabBarController.selectedIndex;
            
            // current view is tabbar, clear the badge.
            if(selectedtabIndex == PAPMessageTabBarItemIndex){
                tabBarItem.badgeValue = nil;
            }
        } else {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPMessageTabBarItemIndex] tabBarItem];
            tabBarItem.badgeValue = nil;
        }
    }];
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

#pragma mark - Activity Points

- (void)tappedActivityPoints{
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Tapped activity points"}];
    
    // create and push activity point screen
    ActivityPointViewController *activityPointViewController = [[ActivityPointViewController alloc] initWithNibName:nil bundle:nil];
    // set points after screen in stack
    activityPointViewController.points.text = self.activityPoints.text;
    [self.navigationController presentViewController:activityPointViewController animated:YES completion:nil];
    
}

- (void)getActivityPoints{
    
    // get current points
    NSNumber *activityCount = [[ActivityPointSystem sharedActivityPointSystem] activityPoints];
    
    // check if the points have changed so we can trigger animation
    if(![self.prevPointCount isEqualToNumber:activityCount]){
        
        // set new count and flag
        self.activityPoints.text = [activityCount stringValue];
        self.prevPointCount = activityCount;
        
        CGAffineTransform transform = self.activityPoints.transform;
        
        // animate the activity change
        [UIView animateWithDuration:0.2 animations:^{
            self.activityPoints.font = [UIFont boldSystemFontOfSize:12];
            self.activityPoints.transform = CGAffineTransformScale(self.activityPoints.transform, 1.1, 1.1);
        } completion:^(BOOL finished) {
            //fade out
            [UIView animateWithDuration:0.2f animations:^{
                self.activityPoints.transform = transform;
            } completion:^(BOOL finished) {
                self.activityPoints.font = [UIFont boldSystemFontOfSize:10.0f];
            }];
        }];
    }
}

#pragma mark - ()

-(void)setUserInfoAnalytics{
    
    // get user info for analytics
    NSString *displayName = [[PFUser currentUser] objectForKey:@"displayName"] != nil ? [[PFUser currentUser] objectForKey:@"displayName"] : @"";
    NSString *currentUserObjectId = [[PFUser currentUser] objectId] != nil ? [[PFUser currentUser] objectId] : @"";
    
    NSLog(@"%@", displayName);
    NSString *email = [[PFUser currentUser] objectForKey:@"email"] != nil ? [[PFUser currentUser] objectForKey:@"email"] : @"";
    NSString *industry = [[PFUser currentUser] objectForKey:@"industry"] != nil ? [[PFUser currentUser] objectForKey:@"industry"] : @"";
    NSDate *createdAt = [[PFUser currentUser] createdAt];
    
    NSString *isAdmin = @"No";
    
    // Mxpanel analytics identify: must be called before
    // people properties can be set
    [[Mixpanel sharedInstance] identify:currentUserObjectId];
    
    // info for crashes
    [Crashlytics setUserName:displayName];
    [Crashlytics setUserEmail:email];
    
    // mixpanel analytics - Sets user
    [[Mixpanel sharedInstance].people set:@{@"$name": displayName, @"$email": email, @"industry": industry, @"created": createdAt, @"userObjId": currentUserObjectId}];
    
    // super properties
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"Name": displayName}];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"Industry": industry}];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"Email": email}];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"UserObjId": currentUserObjectId}];
    
    
    // add admin property if one of us
    if([currentUserObjectId isEqualToString:@"3KiW2NoGuT"] || [currentUserObjectId isEqualToString:@"rblDQcdZcY"] || [currentUserObjectId isEqualToString:@"vB648p1bT1"] || [currentUserObjectId isEqualToString:@"EFGqHAIxLm"]){
        isAdmin = @"Yes";
    }
    
    // set admin property
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"Admin": isAdmin}];
    
    /* Following three methods are to identify a user. These user properties will be viewable on the konotor web dashboard */
    [Konotor setUserName:displayName]; // To set an identifiable name for the user
    [Konotor setUserEmail:email]; //To set user's email id
    [Konotor setUserIdentifier:currentUserObjectId]; // To set the user's identifier unique to your system
    
    // set user id for flight recorder
    [[FlightRecorder sharedInstance] setSessionUserID:displayName];
    
    // registers dummy users.
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        [Intercom registerUnidentifiedUser];
        return;
    }
    
    // set intercom properties for real users.
    
    [Intercom registerUserWithUserId:currentUserObjectId];
    [Intercom updateUserWithAttributes:@{
                                         @"name": displayName,
                                         @"email" : email,
                                         @"custom_attributes":@{@"industry": industry, @"admin": isAdmin},
                                         }];
}

- (void)inviteFriendsButtonAction:(id)sender {
    FollowersFollowingViewController *detailViewController = [[FollowersFollowingViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)promptFeedback:(id)sender{
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        PAPLoginSelectionViewController *loginSelectionViewController = [[PAPLoginSelectionViewController alloc] initWithNibName:@"PAPLoginSelectionViewController" bundle:nil];
        [self.view.window.rootViewController presentViewController:loginSelectionViewController animated:YES completion:nil];
        return;
    }
    
    [SVProgressHUD show];
    
    NSArray *activityItems = @[self];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
    [activityVC setValue:@"Join me on Teamstory!" forKey:@"subject"];
    
    [self.navigationController presentViewController:activityVC animated:YES completion:^{
        [SVProgressHUD dismiss];
    }];
    
    // this gets handled after an activity is completed.
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if (completed) {
            if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
                
                [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Shared Post", @"Source": @"Discover", @"Platform": @"Facebook"}];
                
                NSLog(@"facebook");
            } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
                
                [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Shared Post", @"Source": @"Discover", @"Platform": @"Twitter"}];
                
                NSLog(@"twitter");
            } else if ([activityType isEqualToString:UIActivityTypeMail]) {
                
                [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Shared Post", @"Source": @"Discover", @"Platform": @"Email"}];
                
                NSLog(@"email");
            } else {
                // all other activities.
            }
        }
    }];
    
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)])
    {
        // iOS 8+
        UIPopoverPresentationController *presentationController = [activityVC popoverPresentationController];
        presentationController.sourceView = self.view; // if button or change to self.view.
    }
}

-(void)notificationBarButton:(id)sender {
    [[PAPCache sharedCache] notificationCache:notificationContent];
    
    if (notificationPhoto) {
        PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:notificationPhoto source:@"Notification"];
        
        // hides tab bar so we can add custom keyboard
        photoDetailsVC.hidesBottomBarWhenPushed = YES;
        
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
    //[self.logoBtn setHidden:isHidden];
    [self.activityPoints setHidden:isHidden];
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
            
            // make sure index path supplied is within the feed's bounds and feed has objects
            if (lastViewdIndexPath.section <= [super.feed numberOfSections] && super.objects.count > 0){
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
}

# pragma UIActivityViewControllerDelegate
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        NSString *theText = @"Join me and hundreds of #entrepreneurs and #founders on @teamstory!:goo.gl/F2QSoJ" ;
        return theText;
    }
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        NSString *theText;
        theText = @"Join me and hundreds of #entrepreneurs and #founders on @teamstoryapp!:goo.gl/F2QSoJ";
        return theText;
    }
    
    return @"Join me and hundreds of entrepreneurs and founders on teamstoryapp!:http://goo.gl/F2QSoJ";
}





@end
