//
//  PAPAccountViewController.m
//  Teamstory
//
//

#import "PAPAccountViewController.h"
#import "PAPLoadMoreCell.h"
#import "PAPSettingsButtonItem.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPwebviewViewController.h"
#import "FollowersFollowingViewController.h"
#import "PAPMessagingViewController.h"
#import "ProfileSettingViewController.h"
#import "PAPLoginSelectionViewController.h"
#import "PAPTabBarController.h"

#define SPACE_FOR_COUNTS 10
#define FIRST_X_POS 15
#define MAX_LABEL_WIDTH 290
#define VERTICAL_SPACE_FOR_MULTI_LINE 15

@interface PAPAccountViewController() {
    float alphaValue_twitter;
    float alphaValue_angellist;
    float alphaValue_linkedin;
    BOOL button_enable_twitter;
    BOOL button_enable_angellist;
    BOOL button_enable_linkedin;

    CGSize website_expectedSize;
}
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *locationIconImageView;
@property (nonatomic, strong) UILabel *userDisplayName;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) PFFile* imageFile;
@property (nonatomic, strong) NSString *locationInfo;
@property (nonatomic, strong) NSString *descriptionInfo;
@property (nonatomic, strong) NSString *websiteInfo;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) UILabel *userDisplayNameLabel;
@property (nonatomic, strong) UILabel *followerCountLabel;
@property (nonatomic, strong) UILabel *followingCountLabel;
@property (nonatomic, strong) UIButton *websiteLink;
@property (nonatomic, strong) NSString *industry;
@property (nonatomic, strong) UILabel *industryLabel;
@property (nonatomic, strong) NSString *linkedin_url;
@property (nonatomic, strong) NSString *angellist_url;
@property (nonatomic, strong) NSString *twitter_url;
@property (nonatomic, strong) UIButton *angellist_button;
@property (nonatomic, strong) UIButton *twitter_button;
@property (nonatomic, strong) UIButton *linkedIn_button;
@property (nonatomic, strong) UIView *whiteBackground;
@property (nonatomic, strong) UIButton *multiActionButton;
@property (nonatomic, strong) UILabel *locationSiteSeparator;
@property (nonatomic, strong) UILabel *accountTitleLabel;
@property (nonatomic, strong) UIViewController *headerContainerViewController;
@property (nonatomic, strong) UIView *multiActionContainerView;
@property int userStatUpdateCount;
@property BOOL isProfileOwner;
@property BOOL refreshInfo;
@property float firstXPos;
@property float firstYPos;

@end

@implementation PAPAccountViewController
@synthesize headerView;
@synthesize user;
@synthesize textField;
@synthesize userDisplayName;
@synthesize locationLabel;
@synthesize imageFile;
@synthesize locationInfo;
@synthesize currentUser;
@synthesize descriptionInfo;
@synthesize descriptionLabel;
@synthesize settingsActionSheetDelegate;
@synthesize websiteInfo;
@synthesize navController;
@synthesize displayName;
@synthesize userDisplayNameLabel;
@synthesize websiteLink;
@synthesize industry;
@synthesize industryLabel;
@synthesize twitter_url;
@synthesize angellist_url;
@synthesize linkedin_url;
@synthesize angellist_button;
@synthesize twitter_button;
@synthesize linkedIn_button;
@synthesize whiteBackground;


#if DEBUG
static NSString *const kevin_account = @"wKx1GsCnSq";
static NSString *const justin_account = @"WUZTy3Ayxy";
static NSString *const freddy_account = @"4Su2vXzhFq";
#else
static NSString *const kevin_account = @"3KiW2NoGuT";
static NSString *const justin_account = @"vB648p1bT1";
static NSString *const freddy_account = @"rblDQcdZcY";
#endif



#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // check if user in profile owns the profile
    self.isProfileOwner = [[[PFUser currentUser] objectId] isEqualToString:[self.user objectId]];
    
    // Handling anonymous users.
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] && [[self.user objectForKey:@"displayName"] length] == 0){
            PAPLoginSelectionViewController *loginSelectionViewController = [[PAPLoginSelectionViewController alloc] initWithNibName:@"PAPLoginSelectionViewController" bundle:nil];
	        [self.navigationController presentViewController:loginSelectionViewController animated:YES completion:nil];
        return;
    }
    
    [self createPageViewController];
    
    // remove refresh control for home that's set by default in inherited timeline
    [self.refreshControl removeFromSuperview];

    // change extended background color to match header
    self.extendBgView.backgroundColor = [UIColor colorWithRed:73.0f/255.0f green:174.0f/255.0f blue:137.0f/255.0f alpha:1.0f];
    
    // hide default back button
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    self.accountTitleLabel = [[UILabel alloc] initWithFrame:self.navigationItem.titleView.frame];
    self.accountTitleLabel.text = [self.user objectForKey:@"displayName"];
    self.accountTitleLabel.textColor = [UIColor whiteColor];
    self.accountTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.accountTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.accountTitleLabel sizeToFit];
    
     self.navigationItem.titleView = self.accountTitleLabel;
    
    [self.navigationItem.titleView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapNavTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTop)];
    [self.navigationItem.titleView addGestureRecognizer:tapNavTitle];

    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    
    if (self.user != [PFUser currentUser]){
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
        [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }else{
        self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    }
    
    [self setHeaderDefault];

    [SVProgressHUD show];
    
    [self loadMemberInfo:^(BOOL success){
        if(success){
            
            // show properties
            [self displayMemberValuesForLayout];
            
            // add completed view to header
            self.feed.tableHeaderView = self.headerContainerViewController.view;
            
        }else{
            [self showLoadingError];
        }
        
        [SVProgressHUD dismiss];
    }];
    
    // flag to make sure pulling of info only happens once per screen view for both owner and other member's profiles. See note in viewWillAppear
    self.refreshInfo = NO;
}

