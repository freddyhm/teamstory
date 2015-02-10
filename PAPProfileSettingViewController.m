//
//  PAPProfileSettingViewController.m
//  TeamStory
//

#import "PAPProfileSettingViewController.h"
#import "PAPAccountViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "Mixpanel.h"
#import <FlightRecorder/FlightRecorder.h>

#define SUCCESSFUL 1
#define IMAGE_NIL 2

#define offsetHeight 50.0f

@interface PAPProfileSettingViewController() {
    BOOL smallImage;
    int movementDistance;
    CGRect companyName_frame;
    CGRect email_address_frame;
    int lineStartPoint;
    int industry_pickerRow;
    bool profileExist;
}

@property (nonatomic,strong) UINavigationController *navController;
@property (nonatomic, strong) PAPAccountViewController *accountViewController_tabBar;
@property (nonatomic, strong) NSData *imageData_picker;
@property (nonatomic, strong) NSData *imageData_picker_small;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *location_user;
@property (nonatomic, strong) NSString *website_user;
@property (nonatomic, strong) NSString *displayName_user;
@property (nonatomic, strong) NSString *description_user;
@property (nonatomic, strong) NSString *email_user;
@property (nonatomic, strong) UIScrollView *backgroundView;
@property (nonatomic, strong) PFImageView* profilePictureImageView;
@property (nonatomic, strong) PFFile *imageProfileFile;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UITextField *twitter_textfield;
@property (nonatomic, strong) UITextField *linkedin_textfield;
@property (nonatomic, strong) UITextField *angelist_textfield;
@property (nonatomic, strong) UIButton *industry_button;
@property (nonatomic, strong) NSString *industry_user;
@property (nonatomic, strong) NSString *twitter_user;
@property (nonatomic, strong) NSString *linkedin_user;
@property (nonatomic, strong) NSString *angelist_user;
@property (nonatomic, strong) NSArray *industry_dataSource;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) NSString *industry_chosen;
@property (nonatomic, strong) UIPickerView *industry_pickerView;
@property (nonatomic, strong) UIButton *industry_chooseButton;
@property (nonatomic, strong) NSString *placeholderText;

@end

@implementation PAPProfileSettingViewController
@synthesize companyName;
@synthesize location;
@synthesize website;
@synthesize navController;
@synthesize accountViewController_tabBar;
@synthesize imageData_picker;
@synthesize imageData_picker_small;
@synthesize user;
@synthesize location_user;
@synthesize website_user;
@synthesize displayName_user;
@synthesize description_user;
@synthesize backgroundView;
@synthesize profilePictureImageView;
@synthesize imageProfileFile;
@synthesize email_address;
@synthesize email_user;
@synthesize saveButton;
@synthesize twitter_textfield;
@synthesize linkedin_textfield;
@synthesize angelist_textfield;
@synthesize industry_button;
@synthesize industry_user;
@synthesize twitter_user;
@synthesize linkedin_user;
@synthesize angelist_user;
@synthesize industry_dataSource;
@synthesize dimView;
@synthesize industry_chosen;
@synthesize industry_pickerView;
@synthesize industry_chooseButton;
@synthesize placeholderText;

#pragma mark - Initialization

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    user = [PFUser currentUser];
    
    // creating another method to call later for the freshing purpose.
    [self refreshView];
}

