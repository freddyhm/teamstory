//
//  PAPAccountViewController.m
//  Teamstory
//
//

#import "PAPAccountViewController.h"
#import "PAPLoadMoreCell.h"
#import "PAPSettingsButtonItem.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "SVProgressHUD.h"
#import "PAPwebviewViewController.h"
#import "FollowersFollowingViewController.h"
#import "Mixpanel.h"
#import <FlightRecorder/FlightRecorder.h>
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
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        PAPLoginSelectionViewController *loginSelectionViewController = [[PAPLoginSelectionViewController alloc] initWithNibName:@"PAPLoginSelectionViewController" bundle:nil];
        [self.navigationController presentViewController:loginSelectionViewController animated:YES completion:nil];
        return;
    }
    
    // remove refresh control for home that is set by default in inherited timeline
    [super.refreshControl removeFromSuperview];
    
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
    UIFont *locationFont = [UIFont fontWithName:@"Helvetica" size:13.0f];
    UIColor *locationColor = [UIColor colorWithRed:158.0f/255.0f green:158.0f/255.0f blue:158.0f/255.0f alpha:1];
    
    self.locationLabel = [[UILabel alloc]init];
    [self.locationLabel setBackgroundColor:[UIColor clearColor]];
    [self.locationLabel setTextColor:locationColor];
    [self.locationLabel setFont:locationFont];
    [self.locationLabel setText:self.locationInfo];
    
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
            
            
            if (imageFile && locationInfo && displayName) {
                self.industryLabel = [[UILabel alloc] init];
                
                self.industryLabel.text = self.industry;
                
                self.descriptionLabel = [[UILabel alloc] init];
                self.descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
                [self.descriptionLabel setTextColor:[UIColor colorWithRed:178.0f/255.0f green:184.0f/255.0f blue:189.0f/255.0f alpha:1.0f]];
                self.descriptionLabel.text = self.descriptionInfo;
                self.descriptionLabel.numberOfLines = 0;
                CGSize maximumLabelSize = CGSizeMake(300.0f, MAXFLOAT);
                
                CGSize expectedSize = [self.descriptionLabel sizeThatFits:maximumLabelSize];
                
                
                CGSize industry_expectedSize = [self.industry sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];

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
                [self.view addSubview:self.headerView];
                
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
            
                profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake( 10.0f, 10.0f, 70.0f, 70.0f)];
                [profilePictureBackgroundView setBackgroundColor:[UIColor whiteColor]];
                profilePictureBackgroundView.alpha = 0.0f;
                CALayer *layer = [profilePictureBackgroundView layer];
                layer.cornerRadius = 0.0f;
                layer.masksToBounds = YES;
                [self.headerView addSubview:profilePictureBackgroundView];
                
                profilePictureBackgroundView.layer.cornerRadius = profilePictureBackgroundView.frame.size.width / 2;
                profilePictureBackgroundView.clipsToBounds = YES;

                profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 10.0f, 10.0f, 70.0f, 70.0f)];
                [self.headerView addSubview:profilePictureImageView];
                [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
                layer = [profilePictureImageView layer];
                layer.cornerRadius = 0.0f;
                layer.masksToBounds = YES;
                profilePictureImageView.alpha = 0.0f;
                
                profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2;
                profilePictureImageView.clipsToBounds = YES;
                
                currentUser = [PFUser currentUser];
                
                if (imageFile) {
                    [profilePictureImageView setFile:imageFile];
                    [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
                        if (!error) {
                            [UIView animateWithDuration:0.05f animations:^{
                                profilePictureBackgroundView.alpha = 1.0f;
                                profilePictureImageView.alpha = 1.0f;
                            }];
                        }
                    }];
                } else {
                    NSLog(@"ImageFile Not found");
                }

                
                if ([self.industry length] > 0) {
                    industryLabel.hidden = NO;
                    [industryLabel setFrame:CGRectMake(320.0f - (industry_expectedSize.width + 20.0f), 97.0f + expectedSize.height + website_expectedSize.height, industry_expectedSize.width + 10.0f, 22.0f)];
                } else {
                    industryLabel.hidden = YES;
                }
                industryLabel.textAlignment = NSTextAlignmentCenter;
                [industryLabel setBackgroundColor:[UIColor colorWithRed:201.0f/255.0f green:205.0f/255.0f blue:208.0f/255.0f alpha:1.0f]];
                [industryLabel.layer setCornerRadius:3.0f];
                [industryLabel setClipsToBounds:YES];
                [industryLabel setFont:[UIFont systemFontOfSize:13.0f]];
                [industryLabel setTextColor:[UIColor whiteColor]];
                [self.headerView addSubview:industryLabel];
                
                [self.descriptionLabel setFrame:CGRectMake(10.0f, 88.0f, expectedSize.width, expectedSize.height)];
                [self.headerView addSubview:self.descriptionLabel];
                
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
                
                // follower count & label
                
                // Title
                UILabel *followersTitle = [[UILabel alloc] init];
                [followersTitle setTextColor:countTitleColor];
                [followersTitle setFont:countTitleFont];
                [followersTitle setText:@"followers"];
                
                CGFloat followersTitleWidth = [followersTitle.text sizeWithAttributes:@{NSFontAttributeName: countTitleFont}].width;

                [followersTitle setFrame:CGRectMake( photoCountTitle.frame.origin.x + photoCountTitle.frame.size.width + 31.0f, photoCountTitle.frame.origin.y, followersTitleWidth, photoCountTitle.frame.size.height)];
                [followersTitle addGestureRecognizer:tap4];
                [followersTitle setUserInteractionEnabled:YES];
                
                // Count
                self.followerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( photoCountLabel.frame.origin.x + photoCountLabel.frame.size.width + 31.0f, photoCountLabel.frame.origin.y, followersTitleWidth, photoCountLabel.frame.size.height)];
                [self.followerCountLabel setTextAlignment:NSTextAlignmentCenter];
                [self.followerCountLabel setTextColor:countColor];
                [self.followerCountLabel setFont:countFont];
                [self.followerCountLabel addGestureRecognizer:tap3];
                [self.followerCountLabel setUserInteractionEnabled:YES];
                
                [self.headerView addSubview:self.followerCountLabel];
                [self.headerView addSubview:followersTitle];
                
                // following count & label
                
                // Title
                UILabel *followingTitle = [[UILabel alloc] init];
                [followingTitle setTextColor:countTitleColor];
                [followingTitle setFont:countTitleFont];
                [followingTitle setText:@"following"];
                
                CGFloat followingCountLabelWidth = [followingTitle.text sizeWithAttributes:@{NSFontAttributeName: countTitleFont}].width;
                
                [followingTitle setFrame:CGRectMake( followersTitle.frame.origin.x + followersTitle.frame.size.width + 31.0f, followersTitle.frame.origin.y, followingCountLabelWidth, followersTitle.frame.size.height)];
                [followingTitle addGestureRecognizer:tap6];
                [followingTitle setUserInteractionEnabled:YES];
                
                // Count
                self.followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.followerCountLabel.frame.origin.x + self.followerCountLabel.frame.size.width + 31.0f, self.followerCountLabel.frame.origin.y, followingCountLabelWidth, self.followerCountLabel.frame.size.height)];
                self.followingCountLabel.textAlignment = NSTextAlignmentCenter;
                [self.followingCountLabel setFont:countFont];
                [self.followingCountLabel setTextColor:countColor];
                [self.followingCountLabel addGestureRecognizer:tap5];
                [self.followingCountLabel setUserInteractionEnabled:YES];
                
                [self.headerView addSubview:self.followingCountLabel];
                [self.headerView addSubview:followingTitle];
                
                // follow/unfollow/editprofile big button
                UIImage *editProfileBtn = [UIImage imageNamed:@"btn_editprofile.png"];
                self.multiActionButton = [[UIButton alloc]initWithFrame:CGRectMake(photoCountTitle.frame.origin.x, photoCountTitle.frame.origin.y + 20.0f, editProfileBtn.size.width, editProfileBtn.size.height)];
                [self.multiActionButton setImage:editProfileBtn forState:UIControlStateNormal];
                self.multiActionButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                [self.multiActionButton addTarget:self action:@selector(editProfileAction:) forControlEvents:UIControlEventTouchUpInside];
        
                [self.headerView addSubview:self.multiActionButton];
                
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
    
                [self.headerView addSubview:self.locationLabel];
                
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
                
                
                [websiteLink setFrame:CGRectMake(self.locationSiteSeparator.frame.origin.x + self.locationSiteSeparator.frame.size.width, 89.0f + expectedSize.height, website_expectedSize.width, website_expectedSize.height)];
                [websiteLink setTitleColor:[UIColor colorWithRed:86.0f/255.0f green:130.0f/255.0f blue:164.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
                websiteLink.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                websiteLink.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                [websiteLink addTarget:self action:@selector(websiteLinkAction:) forControlEvents:UIControlEventTouchUpInside];
                
                if ([websiteInfo length] > 0) {
                    [websiteLink setTitle:websiteInfo forState:UIControlStateNormal];
                }
                
                [self.headerView addSubview:websiteLink];
                
                linkedIn_button = [[UIButton alloc] init];
                [linkedIn_button setFrame:CGRectMake(10.0f, 97.0f + expectedSize.height + website_expectedSize.height, 22.0f, 22.0f)];
                [linkedIn_button setBackgroundImage:[UIImage imageNamed:@"icon-linkedin-profile.png"] forState:UIControlStateNormal];
                [linkedIn_button setAlpha:alphaValue_linkedin];
                linkedIn_button.enabled = button_enable_linkedin;
                [linkedIn_button addTarget:self action:@selector(linkedin_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.headerView addSubview:linkedIn_button];
                
                twitter_button = [[UIButton alloc] init];
                twitter_button.frame = CGRectMake(42.0f, 97.0f + expectedSize.height + website_expectedSize.height, 22.0f, 22.0f);
                [twitter_button setAlpha:alphaValue_twitter];
                twitter_button.enabled = button_enable_twitter;
                [twitter_button addTarget:self action:@selector(twitter_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                [twitter_button setBackgroundImage:[UIImage imageNamed:@"icon-twitter-profile.png"] forState:UIControlStateNormal];
                [self.headerView addSubview:twitter_button];
                
                angellist_button = [[UIButton alloc] init];
                angellist_button.frame = CGRectMake(74.0f, 97.0f + expectedSize.height + website_expectedSize.height, 22.0f, 22.0f);
                [angellist_button setBackgroundImage:[UIImage imageNamed:@"icon-angel-profile.png"] forState:UIControlStateNormal];
                [angellist_button setAlpha:alphaValue_angellist];
                angellist_button.enabled = button_enable_angellist;
                [angellist_button addTarget:self action:@selector(angellist_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.headerView addSubview:angellist_button];
                
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
                
                [self.followerCountLabel setText:@"0"];
                
                PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
                [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
                [queryFollowerCount setCachePolicy:kPFCachePolicyNetworkElseCache];
                
                [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    if (!error) {
                        [self.followerCountLabel setText:[NSString stringWithFormat:@"%d",number]];
                    }
                }];
                
                NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
                [self.followingCountLabel setText:@"0"];
                if (followingDictionary) {
                    [self.followingCountLabel setText:[NSString stringWithFormat:@"%d", (int)[[followingDictionary allValues] count]]];
                }
                
                PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
                [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
                [queryFollowingCount setCachePolicy:kPFCachePolicyNetworkElseCache];
                
                // get followers for current user                
                [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    if (!error) {
                        [self.followingCountLabel setText:[NSString stringWithFormat:@"%d", number]];
                    }
                }];
                
                if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                    UIImage *messageButtonImage = [UIImage imageNamed:@"btn_message_empty.png"];
                    
                    UIView *messageButtonView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, messageButtonImage.size.width, messageButtonImage.size.height)];
                    
                    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [messageButton setFrame:CGRectMake(10, 0, messageButtonImage.size.width, messageButtonImage.size.height)];
                    [messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    [messageButton setBackgroundImage:messageButtonImage forState:UIControlStateNormal];
                    
                    [messageButtonView addSubview:messageButton];
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:messageButtonView];
                    
                    
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
            
            // load header
            self.feed.tableHeaderView = headerView;
            
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Account info failed to load. Try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
        
        if([SVProgressHUD isVisible]){
            [SVProgressHUD dismiss];
        }
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

- (void)viewWillDisappear:(BOOL)animated {
    [[self.navigationController.tabBarController.viewControllers objectAtIndex:4] tabBarItem].image = [[UIImage imageNamed:@"nav_profile.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)viewWillAppear:(BOOL)animated{
    // analytics
    [super viewWillAppear:YES];
    
    // google analytics
    [PAPUtility captureScreenGA:@"Account"];

    
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] && ([[PFUser currentUser] objectForKey:@"description"] == nil || [[PFUser currentUser] objectForKey:@"industry"] == nil || [[PFUser currentUser] objectForKey:@"location"] == nil)) {
        NSDate *profileUpdateDate = [[PFUser currentUser] objectForKey:@"profileUpdate"];
        NSDate *currentDate = [NSDate date];
        
        NSTimeInterval distanceBetweenDatesProfile = [currentDate timeIntervalSinceDate:profileUpdateDate];
        float profileGlowTimeFrame = 7*24*60*60; //every 7 days
        
        if (distanceBetweenDatesProfile > profileGlowTimeFrame || profileUpdateDate == nil) {
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
        
        self.locationLabel.text = [self.user objectForKey:@"location"];
        self.descriptionLabel.text = [self.user objectForKey:@"description"];
        self.websiteInfo = [self.user objectForKey:@"website"];
        self.industryLabel.text = [self.user objectForKey:@"industry"];
        self.angellist_url = [self.user objectForKey:@"angellist_url"];
        self.twitter_url = [self.user objectForKey:@"twitter_url"];
        self.linkedin_url = [self.user objectForKey:@"linkedin_url"];
        
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
        
        angellist_button.enabled = button_enable_angellist;
        angellist_button.alpha = alphaValue_angellist;
        
        twitter_button.enabled = button_enable_twitter;
        twitter_button.alpha = alphaValue_twitter;
        
        linkedIn_button.enabled = button_enable_linkedin;
        linkedIn_button.alpha = alphaValue_linkedin;
        
        [profilePictureImageView setFile:[self.user objectForKey:@"profilePictureMedium"]];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.05f animations:^{
                    profilePictureBackgroundView.alpha = 1.0f;
                    profilePictureImageView.alpha = 1.0f;
                }];
            }
        }];
        
        CGSize maximumLabelSize = CGSizeMake(300.0f, MAXFLOAT);
        
        CGSize expectedSize = [self.descriptionLabel sizeThatFits:maximumLabelSize];
        
        
        CGSize industry_expectedSize = [self.industryLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
        
        if ([self.websiteInfo length] > 0) {
            website_expectedSize = [self.websiteInfo sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
            
        } else {
            website_expectedSize = CGSizeMake(132.01f, 15.50f);
        }
        
        self.headerView.frame = CGRectMake( 0.0f, 0.0f, self.feed.bounds.size.width, 97.0f + expectedSize.height + website_expectedSize.height + 43.0f);
        
        if ([self.industryLabel.text length] > 0) {
            industryLabel.hidden = NO;
            [industryLabel setFrame:CGRectMake(318.0f - (industry_expectedSize.width + 20.0f), 97.0f + expectedSize.height + website_expectedSize.height, industry_expectedSize.width + 10.0f, 22.0f)];
        } else {
            industryLabel.hidden = YES;
        }
        
        [descriptionLabel setFrame:CGRectMake(10.0f, 88.0f, expectedSize.width, expectedSize.height)];
        
        
        // handling slow internet / slow backend
        if(self.locationLabel == nil ){
            self.locationLabel = [[UILabel alloc]init];
        }
        
        if(self.locationLabel.font == nil){
            self.locationLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
        }
        
        // re-calculate width size for location label, image, and separator
        CGFloat locationLabelWidth = [self.locationLabel.text sizeWithAttributes:
                                      @{NSFontAttributeName:
                                            self.locationLabel.font}].width;
        [self.locationLabel setFrame:CGRectMake(self.locationLabel.frame.origin.x, 88.0f + expectedSize.height, locationLabelWidth + 10.0f, self.locationLabel.frame.size.height)];
        self.locationSiteSeparator.frame = CGRectMake(locationLabelWidth + self.locationLabel.frame.origin.x + 5.0f, 91.5f + expectedSize.height, 10.0f, 10.0f);
        
    
        if(self.websiteInfo.length > 0 && ![self.locationSiteSeparator.text isEqualToString:@"|"]){
            self.locationSiteSeparator.text = @"|";
        }
        
        [self.locationIconImageView setFrame:CGRectMake(6.0f, 88.0f + expectedSize.height, 15.0f, 15.0f)];
        
        // calculate space left for website link
        CGFloat spaceLeft = [[UIScreen mainScreen] bounds].size.width - self.locationSiteSeparator.frame.size.width - self.locationLabel.frame.size.width - self.locationIconImageView.frame.size.width - 20;
        
        // edge case when size of website link goes over screen bounds, reduce font to fit
        if(website_expectedSize.width > spaceLeft){
            website_expectedSize.width = spaceLeft;
            websiteLink.titleLabel.adjustsFontSizeToFitWidth = YES;
        }

        [websiteLink setFrame:CGRectMake(self.locationSiteSeparator.frame.origin.x + self.locationSiteSeparator.frame.size.width, 89.0f + expectedSize.height, website_expectedSize.width, website_expectedSize.height)];
        [websiteLink setTitle:self.websiteInfo forState:UIControlStateNormal];
        

        [self.industryLabel setFrame:CGRectMake(320.0f - (industry_expectedSize.width + 20.0f), 97.0f + expectedSize.height + website_expectedSize.height, industry_expectedSize.width + 10.0f, 22.0f)];
        [whiteBackground setFrame:CGRectMake( 0.0f, 0.0f, self.feed.bounds.size.width, self.headerView.bounds.size.height - 10.0f)];
        
        linkedIn_button.frame = CGRectMake(10.0f, 97.0f + expectedSize.height + website_expectedSize.height, 22.0f, 22.0f);
        angellist_button.frame = CGRectMake(74.0f, 97.0f + expectedSize.height + website_expectedSize.height, 22.0f, 22.0f);
        twitter_button.frame = CGRectMake(42.0f, 97.0f + expectedSize.height + website_expectedSize.height, 22.0f, 22.0f);
        
        // refresh user stats, dismiss progress hud when finished
        [self refreshFollowerCount:^(BOOL completed) {
            if(completed){
                [SVProgressHUD dismiss];
            }
        }];
    }];
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
                            
                            [self setHidesBottomBarWhenPushed:YES];
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
  //  PAPProfileSettingViewController *profileViewController = [[PAPProfileSettingViewController alloc] init];
    //profileViewController.hidesBottomBarWhenPushed = YES;
    
    ProfileSettingViewController *one = [[ProfileSettingViewController alloc] initWithNibName:@"ProfileSettingViewController" bundle:nil];
    one.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:one animated:YES];
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
            
            [self.followerCountLabel setText:[NSString stringWithFormat:@"%d", number]];
            
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
            
            [self.followingCountLabel setText:[NSString stringWithFormat:@"%d", number]];
            
            // increment and check if we're done updating
            self.userStatUpdateCount++;
            if(self.userStatUpdateCount > 1){
                 completed(YES);
            }
        }
    }];
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

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    if (buttonIndex == 1) {
        ProfileSettingViewController *profileViewController = [[ProfileSettingViewController alloc] init];
        profileViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profileViewController animated:YES];

    }
}


@end