- (void)showFollowers:(id)selector{
    
    FollowersFollowingViewController *showFollowers = [[FollowersFollowingViewController alloc]initWithStyle:UITableViewStylePlain type:@"followers" forUser:self.user];
    [self.navigationController pushViewController:showFollowers animated:YES];
}

- (void)showFollowing:(id)selector{
    FollowersFollowingViewController *showFollowing = [[FollowersFollowingViewController alloc]initWithStyle:UITableViewStylePlain type:@"following" forUser:self.user];
    
    [self.navigationController pushViewController:showFollowing animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    // analytics
    [super viewWillAppear:YES];
    
    // google analytics
    [PAPUtility captureScreenGA:@"Account"];
    
    ((PAPTabBarController *)self.tabBarController).postMenuButton.hidden = YES;
    
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] && ([[PFUser currentUser] objectForKey:@"description"] == nil || [[PFUser currentUser] objectForKey:@"industry"] == nil || [[PFUser currentUser] objectForKey:@"location"] == nil) && [[self.user objectForKey:@"displayName"] isEqualToString:[[PFUser currentUser] objectForKey:@"displayName"]]) {
        NSDate *profileUpdateDate = [[PFUser currentUser] objectForKey:@"profileUpdate"];
        NSDate *currentDate = [NSDate date];
        
        NSTimeInterval distanceBetweenDatesProfile = [currentDate timeIntervalSinceDate:profileUpdateDate];
        float profileGlowTimeFrame = 7*24*60*60; //every 7 days
        
        if (distanceBetweenDatesProfile > profileGlowTimeFrame || profileUpdateDate == nil) {
            
            // mixpanel analytics
            [[Mixpanel sharedInstance] track:@"Showed Edit Profile Alert" properties:@{}];
            
            // flightrecorder event analytics
            [[FlightRecorder sharedInstance] trackEventWithCategory:@"showed_edit_profile" action:@"" label:@"" value:@""];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hi there!" message:@"Did you know that filling out your profile completely gets you noticed more?" delegate:self cancelButtonTitle:@"Maybe Later" otherButtonTitles:@"Edit Profile", nil];
            [alertView show];
        }
    }
    
    [self updateLastVisit];

        
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Account"}];
    
    
    // flightrecorder analytics
   [[FlightRecorder sharedInstance] trackPageView:@"Account"];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"account_screen" action:@"viewing_account" label:@"" value:@""];
    
    // edge case, if multiaction button frozen because of network problems
    if (self.user == [PFUser currentUser] && !self.multiActionButton.enabled){
        self.multiActionButton.enabled = YES;
    }

    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    
    /* Refactor: profile should get refreshed after it's content changes. For now, it refreshes every time view appears AFTER first run (pulls from viewdidload). Note: only in member's own profile does view stay loaded. On other profiles, the controller is re-created every time so this ensures data fetch will only happen once. */
    
    if(self.refreshInfo){
        [SVProgressHUD show];
        
        [self loadMemberInfo:^(BOOL success){
            if(success){
                // show properties
                [self displayMemberValuesForLayout];

            }else{
                [self showLoadingError];
            }
            
            [SVProgressHUD dismiss];
        }];
    }else{
        self.refreshInfo = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    ((PAPTabBarController *)self.tabBarController).postMenuButton.hidden = NO;
    [[self.navigationController.tabBarController.viewControllers objectAtIndex:4] tabBarItem].image = [[UIImage imageNamed:@"nav_profile.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - Set Default For Header Elements

- (void)setHeaderDefault{
    [self setProfileImageDefault];
    [self setDescriptionDefault];
    [self setIndustryDefault];
    [self setWebsiteDefault];
    [self setPointsDefault];
    
    [self setFollowDefault];
    [self setFollowAction];
    
    [self setSocialIconsDefault];
    [self setSocialAction];
}

- (void)setDescriptionDefault{
    self.firstHeaderViewController.descriptionLabel.text = @"";
}

- (void)setProfileImageDefault{
    
    // round frame
    self.firstHeaderViewController.profilePictureImageView.layer.cornerRadius = self.firstHeaderViewController.profilePictureImageView.frame.size.width / 2;
    self.firstHeaderViewController.profilePictureImageView.clipsToBounds = YES;
}

- (void)setIndustryDefault{
    
    // hide title & set value to none
    self.secondHeaderViewController.industryLabel.hidden = YES;
    self.secondHeaderViewController.industryInfo.text = @"";
}

- (void)setWebsiteDefault{
    [self.firstHeaderViewController.websiteLink addTarget:self action:@selector(websiteLinkAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setPointsDefault{
    [self.firstHeaderViewController.pointCountLabel setText:@""];
}

- (void)setFollowDefault{
    
    // follower default count
    [self.firstHeaderViewController.followerCountLabel setText:@""];
    
    // following default count
    [self.firstHeaderViewController.followingCountLabel setText:@""];
}


- (void)setSocialIconsDefault{
    
    // twitter
    alphaValue_twitter = 0.4f;
    button_enable_twitter = NO;
    
    // angellist
    alphaValue_angellist = 0.4f;
    button_enable_angellist = NO;
    
    // linked
    alphaValue_linkedin = 0.4f;
    button_enable_linkedin = NO;
    
    // default disabled social buttons
    [self.secondHeaderViewController.linkedIn setAlpha:alphaValue_linkedin];
    self.secondHeaderViewController.linkedIn.enabled = button_enable_linkedin;
    
    [self.secondHeaderViewController.twitter setAlpha:alphaValue_twitter];
    self.secondHeaderViewController.twitter.enabled = button_enable_twitter;
    
    [self.secondHeaderViewController.angelList setAlpha:alphaValue_angellist];
    self.secondHeaderViewController.angelList.enabled = button_enable_angellist;
}

- (void)setSocialAction{
    
    [self.secondHeaderViewController.linkedIn addTarget:self action:@selector(linkedin_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondHeaderViewController.twitter addTarget:self action:@selector(twitter_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondHeaderViewController.angelList addTarget:self action:@selector(angellist_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setFollowAction{
    
    // taps for followers/following section, all point to same method
    // should be refactored to use file's delegate
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowers:)];
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowers:)];
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowing:)];
    UITapGestureRecognizer *tap6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowing:)];
    
    // Title
    [self.firstHeaderViewController.followerLabel addGestureRecognizer:tap3];
    
    // Count
    [self.firstHeaderViewController.followerCountLabel addGestureRecognizer:tap4];
    
    
    // Following label & count
    
    // Title
    [self.firstHeaderViewController.followingLabel addGestureRecognizer:tap5];
    
    // Count
    [self.firstHeaderViewController.followingCountLabel addGestureRecognizer:tap6];
    
}

#pragma mark - Pull & Display Member Info


- (void)loadMemberInfo:(void (^)(BOOL success))complete{

    [self.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if(!error){
            
            self.user = (PFUser *)object;
            self.imageFile = [self.user objectForKey:@"profilePictureMedium"];
            self.locationInfo = [self.user objectForKey:@"location"];
            self.descriptionInfo = [self.user objectForKey:@"description"];
            self.websiteInfo = [self.user objectForKey:@"website"];
            self.displayName = [self.user objectForKey:@"displayName"];
            self.industry = [self.user objectForKey:@"industry"];
            self.linkedin_url = [self.user objectForKey:@"linkedin_url"];
            self.twitter_url = [self.user objectForKey:@"twitter_url"];
            self.angellist_url = [self.user objectForKey:@"angellist_url"];
            
            return complete(YES);
        }else{
            return complete(NO);
        }
    }];
}

- (void)displayMemberValuesForLayout{
    
    // show profile image
    [self displayMemberProfilePic];
    
    // show location & website
    [self displayLocationAndWebsite];
    
    // show follower/following
    [self displayFollower];
    [self displayFollowing];
    
    // show bio
    [self displayDescription];
    
    // show points
    [self displayPoints];
    
    // show social icons
    [self displaySocialIcons];
    
    // show industry
    [self displayIndustry];
    
    // show follow/message button & follow relation when visiting someone's profile
    if (!self.isProfileOwner) {
        [self displayMoreActionBtn];
        [self displayFollowRelationToOwner];
    }
}

- (void)displayMemberProfilePic{
    
    if(self.imageFile){
        [self.firstHeaderViewController.profilePictureImageView setFile:[self.user objectForKey:@"profilePictureMedium"]];
        [self.firstHeaderViewController.profilePictureImageView loadInBackground];
    }
}

- (void)displayFollowing{
    
    // following count
    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
    if (followingDictionary) {
        [self.firstHeaderViewController.followingCountLabel setText:[NSString stringWithFormat:@"%d", (int)[[followingDictionary allValues] count]]];
    }
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyNetworkElseCache];
    
    // get followers for current user
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self.firstHeaderViewController.followingCountLabel setText:[NSString stringWithFormat:@"%d", number]];
            [self.firstHeaderViewController.followingCountLabel sizeToFit];
            
            [self.firstHeaderViewController.followingLabel setFrame:CGRectMake(self.firstHeaderViewController.followingCountLabel.frame.origin.x + self.firstHeaderViewController.followingCountLabel.frame.size.width + SPACE_FOR_COUNTS, self.firstHeaderViewController.followingLabel.frame.origin.y, self.firstHeaderViewController.followingLabel.frame.size.width, self.firstHeaderViewController.followingLabel.frame.size.height)];
        }
    }];
}