-(void)viewDidAppear:(BOOL)animated{
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Edit Profile"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"edit_profile_screen" action:@"viewed_edit_profile" label:@"" value:@""];
    
    [SVProgressHUD show];
    
    if(email_user != nil && [SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

- (void)refreshView {
    [self.navigationItem setHidesBackButton:YES];
    
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, [UIScreen mainScreen].bounds.size.height)];
    dimView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];
    dimView.hidden = YES;
    
    
    industry_dataSource = [NSArray arrayWithObjects:@"Information Technology", @"Consumers", @"Enterprises", @"Media", @"Education", @"Health Care", @"Finance", @"Sales and Marketing", @"Fashion", @"Health and Wellness", @"Retail", @"Sports", @"UI/UX Design", @"Travel", @"Web Development", @"Real Estate", @"Recruiting", @"Entertainment", @"Clean Technology", @"Events", @"B2B", @"Restaurants", @"Lifestyle", @"Big Data Analytics", @"Music Services", @"Event Management", @"Non Profits", @"Discovery", @"Incubators", @"Other", nil];
    
    NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
    profileExist = [profilExist_num boolValue];
    
    // Initialization
    UIColor *backgroundColor = [UIColor colorWithWhite:0.95f alpha:0.8f];
    UIColor *lineColor = [UIColor colorWithWhite:0.87f alpha:0.9f];
    UIFont *fonts = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    
    self.backgroundView = [[UIScrollView alloc] init];
    self.backgroundView.delegate = self;
    [self.backgroundView setBackgroundColor:backgroundColor];
    
    UIButton *profileImagePicker = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    [profileImagePicker setImage:[UIImage imageNamed:@"icon-upload.png"] forState:UIControlStateNormal];
    [profileImagePicker addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.user refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            self.user = (PFUser *)object;
            
            location_user = self.user[@"location"];
            website_user = self.user[@"website"];
            displayName_user = self.user[@"displayName"];
            self.description_user = self.user[@"description"];
            
            email_user = self.user[@"email"];
            industry_user = self.user[@"industry"];
            twitter_user = self.user[@"twitter_url"];
            linkedin_user = self.user[@"linkedin_url"];
            angelist_user = self.user[@"angellist_url"];
            imageProfileFile = [self.user objectForKey:@"profilePictureMedium"];
            
            if ([location_user length] == 0) {
                location_user = @"Location";
            }
            if ([website_user length] == 0) {
                website_user = @"Website URL";
            }
            if ([displayName_user length] == 0) {
                displayName_user = @"Display or Company Name";
            }
            if ([self.description_user length] == 0) {
                self.description_user = @"Description";
            }
            if ([industry_user length] == 0) {
                industry_user = @"Industry / Market";
            }
            if ([twitter_user length] == 0) {
                twitter_user = @"Twitter";
            }
            if ([linkedin_user length] == 0) {
                linkedin_user = @"LinkedIn";
            }
            if ([angelist_user length] == 0) {
                angelist_user = @"AngelList";
            }
            
            // Do not display back button if user is first time logging in.
            if (profileExist == true) {
                UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [backButton setFrame:CGRectMake( 0.0f, 0.0f, 22.0f, 22.0f)];
                [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
                [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
                
                UIButton *navSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [navSaveButton setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 22.0f)];
                [navSaveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [navSaveButton setBackgroundImage:[UIImage imageNamed:@"button_done.png"] forState:UIControlStateNormal];
                [navSaveButton setBackgroundImage:[UIImage imageNamed:@"button_done_selected.png"] forState:UIControlStateHighlighted];
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navSaveButton];
                
                [self.view addSubview:profileImagePicker];
                companyName_frame = CGRectMake( 60.0f, 12.5f, 250.0f, 25.0f);
                email_address_frame = CGRectMake( 60.0f, 12.5f + offsetHeight, 250.0f, 25.0f);
                [self.backgroundView setContentSize:CGSizeMake(320.0f, 500.0f)];
                
                if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
                    profileImagePicker.frame = CGRectMake( 122.5f, 31.0f, 75.0f, 75.0f );
                    self.backgroundView.frame = CGRectMake(0.0f, self.view.bounds.size.height - 280.0f, self.view.bounds.size.width, 280.0f);
                    saveButton.frame = CGRectMake(35.0f, self.backgroundView.bounds.size.height - 60.0f, 250.0f, 45.0f);
                    profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 122.5f, 31.0f, 75.0f, 75.0f )];
                } else {
                    profileImagePicker.frame = CGRectMake( 122.5f, 71.0f, 75.0f, 75.0f );
                    self.backgroundView.frame = CGRectMake(0.0f, self.view.bounds.size.height - 280.0f, self.view.bounds.size.width, 280.0f);
                    saveButton.frame = CGRectMake(35.0f, self.backgroundView.bounds.size.height - 70.0f, 250.0f, 45.0f);
                    profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 122.5f, 71.0f, 75.0f, 75.0f )];
                }
                
                UIImageView *companyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"companyName.png"]];
                [companyImageView setFrame:CGRectMake( 10.0f, 5.0f, 40.0f, 40.0f)];
                [self.backgroundView addSubview:companyImageView];
                
                UIImageView *emailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-email.png"]];
                [emailImageView setFrame:CGRectMake( 10.0f, 55.0f, 40.0f, 40.0f)];
                [self.backgroundView addSubview:emailImageView];
                
                lineStartPoint = 0;
                
            } else {
                saveButton = [[UIButton alloc] init];
                
                profileImagePicker.frame = CGRectMake( 10.0f, 15.0f, 70.0f, 70.0f );
                profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 10.0f, -5.0f, 70.0f, 70.0f )];
                [self.backgroundView addSubview:profileImagePicker];
                companyName_frame = CGRectMake( 120.0f, 12.5f , 200.0f, 25.0f);
                email_address_frame = CGRectMake( 120.0f, 12.5f + offsetHeight, 200.0f, 25.0f);
                
                if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
                    [self.backgroundView setContentSize:CGSizeMake(320.0f, 500.0f)];
                    self.backgroundView.frame = CGRectMake(0.0f, 50.0f, self.view.bounds.size.width, self.view.bounds.size.height - 50.0f);
                    saveButton.frame = CGRectMake(35.0f, 455.0f, 250.0f, 40.0f);
                } else {
                    self.backgroundView.frame = CGRectMake(0.0f, 50.0f, self.view.bounds.size.width, self.view.bounds.size.height - 50.0f);
                    saveButton.frame = CGRectMake(35.0f, 460.0f, 250.0f, 40.0f);
                }
                
                UIImageView *companyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"companyName.png"]];
                [companyImageView setFrame:CGRectMake( 80.0f, 5.0f, 40.0f, 40.0f)];
                [self.backgroundView addSubview:companyImageView];
                
                UIImageView *emailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-email.png"]];
                [emailImageView setFrame:CGRectMake( 80.0f, 55.0f, 40.0f, 40.0f)];
                [self.backgroundView addSubview:emailImageView];
                
                lineStartPoint = 90;
            }
            
            [self.view addSubview:self.backgroundView];
            
            [[saveButton titleLabel] setFont:[UIFont boldSystemFontOfSize:14.0f]];
            [saveButton setBackgroundColor:[UIColor colorWithRed:91.0f/255.0f green:194.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
            [saveButton setTitle:@"Apply for Membership" forState:UIControlStateNormal];
            [saveButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
            [saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [backgroundView addSubview:saveButton];
            
            
            if (imageProfileFile) {
                [profilePictureImageView setFile:imageProfileFile];
                [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
                    if (!error) {
                        [UIView animateWithDuration:0.05f animations:^{
                            profilePictureImageView.alpha = 1.0f;
                        }];
                    }
                }];
            } else {
                NSLog(@"ImageFile Not found");
            }
            
            [profilePictureImageView setContentMode:UIViewContentModeScaleToFill];
            [self.view addSubview:profilePictureImageView];
            
            UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
            [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
            [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
            [profileImagePicker addGestureRecognizer:swipeUpGestureRecognizer];
            
            UIImageView *locationImageView = [[UIImageView alloc] initWithImage:nil];
            [locationImageView setImage:[UIImage imageNamed:@"profileLocation.png"]];
            [locationImageView setFrame:CGRectMake( 10.0f, 105.0f, 40.0f, 40.0f)];
            [self.backgroundView addSubview:locationImageView];
            
            UIImageView *userDescriptionImageView = [[UIImageView alloc] initWithImage:nil];
            [userDescriptionImageView setImage:[UIImage imageNamed:@"profileDescription.png"]];
            [userDescriptionImageView setFrame:CGRectMake( 10.0f, 155.0f, 40.0f, 40.0f)];
            [self.backgroundView addSubview:userDescriptionImageView];
            
            UIImageView *industryImageView = [[UIImageView alloc] initWithImage:nil];
            [industryImageView setImage:[UIImage imageNamed:@"icon-industry.png"]];
            [industryImageView setFrame:CGRectMake( 10.0f, 205.0f, 40.0f, 40.0f)];
            [self.backgroundView addSubview:industryImageView];
            
            UIImageView *websiteImageView = [[UIImageView alloc] initWithImage:nil];
            [websiteImageView setImage:[UIImage imageNamed:@"profileWebsite.png"]];
            [websiteImageView setFrame:CGRectMake( 10.0f, 255.0f, 40.0f, 40.0f)];
            [self.backgroundView addSubview:websiteImageView];
            
            UIImageView *twitterImageView = [[UIImageView alloc] initWithImage:nil];
            [twitterImageView setImage:[UIImage imageNamed:@"icon-twitter.png"]];
            [twitterImageView setFrame:CGRectMake( 10.0f, 305.0f, 40.0f, 40.0f)];
            [self.backgroundView addSubview:twitterImageView];
            
            UIImageView *linkedInImageView = [[UIImageView alloc] initWithImage:nil];
            [linkedInImageView setImage:[UIImage imageNamed:@"icon-linkedin.png"]];
            [linkedInImageView setFrame:CGRectMake( 10.0f, 355.0f, 40.0f, 40.0f)];
            [self.backgroundView addSubview:linkedInImageView];
            
            UIImageView *angelistImageView = [[UIImageView alloc] initWithImage:nil];
            [angelistImageView setImage:[UIImage imageNamed:@"icon-angel.png"]];
            [angelistImageView setFrame:CGRectMake( 10.0f, 405.0f, 40.0f, 40.0f)];
            [self.backgroundView addSubview:angelistImageView];
            
            self.companyName = [[UITextField alloc] initWithFrame:companyName_frame];
            [self.companyName setBackgroundColor:[UIColor clearColor]];
            [self.companyName setFont:fonts];
            self.companyName.placeholder = displayName_user;
            self.companyName.userInteractionEnabled = YES;
            self.companyName.delegate = self;
            [self.backgroundView addSubview:self.companyName];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(lineStartPoint, 50.0f, 320.0f, 1)];
            lineView.backgroundColor = lineColor;
            [self.backgroundView addSubview:lineView];
            
            self.email_address = [[UITextField alloc] initWithFrame:email_address_frame];
            self.email_address.autocorrectionType = UITextAutocorrectionTypeNo;
            [self.email_address setBackgroundColor:[UIColor clearColor]];
            [self.email_address setFont:fonts];
            self.email_address.autocapitalizationType = UITextAutocapitalizationTypeNone;
            if ([email_user length] == 0) {
                self.email_address.placeholder = @"Email";
                self.email_address.userInteractionEnabled = YES;
            } else {
                self.email_address.placeholder = email_user;
                self.email_address.userInteractionEnabled = NO;
            }
            self.email_address.delegate = self;
            [self.backgroundView addSubview:self.email_address];
            
            UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 100.0f, self.view.bounds.size.width, 1)];
            lineView1.backgroundColor = lineColor;
            [self.backgroundView addSubview:lineView1];
            
            CGRect location_frame = CGRectMake( 60.0f, 12.5f + offsetHeight * 2, 250.0f, 25.0f);
            self.location = [[UITextField alloc] initWithFrame:location_frame];
            self.location.autocorrectionType = UITextAutocorrectionTypeNo;
            [self.location setBackgroundColor:[UIColor clearColor]];
            [self.location setFont:fonts];
            self.location.placeholder = location_user;
            self.location.userInteractionEnabled = YES;
            self.location.delegate = self;
            [self.location resignFirstResponder];
            [self.backgroundView addSubview:self.location];
            
            UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 150.0f, self.view.bounds.size.width, 1)];
            lineView2.backgroundColor = lineColor;
            [self.backgroundView addSubview:lineView2];
            
            CGRect userDescription_frame = CGRectMake( 60.0f, 12.5f + offsetHeight * 3, 250.0f, 25.0f);
            self.userDescription = [[UITextField alloc] initWithFrame:userDescription_frame];
            self.userDescription.autocorrectionType = UITextAutocorrectionTypeNo;
            [self.userDescription setBackgroundColor:[UIColor clearColor]];
            [self.userDescription setFont:fonts];
            self.userDescription.placeholder = description_user;
            
            CGRect description_frame = CGRectMake( 60.0f, 12.5f + offsetHeight * 3, 250.0f, 25.0f);
            self.userDescription = [[UITextField alloc] initWithFrame:description_frame];
            self.userDescription.autocorrectionType = UITextAutocorrectionTypeNo;
            [self.userDescription setBackgroundColor:[UIColor clearColor]];
            [self.userDescription setFont:fonts];
            self.userDescription.placeholder = self.description_user;
            self.userDescription.userInteractionEnabled = YES;
            self.userDescription.delegate = self;
            [self.userDescription resignFirstResponder];
            [self.backgroundView addSubview:self.userDescription];
            
            UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 200.0f, self.view.bounds.size.width, 1)];
            lineView3.backgroundColor = lineColor;
            [self.backgroundView addSubview:lineView3];
            
            CGRect industry_frame = CGRectMake( 60.0f, 12.5f + offsetHeight * 4, 250.0f, 25.0f);
            self.industry_button = [[UIButton alloc] initWithFrame:industry_frame];
            [self.industry_button setTitle:industry_user forState:UIControlStateNormal];
            [self.industry_button setBackgroundColor:[UIColor clearColor]];
            //         [self.industry_button.titleLabel setTextColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
            [self.industry_button setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
            [self.industry_button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [self.industry_button.titleLabel setFont:fonts];
            [self.industry_button addTarget:self action:@selector(industry_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.backgroundView addSubview:self.industry_button];
            
            UIView *lineView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 250.0f, self.view.bounds.size.width, 1)];
            lineView4.backgroundColor = lineColor;
            [self.backgroundView addSubview:lineView4];
            
            CGRect website_frame = CGRectMake( 60.0f, 12.5f + offsetHeight * 5, 250.0f, 25.0f);
            self.website = [[UITextField alloc] initWithFrame:website_frame];
            [self.website setBackgroundColor:[UIColor clearColor]];
            self.website.autocorrectionType = UITextAutocorrectionTypeNo;
            [self.website setFont:fonts];
            self.website.placeholder = website_user;
            self.website.userInteractionEnabled = YES;
            self.website.delegate = self;
            self.website.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [self.website resignFirstResponder];
            [self.backgroundView addSubview:self.website];
            
            UIView *lineView5 = [[UIView alloc] initWithFrame:CGRectMake(0, 300.0f, self.view.bounds.size.width, 1)];
            lineView5.backgroundColor = lineColor;
            [self.backgroundView addSubview:lineView5];
            
            CGRect twitter_frame = CGRectMake( 60.0f, 12.5f + offsetHeight * 6, 250.0f, 25.0f);
            self.twitter_textfield = [[UITextField alloc] initWithFrame:twitter_frame];
            self.twitter_textfield.autocorrectionType = UITextAutocorrectionTypeNo;
            [self.twitter_textfield setBackgroundColor:[UIColor clearColor]];
            [self.twitter_textfield setFont:fonts];
            self.twitter_textfield.placeholder = twitter_user;
            self.twitter_textfield.userInteractionEnabled = YES;
            self.twitter_textfield.delegate = self;
            self.twitter_textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [self.twitter_textfield resignFirstResponder];
            [self.backgroundView addSubview:self.twitter_textfield];
            
            UIView *lineView6 = [[UIView alloc] initWithFrame:CGRectMake(0, 350.0f, self.view.bounds.size.width, 1)];
            lineView6.backgroundColor = lineColor;
            [self.backgroundView addSubview:lineView6];
            
            CGRect linkedIn_frame = CGRectMake( 60.0f, 12.5f + offsetHeight * 7, 250.0f, 25.0f);
            self.linkedin_textfield = [[UITextField alloc] initWithFrame:linkedIn_frame];
            [self.linkedin_textfield setBackgroundColor:[UIColor clearColor]];
            self.linkedin_textfield.autocorrectionType = UITextAutocorrectionTypeNo;
            [self.linkedin_textfield setFont:fonts];
            self.linkedin_textfield.placeholder = linkedin_user;
            self.linkedin_textfield.userInteractionEnabled = YES;
            self.linkedin_textfield.delegate = self;
            self.linkedin_textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [self.linkedin_textfield resignFirstResponder];
            [self.backgroundView addSubview:self.linkedin_textfield];
            
            UIView *lineView7 = [[UIView alloc] initWithFrame:CGRectMake(0, 400.0f, self.view.bounds.size.width, 1)];
            lineView7.backgroundColor = lineColor;
            [self.backgroundView addSubview:lineView7];
            
            CGRect angel_frame = CGRectMake( 60.0f, 12.5f + offsetHeight * 8, 250.0f, 25.0f);
            self.angelist_textfield = [[UITextField alloc] initWithFrame:angel_frame];
            self.angelist_textfield.autocorrectionType = UITextAutocorrectionTypeNo;
            [self.angelist_textfield setBackgroundColor:[UIColor clearColor]];
            [self.angelist_textfield setFont:fonts];
            self.angelist_textfield.placeholder = angelist_user;
            self.angelist_textfield.userInteractionEnabled = YES;
            self.angelist_textfield.delegate = self;
            self.angelist_textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [self.angelist_textfield resignFirstResponder];
            [self.backgroundView addSubview:self.angelist_textfield];
            
            UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(dismissKeyboard)];
            
            [self.view addGestureRecognizer:tapOutside];
            [self.view addSubview:dimView];
            [SVProgressHUD dismiss];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Profile fetch failed. Check your network connection and try again" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert show];
            
            if(profileExist == true){
                UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [backButton setFrame:CGRectMake( 0.0f, 0.0f, 22.0f, 22.0f)];
                [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
                [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
            }
        }
    }];
}


