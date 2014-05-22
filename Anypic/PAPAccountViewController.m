//
//  PAPAccountViewController.m
//  Teamstory
//
//

#import "PAPAccountViewController.h"
#import "PAPLoadMoreCell.h"
#import "PAPProfileSettingViewController.h"
#import "PAPSettingsButtonItem.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "SVProgressHUD.h"
#import "PAPwebviewViewController.h"

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


#pragma mark - Initialization


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    
    [SVProgressHUD show];
    
    [self.user refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
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
                if ([self.industry length] > 0) {
                    self.industryLabel = [[UILabel alloc] init];
                }
                self.industryLabel.text = self.industry;
                
                self.descriptionLabel = [[UILabel alloc] init];
                self.descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
                [self.descriptionLabel setTextColor:[UIColor colorWithRed:178.0f/255.0f green:184.0f/255.0f blue:189.0f/255.0f alpha:1.0f]];
                self.descriptionLabel.text = self.descriptionInfo;
                self.descriptionLabel.numberOfLines = 0;
                CGSize maximumLabelSize = CGSizeMake(300.0f, 32.0f);
                
                CGSize expectedSize = [self.descriptionLabel sizeThatFits:maximumLabelSize];
                CGSize industry_expectedSize = [self.industry sizeWithFont:[UIFont systemFontOfSize:13.0f]];
                
                if ([self.websiteInfo length] > 0) {
                    website_expectedSize = [self.websiteInfo sizeWithFont:[UIFont systemFontOfSize:13.0f]];
                } else {
                    website_expectedSize = CGSizeMake(0.0f, 0.0f);
                }
                
                UIColor *textColor = [UIColor colorWithRed:158.0f/255.0f green:158.0f/255.0f blue:158.0f/255.0f alpha:1.0f];
                
                self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProfileNavigationBar.png"]];
                self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
                
                self.headerView = [[UIView alloc] init];
                
                self.headerView.frame = CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 97.0f + expectedSize.height + website_expectedSize.height + 43.0f);
                [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
                
                UIView *whiteBackground = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, self.headerView.bounds.size.height - 10.0f)];
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
                [profilePictureBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
                profilePictureBackgroundView.alpha = 0.0f;
                CALayer *layer = [profilePictureBackgroundView layer];
                layer.cornerRadius = 0.0f;
                layer.masksToBounds = YES;
                [self.headerView addSubview:profilePictureBackgroundView];

                profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 10.0f, 10.0f, 70.0f, 70.0f)];
                [self.headerView addSubview:profilePictureImageView];
                [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
                layer = [profilePictureImageView layer];
                layer.cornerRadius = 0.0f;
                layer.masksToBounds = YES;
                profilePictureImageView.alpha = 0.0f;
                
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

                if ([locationInfo length] > 0) {
                    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake( 110.0f, 30.0f, self.headerView.bounds.size.width, 16.0f )];
                    [locationLabel setText:locationInfo];
                    [locationLabel setBackgroundColor:[UIColor clearColor]];
                    [locationLabel setTextColor:textColor];
                    [locationLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
                    [self.headerView addSubview:locationLabel];
                } else {
                    NSLog(@"locationInfo Not found");
                }
                
                [industryLabel setFrame:CGRectMake(320.0f - (industry_expectedSize.width + 20.0f), 97.0f + expectedSize.height + website_expectedSize.height, industry_expectedSize.width + 10.0f, 22.0f)];
                industryLabel.textAlignment = NSTextAlignmentCenter;
                [industryLabel setBackgroundColor:[UIColor colorWithRed:201.0f/255.0f green:205.0f/255.0f blue:208.0f/255.0f alpha:1.0f]];
                [industryLabel.layer setCornerRadius:3.0f];
                [industryLabel setClipsToBounds:YES];
                [industryLabel setFont:[UIFont systemFontOfSize:13.0f]];
                [industryLabel setTextColor:[UIColor whiteColor]];
                [self.headerView addSubview:industryLabel];
                
                
                [descriptionLabel setFrame:CGRectMake(10.0f, 88.0f, expectedSize.width, expectedSize.height)];
                [self.headerView addSubview:descriptionLabel];
                
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
                self.tableView.backgroundView = texturedBackgroundView;
                
                UILabel *photoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 110.0f, 45.0f, 92.0f, 22.0f)];
                [photoCountLabel setBackgroundColor:[UIColor clearColor]];
                [photoCountLabel setTextColor:textColor];
                [photoCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
                [self.headerView addSubview:photoCountLabel];
                
                UIImageView *photoCountIconImageView = [[UIImageView alloc] initWithImage:nil];
                [photoCountIconImageView setImage:[UIImage imageNamed:@"icon-pics.png"]];
                [photoCountIconImageView setFrame:CGRectMake( 90.0f, 47.50f, 15.0f, 15.0f)];
                [self.headerView addSubview:photoCountIconImageView];
                
                UIImageView *followersIconImageView = [[UIImageView alloc] initWithImage:nil];
                [followersIconImageView setImage:[UIImage imageNamed:@"icon-followers.png"]];
                [followersIconImageView setFrame:CGRectMake( 90.0f, 65.0f, 15.0f, 15.0f)];
                [self.headerView addSubview:followersIconImageView];
                
                UIImageView *locationIconImageView = [[UIImageView alloc] initWithImage:nil];
                [locationIconImageView setImage:[UIImage imageNamed:@"iconlocation.png"]];
                [locationIconImageView setFrame:CGRectMake( 90.0f, 30.0f, 15.0f, 15.0f)];
                [self.headerView addSubview:locationIconImageView];
                
                self.followerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 110.0f, 65.0f, self.headerView.bounds.size.width, 16.0f)];
                [self.followerCountLabel setBackgroundColor:[UIColor clearColor]];
                [self.followerCountLabel setTextColor:textColor];
                [self.followerCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
                [self.headerView addSubview:self.followerCountLabel];
                
                self.followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 193.0f, 65.0f, self.headerView.bounds.size.width, 16.0f)];
                [self.followingCountLabel setBackgroundColor:[UIColor clearColor]];
                [self.followingCountLabel setTextColor:textColor];
                [self.followingCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
                [self.headerView addSubview:self.followingCountLabel];
                
                userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 12.0f, self.headerView.bounds.size.width, 16.0f)];
                [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
                [userDisplayNameLabel setTextColor:[UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
                [userDisplayNameLabel setText:displayName];
                [userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
                [self.headerView addSubview:userDisplayNameLabel];
                
                if ([websiteInfo length] > 0) {
                    websiteLink = [UIButton buttonWithType:UIButtonTypeCustom];
                    [websiteLink setFrame:CGRectMake( 10.0f, 86.0f + expectedSize.height, 300.0f, 16.0f)];
                    [websiteLink setTitle:websiteInfo forState:UIControlStateNormal];
                    [websiteLink setTitleColor:[UIColor colorWithRed:86.0f/255.0f green:130.0f/255.0f blue:164.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
                    websiteLink.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    websiteLink.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                    [websiteLink addTarget:self action:@selector(websiteLinkAction:) forControlEvents:UIControlEventTouchUpInside];
                    [self.headerView addSubview:websiteLink];
                }
                
                linkedIn_button = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 97.0f + expectedSize.height + website_expectedSize.height, 22.0f, 22.0f)];
                [linkedIn_button setBackgroundImage:[UIImage imageNamed:@"icon-linkedin-profile.png"] forState:UIControlStateNormal];
                [linkedIn_button setAlpha:alphaValue_linkedin];
                linkedIn_button.enabled = button_enable_linkedin;
                [linkedIn_button addTarget:self action:@selector(linkedin_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.headerView addSubview:linkedIn_button];
                
                twitter_button = [[UIButton alloc] initWithFrame:CGRectMake(42.0f, 97.0f + expectedSize.height + website_expectedSize.height, 22.0f, 22.0f)];
                [twitter_button setAlpha:alphaValue_twitter];
                twitter_button.enabled = button_enable_twitter;
                [twitter_button addTarget:self action:@selector(twitter_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                [twitter_button setBackgroundImage:[UIImage imageNamed:@"icon-twitter-profile.png"] forState:UIControlStateNormal];
                [self.headerView addSubview:twitter_button];
                
                angellist_button = [[UIButton alloc] initWithFrame:CGRectMake(74.0f, 97.0f + expectedSize.height + website_expectedSize.height, 22.0f, 22.0f)];
                [angellist_button setBackgroundImage:[UIImage imageNamed:@"icon-angel-profile.png"] forState:UIControlStateNormal];
                [angellist_button setAlpha:alphaValue_angellist];
                angellist_button.enabled = button_enable_angellist;
                [angellist_button addTarget:self action:@selector(angellist_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.headerView addSubview:angellist_button];
                
                [photoCountLabel setText:@"0 photos"];
                
                PFQuery *queryPhotoCount = [PFQuery queryWithClassName:@"Photo"];
                [queryPhotoCount whereKey:kPAPPhotoUserKey equalTo:self.user];
                [queryPhotoCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [queryPhotoCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    if (!error) {
                        [photoCountLabel setText:[NSString stringWithFormat:@"%d moment%@", number, number==1?@"":@"s"]];
                        [[PAPCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
                    }
                }];
                
                [self.followerCountLabel setText:@"0 followers"];
                
                PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
                [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
                [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    if (!error) {
                        [self.followerCountLabel setText:[NSString stringWithFormat:@"%d follower%@  |", number, number==1?@"":@"s"]];
                    }
                }];
                
                NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
                [self.followingCountLabel setText:@"0 following"];
                if (followingDictionary) {
                    [self.followingCountLabel setText:[NSString stringWithFormat:@"%d following", (int)[[followingDictionary allValues] count]]];
                }
                
                PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
                [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
                [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    if (!error) {
                        [self.followingCountLabel setText:[NSString stringWithFormat:@"%d following", number]];
                    }
                }];
                
                if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                    [loadingActivityIndicatorView startAnimating];
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
                    
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
            self.tableView.tableHeaderView = headerView;
            
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Account info failed to load. Try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
        
        if([SVProgressHUD isVisible]){
            [SVProgressHUD dismiss];
        }
    }];

}

- (void)viewWillAppear:(BOOL)animated{
    // analytics
    [super viewWillAppear:YES];
    [PAPUtility captureScreenGA:@"Account"];
    
    
    if(![SVProgressHUD isVisible]){
        [SVProgressHUD show];
    }

    [self.user refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.user = (PFUser *)object;
    
        self.userDisplayNameLabel.text = [self.user objectForKey:@"displayName"];
        self.locationLabel.text = [self.user objectForKey:@"location"];
        self.descriptionLabel.text = [self.user objectForKey:@"description"];
        [self.websiteLink setTitle:[self.user objectForKey:@"website"] forState:UIControlStateNormal];
        self.websiteInfo = [self.user objectForKey:@"website"];
        self.industryLabel.text = [self.user objectForKey:@"industry"];
        self.angellist_url = [self.user objectForKey:@"angellist_url"];
        self.twitter_url = [self.user objectForKey:@"twitter_url"];
        self.linkedin_url = [self.user objectForKey:@"linkedin_url"];
        
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
        
        CGSize maximumLabelSize = CGSizeMake(300.0f, 32.0f);
        
        CGSize expectedSize = [self.descriptionLabel sizeThatFits:maximumLabelSize];
        CGSize industry_expectedSize = [self.industryLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f]];
        
        if ([self.websiteInfo length] > 0) {
            website_expectedSize = [self.websiteInfo sizeWithFont:[UIFont systemFontOfSize:13.0f]];
        } else {
            website_expectedSize = CGSizeMake(0.0f, 0.0f);
        }
        
        self.headerView.frame = CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 97.0f + expectedSize.height + website_expectedSize.height + 43.0f);
        [self.industryLabel setFrame:CGRectMake(320.0f - (industry_expectedSize.width + 20.0f), 97.0f + expectedSize.height + website_expectedSize.height, industry_expectedSize.width + 10.0f, 22.0f)];
        
        // refresh user stats, dismiss progress hud when finished
        [self refreshFollowerCount:^(BOOL completed) {
            if(completed){
                [SVProgressHUD dismiss];
            }
        }];
    }];
}

#pragma mark - Custom

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Profile",@"About This Version",@"Privacy Policy",@"Terms of Use",@"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}



#pragma mark - PFQueryTableViewController



- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
}

- (PFQuery *)queryForTable {
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:kPAPPhotoUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kPAPPhotoUserKey];
    
    return query;
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

- (void)followButtonAction:(id)sender {
    
    // analytics
    [PAPUtility captureEventGA:@"Engagement" action:@"Follow" label:@"User"];
    
    [self configureUnfollowButton];
    
    // show hud while numbers are refreshing
    [SVProgressHUD show];
    [PAPUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
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

    [self configureFollowButton];
    
    // show hud while numbers are refreshing
    [SVProgressHUD show];
    [PAPUtility unfollowUserEventually:self.user block:^(BOOL succeeded) {
        
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
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    button.frame=CGRectMake(0,0, 22.0f, 22.0f);
    [button addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *followButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = followButton;
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"follow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(followButtonAction:)];
    [[PAPCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
    button.frame=CGRectMake(0,0, 22.0f, 22.0f);
    [button addTarget:self action:@selector(unfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *unfollowButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = unfollowButton;
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"unfollow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(unfollowButtonAction:)];
    [[PAPCache sharedCache] setFollowStatus:YES user:self.user];
}

-(void)refreshFollowerCount:(void (^)(BOOL))completed{
    
    // return completed when both queries have finished
    self.userStatUpdateCount = 0;
    
    // refresh follower count
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            
            [self.followerCountLabel setText:[NSString stringWithFormat:@"%d follower%@  |", number, number==1?@"":@"s"]];
            
            // increment and check if we're done updating
            self.userStatUpdateCount++;
            if(self.userStatUpdateCount > 1){
                completed(YES);
            }
        }
    }];
    
    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
    if (followingDictionary) {
        [self.followingCountLabel setText:[NSString stringWithFormat:@"%d following", (int)[[followingDictionary allValues] count]]];
    }
    
    // refresh following count
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            
            [self.followingCountLabel setText:[NSString stringWithFormat:@"%d following", number]];
            
            // increment and check if we're done updating
            self.userStatUpdateCount++;
            if(self.userStatUpdateCount > 1){
                 completed(YES);
            }
        }
    }];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self.refreshControl endRefreshing];
    self.tableView.scrollEnabled = YES;
}

@end