- (void)displayFollower{
    
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyNetworkElseCache];
    
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self.firstHeaderViewController.followerCountLabel setText:[NSString stringWithFormat:@"%d",number]];
            [self.firstHeaderViewController.followerCountLabel sizeToFit];
            
            [self.firstHeaderViewController.followerLabel setFrame:CGRectMake(self.firstHeaderViewController.followerCountLabel.frame.origin.x + self.firstHeaderViewController.followerCountLabel.frame.size.width + SPACE_FOR_COUNTS, self.firstHeaderViewController.followerLabel.frame.origin.y, self.firstHeaderViewController.followerLabel.frame.size.width, self.firstHeaderViewController.followerLabel.frame.size.height)];
        }
    }];
}

- (void)displayDescription{
    
    // set description
    if(self.descriptionInfo.length > 0){
        self.firstHeaderViewController.descriptionLabel.text = self.descriptionInfo;
    }else{
        [self setDescriptionDefault];
    }
}

- (void)displayPoints{
    
    // get activity points for profile owner
    NSNumber *activityPoints = self.isProfileOwner ? [[AtMention sharedAtMention] activityPoints] : [self.user objectForKey:@"activityPoints"];
    
    if(activityPoints){
        [self.firstHeaderViewController.pointCountLabel setText:[activityPoints stringValue]];
        [self.firstHeaderViewController.pointCountLabel sizeToFit];
        
        [self.firstHeaderViewController.pointLabel setFrame:CGRectMake(self.firstHeaderViewController.pointCountLabel.frame.origin.x + self.firstHeaderViewController.pointCountLabel.frame.size.width + SPACE_FOR_COUNTS, self.firstHeaderViewController.pointLabel.frame.origin.y, self.firstHeaderViewController.pointLabel.frame.size.width, self.firstHeaderViewController.pointLabel.frame.size.height)];
    }else{
        [self setPointsDefault];
    }
}