#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.backgroundView setContentOffset:CGPointMake(0, 20)];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissKeyboard];
    [self.profilePictureImageView removeFromSuperview];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *smallRoundedImage = [PAPUtility resizeImage:image width:84.0f height:84.0f];
    UIImage *resizedImage = [PAPUtility resizeImage:image width:200.0f height:200.0f];
    
    // Upload image
    imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
    imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
    bool profileExist_user = [profilExist_num boolValue];
    
    if (!profileExist_user) {
        /*
         if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
         cameraButton.frame = CGRectMake( 122.5f, 35.0f, 75.0f, 75.0f );
         cameraButton.center = CGPointMake(160.0f, 73.0f);
         } else {
         cameraButton.frame = CGRectMake( 122.5f, 85.0f, 75.0f, 75.0f );
         cameraButton.center = CGPointMake(160.0f, 123.0f);
         }
         */
        
        //prevents from poping back to -20 pixels;
        [self.backgroundView setContentOffset:CGPointMake(0, 20)];
        
        cameraButton.frame = CGRectMake(10.0f, 15.0f, 70.0f, 70.0f);
        cameraButton.frame = CGRectIntegral(cameraButton.frame);
        [cameraButton setImage:resizedImage forState:UIControlStateNormal];
        [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundView addSubview:cameraButton];
    } else {
        if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
            cameraButton.frame = CGRectMake( 122.5f, 31.0f, 75.0f, 75.0f );
        } else {
            cameraButton.frame = CGRectMake( 122.5f, 71.0f, 75.0f, 75.0f );
        }
        
        [cameraButton setImage:resizedImage forState:UIControlStateNormal];
        [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cameraButton];
    }
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [cameraButton addGestureRecognizer:swipeUpGestureRecognizer];
    
}

