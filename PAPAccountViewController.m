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
@property (nonatomic, strong) PFImageView *profilePictureImageView;
@property (nonatomic, strong) UIView *profilePictureBackgroundView;
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


@end

@implementation PAPAccountViewController
@synthesize headerView;
@synthesize user;
@synthesize textField;
@synthesize userDisplayName;
@synthesize locationLabel;
@synthesize imageFile;
@synthesize locationInfo;
@synthesize profilePictureImageView;
@synthesize profilePictureBackgroundView;
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
    
    // Handling anonymous users.
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] && [[self.user objectForKey:@"displayName"] length] == 0){
            PAPLoginSelectionViewController *loginSelectionViewController = [[PAPLoginSelectionViewController alloc] initWithNibName:@"PAPLoginSelectionViewController" bundle:nil];
	        [self.navigationController presentViewController:loginSelectionViewController animated:YES completion:nil];
        return;
    }
    
    [self createPageViewController];
    
    // remove refresh control for home that is set by default in inherited timeline
    [super.refreshControl removeFromSuperview];
    [self.feed setBounces:NO];
    
    // hide back button
    [self.navigationItem setHidesBackButton:YES];
    
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
    
    [SVProgressHUD show];
    
    // Location label
    //self.firstHeaderViewController.locationLabel.text = self.locationInfo;
    

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
            
            if ([websiteInfo isEqualToString:@"http://"]) {
                websiteInfo = nil;
            }
            if ([self.linkedin_url isEqualToString:@"https://www.linkedin.com/in/"]) {
                self.linkedin_url = nil;
            }
            if ([self.twitter_url isEqualToString:@"https://twitter.com/"]) {
                self.twitter_url = nil;
            }
            if ([self.angellist_url isEqualToString:@"https://angel.co/"]) {
                self.angellist_url = nil;
            }
            
            [self setLocationAndWebsite:self.locationInfo website:self.websiteInfo];
            
            
            if (imageFile && locationInfo && displayName) {
                
                // industry label
                self.secondHeaderViewController.industryInfo.text = self.industry;
                
                // description label
                self.firstHeaderViewController.descriptionLabel.text = self.descriptionInfo;
                
                CGSize maximumLabelSize = CGSizeMake(300.0f, MAXFLOAT);
                
                CGSize expectedSize = [self.descriptionLabel sizeThatFits:maximumLabelSize];
                
        
                if ([self.websiteInfo length] > 0) {
                    website_expectedSize = [self.websiteInfo sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
                    
                } else {
                    website_expectedSize = CGSizeMake(132.01f, 15.50f);
                }
                
                UIColor *textColor = [UIColor colorWithRed:158.0f/255.0f green:158.0f/255.0f blue:158.0f/255.0f alpha:1.0f];
                
                self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
                
                self.headerView = [[UIView alloc] init];
                
                self.headerView.frame = CGRectMake( 0.0f, 0.0f, self.feed.bounds.size.width, 97.0f + expectedSize.height + website_expectedSize.height + 43.0f);
                [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
                
                whiteBackground = [[UIView alloc] init];
                [whiteBackground setFrame:CGRectMake( 0.0f, 0.0f, self.feed.bounds.size.width, self.headerView.bounds.size.height - 10.0f)];
                [whiteBackground setBackgroundColor:[UIColor whiteColor]];
                [self.headerView addSubview:whiteBackground];
                
                if (self.user != [PFUser currentUser]){
                    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [backButton setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
                    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
                    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
                    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
                }
            
                
                self.firstHeaderViewController.profilePictureImageView.layer.cornerRadius = self.firstHeaderViewController.profilePictureImageView.frame.size.width / 2;
                    self.firstHeaderViewController.profilePictureImageView.clipsToBounds = YES;
                
                currentUser = [PFUser currentUser];
                
                if (imageFile) {
                    [self.firstHeaderViewController.profilePictureImageView setFile:imageFile];
                    [self.firstHeaderViewController.profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
                        if (!error) {
                            [UIView animateWithDuration:0.05f animations:^{
                                self.firstHeaderViewController.profilePictureImageView.alpha = 1.0f;
                            }];
                        }
                    }];
                } else {
                    NSLog(@"ImageFile Not found");
                }

                
                if ([self.industry length] > 0) {
                    self.secondHeaderViewController.industryLabel.hidden = NO;
                    self.secondHeaderViewController.industryInfo.hidden = NO;
                } else {
                    self.secondHeaderViewController.industryLabel.hidden = YES;
                    self.secondHeaderViewController.industryInfo.hidden = YES;
                }
                
                if ([self.twitter_url length] > 0) {
                    alphaValue_twitter = 1.0f;
                    button_enable_twitter = YES;
                } else {
                    alphaValue_twitter = 0.4f;
                    button_enable_twitter = NO;
                }
                
                if ([self.angellist_url length] > 0) {
                    alphaValue_angellist = 1.0f;
                    button_enable_angellist = YES;
                } else {
                    alphaValue_angellist = 0.4f;
                    button_enable_angellist = NO;
                }
                
                if ([self.linkedin_url length] > 0) {
                    alphaValue_linkedin = 1.0f;
                    button_enable_linkedin = YES;
                } else {
                    alphaValue_linkedin = 0.4f;
                    button_enable_linkedin = NO;
                }
                 
                UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
                [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
                 self.feed.backgroundView = texturedBackgroundView;
                
                // taps for followers/following section, all point to same method
                
                UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowers:)];
                
                UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowers:)];
                
                UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowing:)];
                
                UITapGestureRecognizer *tap6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFollowing:)];
                
                /* followers/following count & title */
                
                UIFont *countFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
                UIColor *countColor = [UIColor colorWithRed:118.0f/255.0f green:118.0f/255.0f blue:118.0f/255.0f alpha:1.0f];
                
                UIColor *countTitleColor = [UIColor colorWithRed:178.0f/255.0f green:184.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
                UIFont *countTitleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
                
                // photo/moment count
                
                // Title
                UILabel *photoCountTitle = [[UILabel alloc] init];
                [photoCountTitle setTextColor:countTitleColor];
                [photoCountTitle setFont:countTitleFont];
                [photoCountTitle setText:@"moments"];
                
                CGFloat photoCountTitleWidth = [photoCountTitle.text sizeWithAttributes:@{NSFontAttributeName: countTitleFont}].width;
                
                [photoCountTitle setFrame:CGRectMake(108.0f, 30.0f, photoCountTitleWidth, 15.0f)];
                [photoCountTitle setUserInteractionEnabled:YES];
                
                // Count
                UILabel *photoCountLabel= [[UILabel alloc] initWithFrame:CGRectMake(108.0f, 10.0f, photoCountTitleWidth, 22.0f)];
                [photoCountLabel setTextAlignment:NSTextAlignmentCenter];
                [photoCountLabel setTextColor:countColor];
                [photoCountLabel setFont:countFont];
                [photoCountLabel setUserInteractionEnabled:YES];
                
                [self.headerView addSubview:photoCountLabel];
                [self.headerView addSubview:photoCountTitle];
                
                // follower label & count
                
                // Title
                [self.firstHeaderViewController.followerLabel addGestureRecognizer:tap3];
                
                // Count
                [self.firstHeaderViewController.followerCountLabel addGestureRecognizer:tap4];
                
                
                // following lable & count
                
                // Title
                [self.firstHeaderViewController.followingLabel addGestureRecognizer:tap5];
                
                // Count
                [self.firstHeaderViewController.followingCountLabel addGestureRecognizer:tap6];
                
                self.locationIconImageView = [[UIImageView alloc] initWithImage:nil];
                [self.locationIconImageView setImage:[UIImage imageNamed:@"iconlocation.png"]];
                [self.locationIconImageView setFrame:CGRectMake(6.0f, 88.0f + expectedSize.height, 15.0f, 15.0f)];
                [self.headerView addSubview:self.locationIconImageView];
                
                // Check length of location
                if([self.locationInfo length] == 0){
                    self.locationInfo = @"";
                }
                
                // handling slow internet / slow backend
                if(self.locationLabel == nil ){
                    self.locationLabel = [[UILabel alloc]init];
                }
                
                if(self.locationLabel.font == nil){
                    self.locationLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
                }
                
                CGFloat locationLabelWidth = [self.locationLabel.text sizeWithAttributes:
                               @{NSFontAttributeName:
                                     self.locationLabel.font}].width;
                
                [self.locationLabel setFrame:CGRectMake(self.locationIconImageView.frame.origin.x + 20.0f, 88.0f + expectedSize.height, locationLabelWidth + 10.0f, 16.0f)];
    

                // the bar separating location and website link
                self.locationSiteSeparator = [[UILabel alloc] init];
                self.locationSiteSeparator.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
                self.locationSiteSeparator.textColor = textColor;
            
                if(websiteInfo.length > 0){
                    self.locationSiteSeparator.text = @"|";
                }
                
                self.locationSiteSeparator.frame = CGRectMake(locationLabelWidth + self.locationLabel.frame.origin.x + 5.0f, 91.5f + expectedSize.height, 10.0f, 10.0f);
                
                [self.headerView addSubview: self.locationSiteSeparator];
                
                websiteLink = [UIButton buttonWithType:UIButtonTypeCustom];
                
                
                // calculate space left for website link
                CGFloat spaceLeft = [[UIScreen mainScreen] bounds].size.width - self.locationSiteSeparator.frame.size.width - self.locationLabel.frame.size.width - self.locationIconImageView.frame.size.width - 20;
                
                // edge case when size of website link goes over screen bounds, reduce font to fit
                if(website_expectedSize.width > spaceLeft){
                    website_expectedSize.width = spaceLeft;
                    websiteLink.titleLabel.adjustsFontSizeToFitWidth = YES;
                }
                
                // website link
                [self.firstHeaderViewController.websiteLink addTarget:self action:@selector(websiteLinkAction:) forControlEvents:UIControlEventTouchUpInside];
                
                if ([websiteInfo length] > 0) {
                    //[self.firstHeaderViewController.websiteLink setTitle:websiteInfo forState:UIControlStateNormal];
                }
                
                // social buttons
                
                [self.secondHeaderViewController.linkedIn setAlpha:alphaValue_angellist];
                self.secondHeaderViewController.linkedIn.enabled = button_enable_angellist;
                [self.secondHeaderViewController.linkedIn addTarget:self action:@selector(linkedin_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                [self.secondHeaderViewController.twitter setAlpha:alphaValue_angellist];
                self.secondHeaderViewController.twitter.enabled = button_enable_angellist;
                [self.secondHeaderViewController.twitter addTarget:self action:@selector(twitter_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                
                [self.secondHeaderViewController.angelList setAlpha:alphaValue_angellist];
                self.secondHeaderViewController.angelList.enabled = button_enable_angellist;
                [self.secondHeaderViewController.angelList addTarget:self action:@selector(angellist_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                
      
                [photoCountLabel setText:@"0"];
                
                PFQuery *queryPhotoCount = [PFQuery queryWithClassName:@"Photo"];
                [queryPhotoCount whereKey:kPAPPhotoUserKey equalTo:self.user];
                [queryPhotoCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [queryPhotoCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    if (!error) {
                        [photoCountLabel setText:[NSString stringWithFormat:@"%d", number]];
                        [[PAPCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
                    }
                }];
                
                // follower count
                [self.firstHeaderViewController.followerCountLabel setText:@"0"];
                
                PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
                [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
                [queryFollowerCount setCachePolicy:kPFCachePolicyNetworkElseCache];
                
                [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    if (!error) {
                        [self.firstHeaderViewController.followerCountLabel setText:[NSString stringWithFormat:@"%d",number]];
                    }
                }];
                
                // following count
                NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
                [self.firstHeaderViewController.followingCountLabel setText:@"0"];
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
                    }
                }];
              
                // set activity points for user
                
                NSNumber *activityPoints = [[AtMention sharedAtMention] activityPoints];
                [self.firstHeaderViewController.pointCountLabel setText:[activityPoints stringValue]];
                
                
                // set follow and message button when visiting someone's profile
                if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                    
                    
                    UIImage *messageButtonImage = [UIImage imageNamed:@"btn_message.png"];
                    
                    // resize button to message and follow size (assuming both stay the same) - hurts my soul :(
                    self.multiActionButton.frame = CGRectMake(self.multiActionButton.frame.origin.x, self.multiActionButton.frame.origin.y, messageButtonImage.size.width, self.multiActionButton.frame.size.height);
                    
                    // set message frame
                    UIView *messageButtonView = [[UIView alloc] initWithFrame:CGRectMake(self.multiActionButton.frame.origin.x + self.multiActionButton.frame.size.width, self.multiActionButton.frame.origin.y, messageButtonImage.size.width / 2, messageButtonImage.size.height)];
                    
                    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    
                    [messageButton setFrame:CGRectMake(10, 0, messageButtonImage.size.width, messageButtonImage.size.height)];
                    [messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    [messageButton setBackgroundImage:messageButtonImage forState:UIControlStateNormal];
                    [messageButton setBackgroundImage:[UIImage imageNamed:@"btn_message_tapped"] forState:UIControlStateSelected];
                    
                    [messageButtonView addSubview:messageButton];
                    
                    [self.multiActionContainerView addSubview:messageButtonView];
                    
                    
                    // check if the currentUser is following this user
                    PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
                    [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                    [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:self.user];
                    [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
                    [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
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
            }
            
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Account info failed to load. Try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
        
        if([SVProgressHUD isVisible]){
            [SVProgressHUD dismiss];
        }

        self.feed.tableHeaderView = self.headerContainerViewController.view;
    }];
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
    
    if(![SVProgressHUD isVisible]){
        [SVProgressHUD show];
    }
    
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    
    [self.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.user = (PFUser *)object;
    
        self.accountTitleLabel.text = [self.user objectForKey:@"displayName"];
        [self.accountTitleLabel sizeToFit];
        
        // location and description for new label
        self.locationInfo = [self.user objectForKey:@"location"];
        self.websiteInfo = [self.user objectForKey:@"website"];
        self.firstHeaderViewController.descriptionLabel.text = [self.user objectForKey:@"description"];
    
        
        [self setLocationAndWebsite:self.locationInfo website:self.websiteInfo];
        
        self.secondHeaderViewController.industryInfo.text = [self.user objectForKey:@"industry"];
        self.angellist_url = [self.user objectForKey:@"angellist_url"];
        self.twitter_url = [self.user objectForKey:@"twitter_url"];
        self.linkedin_url = [self.user objectForKey:@"linkedin_url"];
        
        if ([self.linkedin_url isEqualToString:@"https://www.linkedin.com/in/"]) {
            self.linkedin_url = nil;
        }
        if ([self.twitter_url isEqualToString:@"https://twitter.com/"]) {
            self.twitter_url = nil;
        }
        if ([self.angellist_url isEqualToString:@"https://angel.co/"]) {
            self.angellist_url = nil;
        }
        
        if ([self.angellist_url length] > 0) {
            alphaValue_angellist = 1.0f;
            button_enable_angellist = YES;
        } else {
            alphaValue_angellist = 0.4f;
            button_enable_angellist = NO;
        }
        
        if ([self.linkedin_url length] > 0) {
            alphaValue_linkedin = 1.0f;
            button_enable_linkedin = YES;
        } else {
            alphaValue_linkedin = 0.4f;
            button_enable_linkedin = NO;
        }
        
        self.secondHeaderViewController.angelList.enabled = button_enable_angellist;
        self.secondHeaderViewController.angelList.alpha = alphaValue_angellist;
        
        self.secondHeaderViewController.twitter.enabled = button_enable_twitter;
        self.secondHeaderViewController.twitter.alpha = alphaValue_twitter;
        
        self.secondHeaderViewController.linkedIn.enabled = button_enable_linkedin;
        self.secondHeaderViewController.linkedIn.alpha = alphaValue_linkedin;
        
        [self.firstHeaderViewController.profilePictureImageView setFile:[self.user objectForKey:@"profilePictureMedium"]];
        [self.firstHeaderViewController.profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.05f animations:^{
                    self.firstHeaderViewController.profilePictureImageView.alpha = 1.0f;
                }];
            }
        }];
        
        // refresh user stats, dismiss progress hud when finished
        [self refreshFollowerCount:^(BOOL completed) {
            if(completed){
                [SVProgressHUD dismiss];
            }
        }];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self.navigationController.tabBarController.viewControllers objectAtIndex:4] tabBarItem].image = [[UIImage imageNamed:@"nav_profile.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - Custom

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

- (void)setLocationAndWebsite:(NSString *)location website:(NSString *)website{
    
    // set variables
    BOOL isLoc = location && location.length > 0;
    BOOL isWeb = website && website.length > 0;
    
    BOOL isBoth = isLoc && isWeb;
    BOOL isOnlyLoc = isLoc && !isWeb;
    BOOL isOnlyWeb = !isLoc && isWeb;
    
    // default visibility
    [self.firstHeaderViewController.seperatorLabel setHidden:YES];
    [self.firstHeaderViewController.websiteLink setHidden:NO];
    [self.firstHeaderViewController.locationLabel setHidden:NO];
    
    if(isBoth){
        self.firstHeaderViewController.locationLabel.text = location;
        [self.firstHeaderViewController.websiteLink setTitle:website forState:UIControlStateNormal];
        
        [self.firstHeaderViewController.locationLabel sizeToFit];
        [self.firstHeaderViewController.websiteLink sizeToFit];
    }else if(isOnlyLoc){
        [self.firstHeaderViewController.websiteLink setHidden:YES];
        
        self.firstHeaderViewController.locationLabel.text = location;
        [self.firstHeaderViewController.locationLabel sizeToFit];
    }else if(isOnlyWeb){
        [self.firstHeaderViewController.locationLabel setHidden:YES];
        
        [self.firstHeaderViewController.websiteLink setTitle:website forState:UIControlStateNormal];
        [self.firstHeaderViewController.websiteLink sizeToFit];
    }else{
        [self.firstHeaderViewController.locationLabel setHidden:YES];
        [self.firstHeaderViewController.websiteLink setHidden:YES];
    }
    
    [self setFrameForElements:self.firstHeaderViewController.locationLabel elem2:self.firstHeaderViewController.websiteLink];
}

- (void)setFrameForElements:(UIView *)elem1 elem2:(UIView *)elem2{
    
    // set variables
    BOOL isElem1 = ![elem1 isHidden];
    BOOL isElem2 = ![elem2 isHidden];
    
    int maxWidth = 290;
    float sepWidth = self.firstHeaderViewController.seperatorLabel.frame.size.width;
    float firstPosX = 15;
    
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
    remainingSpace = maxWidth - totalWidth;
    
  //  [elem1 setBackgroundColor:[UIColor redColor]];
  //  [elem2 setBackgroundColor:[UIColor redColor]];
    
   // [self.firstHeaderViewController.seperatorLabel setBackgroundColor:[UIColor redColor]];
    
    // check if total width is under remaining space
    if(remainingSpace >= 0){
        if(isBothElem){

            elem1.frame = CGRectMake(elem1.frame.origin.x, elem1.frame.origin.y, elem1.frame.size.width, elem1.frame.size.height);
            
            self.firstHeaderViewController.seperatorLabel.frame = CGRectMake(elem1.frame.origin.x + elem1.frame.size.width+ 7, self.firstHeaderViewController.seperatorLabel.frame.origin.y, self.firstHeaderViewController.seperatorLabel.frame.size.width, self.firstHeaderViewController.seperatorLabel.frame.size.height);
            
            elem2.frame = CGRectMake(self.firstHeaderViewController.seperatorLabel.frame.origin.x + self.firstHeaderViewController.seperatorLabel.frame.size.width + 5, elem1.frame.origin.y, elem2.frame.size.width, elem1.frame.size.height);
            
            [self.firstHeaderViewController.seperatorLabel setHidden:NO];
            
        }else if(isOnlyElem1){
            elem1.frame = CGRectMake(elem1.frame.origin.x, elem1.frame.origin.y, elem1.frame.size.width, elem1.frame.size.height);
        }else if(isOnlyElem2){
            elem2.frame = CGRectMake(firstPosX, elem1.frame.origin.y, elem2.frame.size.width, elem1.frame.size.height);
        }
    }else{
        if(isBothElem){
            
            [self.firstHeaderViewController.seperatorLabel setHidden:YES];
            
            elem1.frame = CGRectMake(elem1.frame.origin.x, elem1.frame.origin.y, elem1.frame.size.width, elem1.frame.size.height);
            elem2.frame = CGRectMake(elem1.frame.origin.x, elem1.frame.origin.y + 10, elem2.frame.size.width, elem2.frame.size.height);
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
    
    [self.multiActionButton setImage:[UIImage imageNamed:@"btn_follow.png"] forState:UIControlStateNormal];
    [self.multiActionButton removeTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.multiActionButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [[PAPCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
        
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
    [self.multiActionButton setImage:editProfileBtn forState:UIControlStateNormal];
    [self.multiActionButton setImage:[UIImage imageNamed:@"btn_edit_profile_tapped"] forState:UIControlStateSelected];
    
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