- (void)displaySocialIcons{
    
    // enable/disable social icons based on server default or empty
    if ([self.twitter_url length] > 0 && ![self.twitter_url isEqualToString:@"https://twitter.com/"]) {
        alphaValue_twitter = 1.0f;
        button_enable_twitter = YES;
    }else if(alphaValue_twitter != 0.4f){
        alphaValue_twitter = 0.4f;
        button_enable_twitter = NO;
    }
    
    if ([self.angellist_url length] > 0 && ![self.angellist_url isEqualToString:@"https://angel.co/"]) {
        alphaValue_angellist = 1.0f;
        button_enable_angellist = YES;
    }else if(alphaValue_angellist != 0.4f){
        alphaValue_angellist = 0.4f;
        button_enable_angellist = NO;
    }
    
    if ([self.linkedin_url length] > 0 && ![self.linkedin_url isEqualToString:@"https://linkedin.com/in/"]) {
        alphaValue_linkedin = 1.0f;
        button_enable_linkedin = YES;
    }else if(alphaValue_linkedin != 0.4f){
        alphaValue_linkedin = 0.4f;
        button_enable_linkedin = NO;
    }
    
    [self.secondHeaderViewController.linkedIn setAlpha:alphaValue_linkedin];
    self.secondHeaderViewController.linkedIn.enabled = button_enable_linkedin;
    
    [self.secondHeaderViewController.twitter setAlpha:alphaValue_twitter];
    self.secondHeaderViewController.twitter.enabled = button_enable_twitter;

    [self.secondHeaderViewController.angelList setAlpha:alphaValue_angellist];
    self.secondHeaderViewController.angelList.enabled = button_enable_angellist;
}

- (void)displayIndustry{
    
    if(self.industry.length > 0){
        
        // show/hide industry label
        self.secondHeaderViewController.industryLabel.hidden = NO;
        
        // industry label
        self.secondHeaderViewController.industryInfo.text = self.industry;
    }else{
        [self setIndustryDefault];
    }
}

- (void)displayMoreActionBtn{
    
    UIImage *messageButtonImage = [UIImage imageNamed:@"btn_message.png"];
    
    // resize button to message and follow size (assuming both stay the same) - hurts my soul :(
    self.multiActionButton.frame = CGRectMake(self.multiActionButton.frame.origin.x, self.multiActionButton.frame.origin.y, messageButtonImage.size.width, self.multiActionButton.frame.size.height);
    
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [messageButton setImage:[UIImage imageNamed:@"btn_message"] forState:UIControlStateNormal];
    
    [messageButton setFrame:CGRectMake(self.multiActionButton.frame.origin.x + self.multiActionButton.frame.size.width + 10, self.multiActionButton.frame.origin.y, messageButtonImage.size.width, messageButtonImage.size.height)];
    [messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [messageButton setImage:messageButtonImage forState:UIControlStateNormal];
    
    [messageButton setImage:[UIImage imageNamed:@"btn_message_tapped"] forState:UIControlStateSelected];
    
    [self.multiActionContainerView addSubview:messageButton];
}

- (void)displayFollowRelationToOwner{
    
    // check if the currentUser is following this user
    PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryIsFollowing setCachePolicy:kPFCachePolicyNetworkElseCache];
    [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error && [error code] != kPFErrorCacheMiss) {
            NSLog(@"Couldn't determine follow relationship: %@", error);
            self.navigationItem.rightBarButtonItem = nil;
        } else {
            if (number == 0) {
                [self configureFollowButton];
            } else {
                [self configureUnfollowButton];
            }
        }
    }];
    
}