-(void)uploadImage_small:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
    //HUD creation here (see example for code)
    
    [SVProgressHUD show];
    
    user = [PFUser currentUser];
    user[@"profilePictureSmall"] = imageFile;
    
    [user saveInBackground];
    [SVProgressHUD dismiss];
}

-(void)uploadImage_medium:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
    [SVProgressHUD show];
    user = [PFUser currentUser];
    user[@"profilePictureMedium"] = imageFile;
    
    [user saveInBackground];
    [SVProgressHUD dismiss];
}

#pragma mark - UINavigationControllerDelegate


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // keep status bar white, in ios7 changes in imagepicker
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navController = navigationController;
    
    viewController.navigationItem.titleView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    viewController.navigationItem.rightBarButtonItem = nil;
    
    // set color of nav bar to custom grey
    [viewController.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    viewController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(79/255.0) green:(91/255.0) blue:(100/255.0) alpha:(0.0/255.0)];
    viewController.navigationController.navigationBar.translucent = NO;
    
    if ([viewController.title isEqualToString:@"Photos"])
    {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(imagePickerControllerDidCancel:)];
        
    }else{
        
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backToPhotoAlbum)];
        
    }
    
    [viewController.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
}

-(void)backToPhotoAlbum{
    
    // triggered when in selected picture in picker
    [self.navController popViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}


#pragma mark - PAPTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

#pragma mark - ()

- (void) photo_picker_init {
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        [actionSheet showInView:self.view];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

- (void)photoCaptureButtonAction:(id)sender {
    [self photo_picker_init];
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}


- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    }else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
              && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    // if ip
    if ([[[UIDevice currentDevice] model] isEqualToString: @"iPad"] || [[[UIDevice currentDevice] model] isEqualToString: @"iPad Simulator"]) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:cameraUI];
        
        [popover presentPopoverFromRect:self.view.bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }else{
        
        [self presentViewController:cameraUI animated:YES completion:nil];
    }
    
    return YES;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self shouldPresentPhotoCaptureController];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == companyName && email_address.userInteractionEnabled == YES) {
        [email_address becomeFirstResponder];
    } else if (textField == companyName && email_address.userInteractionEnabled == NO) {
        [location becomeFirstResponder];
    } else if (textField == location) {
        [self.userDescription becomeFirstResponder];
    } else if (textField == website) {
        [twitter_textfield becomeFirstResponder];
    } else if (textField == twitter_textfield) {
        [linkedin_textfield becomeFirstResponder];
    } else if (textField == linkedin_textfield) {
        [angelist_textfield becomeFirstResponder];
    } else if (textField == angelist_textfield) {
        [textField endEditing:YES];
    }
    
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == twitter_textfield && [textField.text isEqual: @"https://twitter.com/"]) {
        textField.text = @"";
    } else if (textField == linkedin_textfield && [textField.text isEqualToString:@"https://www.linkedin.com/in/"]) {
        textField.text = @"";
    } else if (textField == angelist_textfield && [textField.text isEqualToString:@"https://angel.co/"]) {
        textField.text = @"";
    } else if (textField == website && [textField.text isEqualToString:@"http://"]) {
        textField.text = @"";
    }
    
    return YES;
}