#pragma mark - Button Actions

-(void)messageButtonAction:(id)sender {
    [SVProgressHUD show];
    
    PFUser *aUser = self.user;
    PFQuery *userOneQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userOneQuery whereKey:@"userOne" equalTo:[PFUser currentUser]];
    [userOneQuery whereKey:@"userTwo" equalTo:aUser];
    
    // Received Message
    PFQuery *userTwoQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userTwoQuery whereKey:@"userOne" equalTo:aUser];
    [userTwoQuery whereKey:@"userTwo" equalTo:[PFUser currentUser]];
    
    PFQuery *finalChatRoomQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userOneQuery, userTwoQuery,nil]];
    [finalChatRoomQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [SVProgressHUD dismiss];
        
        if (!error) {
                PAPMessagingViewController *messageViewController = [[PAPMessagingViewController alloc] init];
                NSString *userNumber;
                
                if ([[[object objectForKey:@"userOne"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                    userNumber = @"userTwo";
                } else {
                    userNumber = @"userOne";
                }
                
                [messageViewController setTargetUser:aUser setUserNumber:userNumber];
                [messageViewController setRoomInfo:object];
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:messageViewController animated:NO];
        } else {
            if ([error code] == 101) {
                PFObject *createChatRoom = [PFObject objectWithClassName:@"ChatRoom"];
                [createChatRoom setObject:[PFUser currentUser] forKey:@"userOne"];
                [createChatRoom setObject:aUser forKey:@"userTwo"];
                
                // setACL;
                PFACL *chatRoomACL = [PFACL ACLWithUser:[PFUser currentUser]];
                [chatRoomACL setPublicWriteAccess:YES];
                [chatRoomACL setPublicReadAccess:YES];
                createChatRoom.ACL = chatRoomACL;
                
                [createChatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [self dismissViewControllerAnimated:NO completion:^{
                            PAPMessagingViewController *messageViewController = [[PAPMessagingViewController alloc] init];
                            [messageViewController setTargetUser:aUser setUserNumber:@"userTwo"];
                            [messageViewController setRoomInfo:createChatRoom];
                            
                            //[self setHidesBottomBarWhenPushed:YES];
                            
                            [self.navigationController pushViewController:messageViewController animated:NO];
                        }];
                    } else {
                        NSLog(@"%@", error);
                    }
                }];
            } else {
                NSLog(@"%@", error);
            }
        }
    }];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)websiteLinkAction:(id)sender{
    NSString *http = @"http://";
    //window does not work with only urls. Must append "http://".
    if ([self.websiteInfo rangeOfString:@"(?i)http" options:NSRegularExpressionSearch].location == NSNotFound) {
        self.websiteInfo = [NSString stringWithFormat:@"%@%@", http, self.websiteInfo];
    }
    
    PAPwebviewViewController *webviewController = [[PAPwebviewViewController alloc] initWithWebsite:self.websiteInfo];
    webviewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webviewController animated:YES];

}

- (void)twitter_buttonAction:(id)sender {
    NSLog(@"twitter button pressed");
    PAPwebviewViewController *webviewController = [[PAPwebviewViewController alloc] initWithWebsite:self.twitter_url];
    webviewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webviewController animated:YES];
}

- (void)angellist_buttonAction:(id)sender {
        NSLog(@"angellist button pressed");
    PAPwebviewViewController *webviewController = [[PAPwebviewViewController alloc] initWithWebsite:self.angellist_url];
    webviewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webviewController animated:YES];
}

- (void)linkedin_buttonAction:(id)sender {
        NSLog(@"linkedin button pressed");
    PAPwebviewViewController *webviewController = [[PAPwebviewViewController alloc] initWithWebsite:self.linkedin_url];
    webviewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webviewController animated:YES];
}


- (void)settingsButtonAction:(id)sender {
    self.settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    
    if ([[self.user objectId] isEqualToString:kevin_account] || [[self.user objectId] isEqualToString:justin_account] || [[self.user objectId] isEqualToString:freddy_account]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"About This Version",@"Privacy Policy",@"Terms of Use",@"Log Out", @"Notification Control", nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"About This Version",@"Privacy Policy",@"Terms of Use",@"Log Out", nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)editProfileAction:(id)sender{
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Selected Edit Profile" properties:@{@"Source": @"Edit Button"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"selected_edit_profile" action:@"edit_button" label:@"" value:@""];
    
    ProfileSettingViewController *profileViewController = [[ProfileSettingViewController alloc] initWithNibName:@"ProfileSettingViewController" bundle:nil];
    profileViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void) updateLastVisit {
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        [[PFUser currentUser] setObject:[NSDate date]  forKey:@"profileUpdate"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Saved successfully current Date:%@", [[PFUser currentUser] objectForKey:@"discoverUpdate"]);
            } else {
                NSLog(@"error: %@", error);
            }
        }];
    }
}