#pragma mark - ()

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonAction:(id)sender {
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Changed Profile"}];
    
    [SVProgressHUD show];
    
    [self.view endEditing:YES];
    NSString* companyName_input = self.companyName.text;
    NSString* location_input = self.location.text;
    NSString* description_input = self.userDescription.text;
    NSString* website_input = [self.website.text lowercaseString];
    NSString* twitter_input = self.twitter_textfield.text;
    NSString* industry_input = self.industry_button.titleLabel.text;
    NSString* linkedin_input = self.linkedin_textfield.text;
    NSString* angellist_input = self.angelist_textfield.text;
    NSString* email_input = self.email_address.text;
    NSString* email_current_input = self.user[@"email"];
    NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
    bool profileExist_user = [profilExist_num boolValue];
    saveButton.userInteractionEnabled = NO;
    
    if (profileExist_user == true) {
        if (!imageData_picker) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You did not select any image. Would you like to update the image?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            alert.tag = IMAGE_NIL;
            [alert show];
            return;
            
        } else {
            [self uploadImage_medium:imageData_picker];
            [self uploadImage_small:imageData_picker_small];
        }
        
        if ([companyName_input length] > 0) {
            self.user[@"displayName"] = companyName_input;
        }
        if ([location_input length] > 0) {
            self.user[@"location"] = location_input;
        }
        if ([description_input length] > 0) {
            self.user[@"description"] = description_input;
        }
        if ([website_input length] > 0) {
            self.user[@"website"] = website_input;
        }
        if ([industry_input length] > 0 && ![industry_input isEqualToString:@"Industry / Market"]) {
            self.user[@"industry"] = industry_input;
        }
        if ([twitter_input length] > 0) {
            self.user[@"twitter_url"] = twitter_input;
        }
        if ([linkedin_input length] > 0) {
            self.user[@"linkedin_url"] = linkedin_input;
        }
        if ([angellist_input length] > 0) {
            self.user[@"angellist_url"] = angellist_input;
        }
        /*
         if (([email_input length] > 0 && [self NSStringIsValidEmail:email_input]) || email_current_input) {
         self.user[@"email"] = email_input;
         } else {
         UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your email input is not valid." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alert.alertViewStyle = UIAlertViewStyleDefault;
         [alert show];
         return;
         }
         */
        //[[PFUser currentUser] saveEventually];
        [SVProgressHUD show];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [SVProgressHUD dismiss];
            
            if(succeeded){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                alert.tag = SUCCESSFUL;
                [alert show];
                
            }else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your Information could not be saved. Reach us at info@teamstoryapp.com" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
            }
        }];
        
    } else {
        if ([companyName_input length] > 0 && [location_input length] > 0 && (([email_input length] > 0 && [self NSStringIsValidEmail:email_input]) || email_current_input )) {
            
            if (!imageData_picker) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You did not select any image. Would you like to update the image?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                alert.tag = IMAGE_NIL;
                [alert show];
                return;
                
            } else {
                [self uploadImage_medium:imageData_picker];
                [self uploadImage_small:imageData_picker_small];
            }
            
            // mendatory fields
            self.user[@"displayName"] = companyName_input;
            self.user[@"location"] = location_input;
            
            // optional fields
            if ([description_input length] > 0) {
                self.user[@"description"] = description_input;
            }
            if ([website_input length] > 0) {
                self.user[@"website"] = website_input;
            }
            if ([industry_input length] > 0 && ![industry_input isEqualToString:@"Industry / Market"]) {
                self.user[@"industry"] = industry_input;
            }
            if ([twitter_input length] > 0) {
                self.user[@"twitter_url"] = twitter_input;
            }
            if ([linkedin_input length] > 0) {
                self.user[@"linkedin_url"] = linkedin_input;
            }
            if ([angellist_input length] > 0) {
                self.user[@"angellist_url"] = angellist_input;
            }
            
            if ([email_current_input length] == 0) {
                self.user[@"email"] = email_input;
            }
            
            
            PFObject *membershipReceived = [PFObject objectWithClassName:kPAPActivityClassKey];
            [membershipReceived setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
            [membershipReceived setObject:@"membership" forKey:@"type"];
            
            PFACL *membershipACL = [PFACL ACL];
            [membershipACL setPublicReadAccess:YES];
            membershipReceived.ACL = membershipACL;
            
            // make sure our join activity is always earlier than a follow
            //[membershipReceived saveEventually];
            [membershipReceived saveInBackground];
            
            [SVProgressHUD show];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [SVProgressHUD dismiss];
                
                if(succeeded){
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    alert.tag = SUCCESSFUL;
                    [alert show];
                }else{
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your Information could not be saved. Reach us at info@teamstoryapp.com" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                }
            }];
            
        } else {
            saveButton.userInteractionEnabled = YES;
            
            if ([companyName_input length] == 0) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter Display Name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
                
            } else if ([location_input length] == 0) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your Location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
            } else if ([email_input length] == 0 || !self.user[@"email"] || ![self NSStringIsValidEmail:email_input]){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your Email input is not valid." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
            } else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please choose User Type." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
            }
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == IMAGE_NIL) {
        if (buttonIndex == 1) {
            [self.view endEditing:YES];
            NSLog(@"image_nil tag");
            
            [self photo_picker_init];
            saveButton.userInteractionEnabled = YES;
            
        } else if (buttonIndex == 0) {
            NSString* companyName_input = self.companyName.text;
            NSString* location_input = self.location.text;
            NSString* userDescription_input = self.userDescription.text;

            NSString* website_input = [self.website.text lowercaseString];
            NSString* email_input = self.email_address.text;
            NSString* industry_input = self.industry_button.titleLabel.text;
            NSString* twitter_input = self.twitter_textfield.text;
            NSString* linkedin_input = self.linkedin_textfield.text;
            NSString* angellist_input = self.angelist_textfield.text;
            bool profileExist_user = self.user[@"profileExist"];
            
            if ([companyName_input length] > 0) {
                self.user[@"displayName"] = companyName_input;
            }
            if ([location_input length] > 0) {
                self.user[@"location"] = location_input;
            }
            if ([userDescription_input length] > 0) {
                self.user[@"description"] = userDescription_input;
            }
            if ([website_input length] > 0) {
                self.user[@"website"] = website_input;
            }
            if ([email_input length] > 0 ) {
                self.user[@"email"] = email_input;
            }
            if ([industry_input length] > 0 && ![industry_input isEqualToString:@"Industry / Market"]) {
                self.user[@"industry"] = industry_input;
            }
            if ([twitter_input length] > 0) {
                self.user[@"twitter_url"] = twitter_input;
            }
            if ([linkedin_input length] > 0) {
                self.user[@"linkedin_url"] = linkedin_input;
            }
            if ([angellist_input length] > 0) {
                self.user[@"angellist_url"] = angellist_input;
            }
            
            if (profileExist_user == NO) {
                UIImage *image = [UIImage imageNamed:@"default-pic.png"];
                
                UIImage *smallRoundedImage = [PAPUtility resizeImage:image width:84.0f height:84.0f];
                UIImage *resizedImage = [PAPUtility resizeImage:image width:200.0f height:200.0f];
                
                // Upload image
                imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
                imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
                
                [self uploadImage_small:imageData_picker_small];
                [self uploadImage_medium:imageData_picker];
                
                PFObject *membershipReceived = [PFObject objectWithClassName:kPAPActivityClassKey];
                [membershipReceived setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                [membershipReceived setObject:@"membership" forKey:@"type"];
                
                PFACL *membershipACL = [PFACL ACL];
                [membershipACL setPublicReadAccess:YES];
                membershipReceived.ACL = membershipACL;
                
                // make sure our join activity is always earlier than a follow
                //[membershipReceived saveEventually];
                [membershipReceived saveInBackground];
            }
            
            //[[PFUser currentUser] saveEventually];
            
            [SVProgressHUD show];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [SVProgressHUD dismiss];
                
                if(succeeded){
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    alert.tag = SUCCESSFUL;
                    [alert show];
                    
                    // Notify timeline so a refresh is triggered
                    [[NSNotificationCenter defaultCenter] postNotificationName:PAPProfileSettingViewControllerUserChangedProfile object:nil userInfo:nil];
                    
                }else{
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your Information could not be saved. Reach us at info@teamstoryapp.com" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                }
                
            }];
            
            
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField: textField up: YES];
    placeholderText = textField.placeholder;
    textField.placeholder = nil;
    
    if (textField == companyName || textField == email_address) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    
    if (textField == twitter_textfield && [textField.text length] == 0) {
        twitter_textfield.text = @"https://twitter.com/";
    } else if (textField == linkedin_textfield && [textField.text length] == 0) {
        linkedin_textfield.text = @"https://www.linkedin.com/in/";
    } else if (textField == angelist_textfield && [textField.text length] == 0) {
        angelist_textfield.text = @"https://angel.co/";
    } else if (textField == website && [textField.text length] == 0) {
        website.text = @"http://";
    }
    
    if (textField == twitter_textfield && ![twitter_user isEqualToString:@"Twitter"]) {
        twitter_textfield.text = twitter_user;
    } else if (textField == linkedin_textfield && ![linkedin_user isEqualToString:@"LinkedIn"]) {
        linkedin_textfield.text = linkedin_user;
    } else if (textField == angelist_textfield && ![angelist_user isEqualToString:@"AngelList"]) {
        angelist_textfield.text = angelist_user;
    } else if (textField == website && ![website_user isEqualToString:@"Website URL"]) {
        website.text = website_user;
    } else if (textField == self.userDescription && ![self.description_user isEqualToString:@"Description"]) {
        self.userDescription.text = self.description_user;
    } else if (textField == companyName && ![displayName_user isEqualToString:@"Display or Company Name"]) {
        companyName.text = displayName_user;
    } else if (textField == location && ![location_user isEqualToString:@"Location"]) {
        location.text = location_user;
    }
}

- (void) industry_buttonAction:(id)sender {
    [self.view endEditing:YES];
    dimView.hidden = NO;
    
    industry_pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 270.0f, 320.0f, 0.0f)];
    industry_pickerView.delegate = self;
    industry_pickerView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.95f];
    industry_pickerView.showsSelectionIndicator = YES;
    [self.view addSubview:industry_pickerView];
    
    industry_chooseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 54.0f, 320.0f, 54.0f)];
    [industry_chooseButton setBackgroundColor:[UIColor colorWithRed:91.0f/255.0f green:194.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
    [industry_chooseButton setTitle:@"Choose" forState:UIControlStateNormal];
    [industry_chooseButton addTarget:self action:@selector(industry_chooseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:industry_chooseButton];
}

- (void) industry_chooseButtonAction:(id)sender {
    dimView.hidden = YES;
    [industry_pickerView removeFromSuperview];
    [industry_chooseButton removeFromSuperview];
    
    [industry_button setTitle:[industry_dataSource objectAtIndex:industry_pickerRow] forState:UIControlStateNormal];
    [self.industry_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField: textField up: NO];
    textField.placeholder = placeholderText;
    
    if (textField == companyName && [(AppDelegate*)[[UIApplication sharedApplication] delegate] isParseReachable]) {
        [SVProgressHUD showWithStatus:@"Validating User Name"];
        [self textfieldUserInteractionControl:NO];
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"displayName" equalTo:textField.text];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            [SVProgressHUD dismiss];
            
            [self textfieldUserInteractionControl:YES];
            
            if (!error) {
                if ((number > 0 || [textField.text length] == 0) && (![[[PFUser currentUser] objectForKey:@"displayName"] isEqualToString:textField.text])) {
                    self.dimView.hidden = YES;
                    [self.view endEditing:YES];
                    [self.industry_chooseButton removeFromSuperview];
                    [self.industry_pickerView removeFromSuperview];
                    companyName.text = @"";
                    [companyName becomeFirstResponder];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Display name is already in use. Please choose another name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                }
            } else {
                NSLog(@"%@", error);
            }
            
        }];
    } else if (textField == email_address && [(AppDelegate*)[[UIApplication sharedApplication] delegate] isParseReachable]) {
        [SVProgressHUD showWithStatus:@"Validating Email"];
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"email" equalTo :email_address.text];
        [userQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            [SVProgressHUD dismiss];
            
            if (!error) {
                if (number > 0) {
                    email_address.text = @"";
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The email address is already in use. Please use another email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                }
            } else {
                NSLog(@"%@", error);
            }
        }];
        
    }
    
    if (textField == twitter_textfield && ![twitter_user isEqualToString:@"Twitter"]) {
        twitter_user = twitter_textfield.text;
    } else if (textField == linkedin_textfield && ![linkedin_user isEqualToString:@"LinkedIn"]) {
        linkedin_user = linkedin_textfield.text;
    } else if (textField == angelist_textfield && ![angelist_user isEqualToString:@"AngelList"]) {
        angelist_user = angelist_textfield.text;
    } else if (textField == website && ![website_user isEqualToString:@"Website URL"]) {
        website_user = website.text;
    } else if (textField == self.userDescription && ![self.description_user isEqualToString:@"Description"]) {
        self.description_user = self.userDescription.text;
    } else if (textField == companyName && ![displayName_user isEqualToString:@"Display or Company Name"]) {
        displayName_user = companyName.text;
    } else if (textField == location && ![location_user isEqualToString:@"Location"]) {
        location_user = location.text;
    }
    
}