#pragma mark - Layout

- (void)displayLocationAndWebsite{
    
    // set variables
    BOOL isLoc = self.locationInfo.length > 0;
    BOOL isWeb = self.websiteInfo.length > 0;
    
    BOOL isBoth = isLoc && isWeb;
    BOOL isOnlyLoc = isLoc && !isWeb;
    BOOL isOnlyWeb = !isLoc && isWeb;
    
    // default visibility
    [self.firstHeaderViewController.seperatorLabel setHidden:YES];
    [self.firstHeaderViewController.websiteLink setHidden:NO];
    [self.firstHeaderViewController.locationLabel setHidden:NO];
    
    if(isBoth){
        self.firstHeaderViewController.locationLabel.text = self.locationInfo;
        [self.firstHeaderViewController.websiteLink setTitle:self.websiteInfo forState:UIControlStateNormal];
    }else if(isOnlyLoc){
        [self.firstHeaderViewController.websiteLink setHidden:YES];
        
        self.firstHeaderViewController.locationLabel.text = self.locationInfo;
    }else if(isOnlyWeb){
        [self.firstHeaderViewController.locationLabel setHidden:YES];
        
        [self.firstHeaderViewController.websiteLink setTitle:self.websiteInfo forState:UIControlStateNormal];
    }else{
        [self.firstHeaderViewController.locationLabel setHidden:YES];
        [self.firstHeaderViewController.websiteLink setHidden:YES];
    }
    
    [self resizeLocationAndWebsite];
    [self setFrameForElements:self.firstHeaderViewController.locationLabel elem2:self.firstHeaderViewController.websiteLink];
}

- (void)resizeLocationAndWebsite{
    
    // change label size to fit server data
    [self.firstHeaderViewController.locationLabel sizeToFit];
    [self.firstHeaderViewController.websiteLink sizeToFit];
    
    /* Truncate tails that go over our max width. Used for labels set before latest version.Should not happen with new accounts 'cos of max character validation check */
     
    if(self.firstHeaderViewController.locationLabel.frame.size.width > MAX_LABEL_WIDTH){
        [self.firstHeaderViewController.locationLabel setFrame:CGRectMake(self.firstHeaderViewController.locationLabel.frame.origin.x, self.firstHeaderViewController.locationLabel.frame.origin.y, MAX_LABEL_WIDTH, self.firstHeaderViewController.locationLabel.frame.size.height)];
    }
    
    if(self.firstHeaderViewController.websiteLink.frame.size.width > MAX_LABEL_WIDTH){
        [self.firstHeaderViewController.websiteLink setFrame:CGRectMake(self.firstHeaderViewController.websiteLink.frame.origin.x, self.firstHeaderViewController.websiteLink.frame.origin.y, MAX_LABEL_WIDTH, self.firstHeaderViewController.websiteLink.frame.size.height)];
    }
}