- (void) textfieldUserInteractionControl:(BOOL) enable {
    [location setUserInteractionEnabled:enable];
    [self.userDescription setUserInteractionEnabled:enable];
    [website setUserInteractionEnabled:enable];
    self.navigationItem.rightBarButtonItem.enabled = enable;
    self.navigationItem.leftBarButtonItem.enabled = enable;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    [SVProgressHUD dismiss];
    float movementDuration = 0.1f; // tweak as needed
    
    if (profileExist == YES) {
        if ([UIScreen mainScreen].bounds.size.height == 480) {
            movementDistance = 130;
            if (textField == twitter_textfield || textField == linkedin_textfield || textField == angelist_textfield) {
                movementDistance = 200;
            }
        } else {
            movementDistance = 200;
        }
    } else {
        if ([UIScreen mainScreen].bounds.size.height == 480) {
            if (textField == twitter_textfield || textField == linkedin_textfield || textField == angelist_textfield || textField == website) {
                movementDistance = 200;
            } else if (textField == self.userDescription) {
                movementDistance = 100;
            } else {
                movementDistance = 0;
            }
        } else {
            if (textField == twitter_textfield || textField == linkedin_textfield || textField == angelist_textfield || textField == website) {
                movementDistance = 200;
            } else {
                movementDistance = 0;
            }
        }
    }
    
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
    
    self.dimView.hidden = YES;
    [self.industry_pickerView removeFromSuperview];
    [self.industry_chooseButton removeFromSuperview];
    if (self.industry_button.titleLabel.textColor != [UIColor blackColor]) {
        [self.industry_button setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
    }
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 30;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 30;
    
    return numRows;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    industry_pickerRow = (int)row;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [industry_dataSource objectAtIndex:row];
}

@end