- (void)setFrameForElements:(UIView *)elem1 elem2:(UIView *)elem2{
    
    // set variables
    BOOL isElem1 = ![elem1 isHidden];
    BOOL isElem2 = ![elem2 isHidden];
    
    float sepWidth = self.firstHeaderViewController.seperatorLabel.frame.size.width;
    
    float remainingSpace = 0;
    float totalWidth = 0;

    // find out which element is present (case 1: both, case 2: elem1, case 3: elem2)
    BOOL isBothElem = isElem1 && isElem2;
    BOOL isOnlyElem1 = isElem1 && !isElem2;
    BOOL isOnlyElem2 = !isElem1 && isElem2;
    
    // sum width for present elements
    if(isElem1){
        totalWidth += elem1.frame.size.width;
    }
    
    if(isElem2){
        totalWidth += elem2.frame.size.width;
    }
    
    // check if both elements are present and sum seperator
    if(isElem1 && isElem2){
        totalWidth += sepWidth;
    }
    
    // calc remaining space
    remainingSpace = MAX_LABEL_WIDTH - totalWidth;
        
    // check if total width is under remaining space
    if(remainingSpace >= 0){
        
        // we have enough space to put both location and website on the same line
        
        // both are present so we place elements and show seperator
        if(isBothElem){

            elem1.frame = CGRectMake(FIRST_X_POS, elem1.frame.origin.y, elem1.frame.size.width, elem1.frame.size.height);
            
            self.firstHeaderViewController.seperatorLabel.frame = CGRectMake(elem1.frame.origin.x + elem1.frame.size.width, self.firstHeaderViewController.seperatorLabel.frame.origin.y, self.firstHeaderViewController.seperatorLabel.frame.size.width, self.firstHeaderViewController.seperatorLabel.frame.size.height);
            
            elem2.frame = CGRectMake(self.firstHeaderViewController.seperatorLabel.frame.origin.x + self.firstHeaderViewController.seperatorLabel.frame.size.width, elem1.frame.origin.y, elem2.frame.size.width, elem1.frame.size.height);
            
            [self.firstHeaderViewController.seperatorLabel setHidden:NO];
            
        }else if(isOnlyElem1){
            elem1.frame = CGRectMake(FIRST_X_POS, self.firstYPos, elem1.frame.size.width, elem1.frame.size.height);
        }else if(isOnlyElem2){
            elem2.frame = CGRectMake(FIRST_X_POS, self.firstYPos, elem2.frame.size.width, elem1.frame.size.height);
        }
    }else{
        if(isBothElem){
            
            [self.firstHeaderViewController.seperatorLabel setHidden:YES];
            
            // get y position of first label so we can place second underneath
            float profileImageViewY = self.firstHeaderViewController.profilePictureImageView.frame.origin.y;
            float profileImageViewHeight = self.firstHeaderViewController.profilePictureImageView.frame.size.height;
            float multiLineYPos = profileImageViewY + profileImageViewHeight + VERTICAL_SPACE_FOR_MULTI_LINE;
            
            elem1.frame = CGRectMake(FIRST_X_POS, multiLineYPos, elem1.frame.size.width, elem1.frame.size.height);
            elem2.frame = CGRectMake(FIRST_X_POS, multiLineYPos + elem1.frame.size.height, elem2.frame.size.width, elem2.frame.size.height);
        }else{
            
            /*  Occurs when location or website is longer than our allowed space. Should not happen with new accounts 'cos of max character validation check. Edge case. */
            
            if(isOnlyElem1){
                elem1.frame = CGRectMake(FIRST_X_POS, self.firstYPos, elem1.frame.size.width, elem1.frame.size.height);
            }else if(isOnlyElem2){
                elem2.frame = CGRectMake(FIRST_X_POS, self.firstYPos, elem2.frame.size.width, elem2.frame.size.height);
            }
        }
    }
}



#pragma mark - Datasource 

- (void)loadObjects:(void (^)(BOOL succeeded))completionBlock isRefresh:(BOOL)isRefresh fromSource:(NSString *)fromSource{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:kPAPPhotoUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kPAPPhotoUserKey];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        self.objects = [NSMutableArray arrayWithArray:objects];
        
        if(completionBlock){
            completionBlock([super objectsDidLoad:error]);
        }else{
            [super objectsDidLoad:error];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark - ()

- (void)showLoadingError{
    
    // notify member of account load fail
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Account info failed to load. Try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)scrollToTop{
    
    // scroll to top with header view incl.
    [self.feed scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}


- (void)followButtonAction:(id)sender {
    
    NSString *followedUserDisplayName = [self.user objectForKey:@"displayName"] != nil ? [self.user objectForKey:@"displayName"]: @"";
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Followed User", @"Source": @"Profile", @"Followed User" : followedUserDisplayName}];
    
    
    // intercome analytics
    [Intercom logEventWithName:@"followed-user" metaData:@{@"followed": followedUserDisplayName, @"source": @"accountview"}];

    
    // increment user follow count by one
    [[Mixpanel sharedInstance].people increment:@"Follow Count" by:[NSNumber numberWithInt:1]];
    
    // disable button until finished unfollow
    self.multiActionButton.enabled = NO;
    
    [self configureUnfollowButton];
    
    // show hud while numbers are refreshing
    [SVProgressHUD show];
    
    [PAPUtility followUserEventually:self.user setNavigationController:self.navigationController block:^(BOOL succeeded, NSError *error) {
        
        self.multiActionButton.enabled = YES;
        
        if (error) {
            [self configureFollowButton];
        }else if(succeeded){
        
            // refresh new count
            [self refreshFollowerCount:^(BOOL completed) {
                if(completed){
                    [SVProgressHUD dismiss];
                }
            }];
        }
    }];
}

- (void)unfollowButtonAction:(id)sender {
   
    // disable button until finished follow
    self.multiActionButton.enabled = NO;

    [self configureFollowButton];
    
    // show hud while numbers are refreshing
    [SVProgressHUD show];
    
    [PAPUtility unfollowUserEventually:self.user block:^(BOOL succeeded) {
        
        self.multiActionButton.enabled = YES;
        
        if (succeeded) {
            // refresh new count
            [self refreshFollowerCount:^(BOOL completed) {
                if(completed){
                    [SVProgressHUD dismiss];
                }
            }];
        }
    }];
}


- (void)configureFollowButton {
    
    self.multiActionButton.enabled = YES;
    
    [self.multiActionButton setImage:[UIImage imageNamed:@"btn_follow.png"] forState:UIControlStateNormal];
    [self.multiActionButton removeTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.multiActionButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [[PAPCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
    
self.multiActionButton.enabled = YES;
        
    [self.multiActionButton setImage:[UIImage imageNamed:@"btn_following.png"] forState:UIControlStateNormal];
    [self.multiActionButton removeTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.multiActionButton addTarget:self action:@selector(unfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [[PAPCache sharedCache] setFollowStatus:YES user:self.user];
}

-(void)refreshFollowerCount:(void (^)(BOOL))completed{
    
    // return completed when both queries have finished
    self.userStatUpdateCount = 0;
    
    // refresh follower count
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyNetworkElseCache];
 
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            
            [self.firstHeaderViewController.followerCountLabel setText:[NSString stringWithFormat:@"%d", number]];
            
            // increment and check if we're done updating
            self.userStatUpdateCount++;
            if(self.userStatUpdateCount > 1){
                completed(YES);
            }
        }
    }];
    
    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
    if (followingDictionary) {
        [self.followingCountLabel setText:[NSString stringWithFormat:@"%d", (int)[[followingDictionary allValues] count]]];
    }
    
    // refresh following count
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyNetworkElseCache];
  
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            
            [self.firstHeaderViewController.followingCountLabel setText:[NSString stringWithFormat:@"%d", number]];
            
            // increment and check if we're done updating
            self.userStatUpdateCount++;
            if(self.userStatUpdateCount > 1){
                 completed(YES);
            }
        }
    }];
}

#pragma mark - Page View Controller & Related Methods

- (void)createPageViewController{
    
    // create controllers for header
    FirstAccountHeaderViewController *firstAccountHeaderViewController = [[FirstAccountHeaderViewController alloc] initWithNibName:@"FirstAccountHeaderViewController" bundle:nil];
    self.firstHeaderViewController = firstAccountHeaderViewController;
    
    SecondAccountHeaderViewController *secondAccountHeaderViewController = [[SecondAccountHeaderViewController alloc] initWithNibName:@"SecondAccountHeaderViewController" bundle:nil];
    self.secondHeaderViewController = secondAccountHeaderViewController;
    
    // call view to load elements since we link action before view is showing - need to refactor
    [self.secondHeaderViewController view];
    [self.firstHeaderViewController view];
    
    
    self.firstYPos = self.firstHeaderViewController.locationLabel.frame.origin.y;
    
    // create container controller to hold all our subviews
    self.headerContainerViewController = [[UIViewController alloc]init];
    [self.headerContainerViewController.view setBackgroundColor:firstAccountHeaderViewController.view.backgroundColor];
    
    // create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.view.frame = self.firstHeaderViewController.view.frame;
    
    // set first controller for pageview
    NSArray *viewControllers = @[self.firstHeaderViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    // follow/unfollow/editprofile big button
    UIImage *editProfileBtn = [UIImage imageNamed:@"btn_edit_profile.png"];
    self.multiActionButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, editProfileBtn.size.width, editProfileBtn.size.height)];
    
    if(self.isProfileOwner){
        [self.multiActionButton setImage:editProfileBtn forState:UIControlStateNormal];
        [self.multiActionButton setImage:[UIImage imageNamed:@"btn_edit_profile_tapped"] forState:UIControlStateSelected];
    }else{
        
        [self.multiActionButton setImage:[UIImage imageNamed:@"btn_follow.png"] forState:UIControlStateNormal];
        [self.multiActionButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.multiActionButton.enabled = NO;
    }
    
    // create button that'll serve as edit and follow/following depending on owner
    self.multiActionButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.multiActionButton addTarget:self action:@selector(editProfileAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // container for our action buttons, needed to to change background and place below pageviewcontroller indicator
    self.multiActionContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.pageViewController.view.frame.size.height + 5, self.headerContainerViewController.view.frame.size.width, self.multiActionButton.frame.size.height + 20)];
    [self.multiActionContainerView setBackgroundColor:[UIColor whiteColor]];
    [self.multiActionContainerView addSubview:self.multiActionButton];
    
    // can't add space between table header and content so adding custom view
    UIView *seperatorView = [[UIView alloc]initWithFrame:CGRectMake(0, self.multiActionContainerView.frame.origin.y + self.multiActionContainerView.frame.size.height, self.view.frame.size.width, 35)];
    [seperatorView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    // set frame for overall header container
    [self.headerContainerViewController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.pageViewController.view.frame.size.height + self.multiActionContainerView.frame.size.height + seperatorView.frame.size.height)];

    [self.headerContainerViewController.view addSubview:self.pageViewController.view];
    [self.headerContainerViewController.view addSubview:self.multiActionContainerView];
    [self.headerContainerViewController.view addSubview:seperatorView];
    
    // add pageviewcontroller as a child to header container
    [self.headerContainerViewController addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self.headerContainerViewController];
    
    // add header container controller as a child to current controller
    [self addChildViewController:self.headerContainerViewController];
    [self.headerContainerViewController didMoveToParentViewController:self];

}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if([viewController isKindOfClass:(FirstAccountHeaderViewController.class)]){
        return nil;
    }else{
        return [self viewControllerAtIndex:0];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if([viewController isKindOfClass:(SecondAccountHeaderViewController.class)]){
        return nil;
    }else{
        return [self viewControllerAtIndex:1];
    }
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (index == 0){
        return self.firstHeaderViewController;
    }else if(index == 1){
        return self.secondHeaderViewController;
    }
    
    return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}


@end