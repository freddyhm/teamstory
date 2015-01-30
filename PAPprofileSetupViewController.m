//
//  PAPprofileSetupViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 7/31/14.
//
//

#import "PAPprofileSetupViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "PAPUtility.h"
#import "Mixpanel.h"
#import "FlightRecorder.h"
#import "Intercom.h"

#define SUCCESSFUL 1
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface PAPprofileSetupViewController () {
    int industry_pickerRow;
}

@property (nonatomic, strong) UIScrollView *mainSV;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UITextField *displayNameTF;
@property (nonatomic, strong) UITextField *locationTF;
@property (nonatomic, strong) UITextField *websiteTF;
@property (nonatomic, strong) UITextView *descriptionTV;
@property (nonatomic, strong) UIButton *industry_button;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) NSArray *industry_datasource;
@property (nonatomic, strong) UIPickerView *industry_pickerView;
@property (nonatomic, strong) UIButton *industry_chooseButton;
@property (nonatomic, strong) UITextField *emailTF;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) UITextField *twitterTF;
@property (nonatomic, strong) UITextField *angellistTF;
@property (nonatomic, strong) UITextField *linkedInTF;
@property (nonatomic, strong) UIButton *navDone;
@property (nonatomic, strong) UIScrollView* contentSV;

@property (nonatomic, strong) UIButton *imagePicker;
@property (nonatomic, strong) NSData *imageData_picker;
@property (nonatomic, strong) NSData *imageData_picker_small;
@property (nonatomic, strong) PFImageView* profilePictureImageView;
@property (nonatomic, strong) PFFile *imageProfileFile;

@property (nonatomic, strong) UILabel *wordCountLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation PAPprofileSetupViewController

- (void)viewWillAppear:(BOOL)animated{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    
    [self locationDetectButtonAction:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"New Profile Screen 1"}];
    
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"new_profile_1_screen" action:@"viewing_new_profile_1" label:@"" value:@""];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"New Profile Screen 1"];
    
    UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, [UIApplication sharedApplication].statusBarFrame.size.height)];
    [statusBarBackground setBackgroundColor:[UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
    [self.view addSubview:statusBarBackground];
    
    self.mainSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, [UIApplication sharedApplication].statusBarFrame.size.height, 320.0f, [UIScreen mainScreen].bounds.size.height)];
    self.mainSV.contentSize = CGSizeMake(960.0f, [UIScreen mainScreen].bounds.size.height);
    self.mainSV.scrollEnabled = NO;
    self.mainSV.delegate = self;
    [self.view addSubview:self.mainSV];
    
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 960.0f, 60.0f)];
    navBar.backgroundColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    [self.mainSV addSubview:navBar];
    
    UIView *backgroudView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 60.0f, self.mainSV.contentSize.width, self.mainSV.bounds.size.height - 216.0f - navBar.bounds.size.height)];
    [backgroudView setBackgroundColor:[UIColor whiteColor]];
    [self.mainSV addSubview:backgroudView];
    
    self.contentSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, navBar.bounds.size.height, 960.0f, [UIScreen mainScreen].bounds.size.height - navBar.bounds.size.height - 216.0f)];
    self.contentSV.contentSize = CGSizeMake(960.0f, 290.0f);
    self.contentSV.delegate = self;
    [self.mainSV addSubview:self.contentSV];
    

    // Nav Labels.
    UILabel *profileSetupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, navBar.bounds.size.height)];
    [profileSetupLabel setText:@"Profile Setup"];
    profileSetupLabel.textAlignment = NSTextAlignmentCenter;
    profileSetupLabel.textColor = [UIColor whiteColor];
    profileSetupLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    [navBar addSubview:profileSetupLabel];
    
    UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f, 0.0f, 320.0f, navBar.bounds.size.height)];
    [aboutLabel setText:@"About"];
    aboutLabel.textAlignment = NSTextAlignmentCenter;
    aboutLabel.textColor = [UIColor whiteColor];
    aboutLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    [navBar addSubview:aboutLabel];
    
    UILabel *linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(640.0f, 0.0f, 320.0f, navBar.bounds.size.height)];
    [linkLabel setText:@"Links"];
    linkLabel.textAlignment = NSTextAlignmentCenter;
    linkLabel.textColor = [UIColor whiteColor];
    linkLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    [navBar addSubview:linkLabel];
    
    UIPageControl *pageControl_bar = [[UIPageControl alloc] initWithFrame:CGRectMake(160.0f - 25.0f, 60.0f, 50.0f, 20.0f)];
    [pageControl_bar setPageIndicatorTintColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
    [pageControl_bar setCurrentPageIndicatorTintColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
    [self setPageControl:pageControl_bar];
    [self.pageControl setNumberOfPages:3];
    [self.view addSubview:pageControl_bar];
    
    UIButton *navNext_1 = [[UIButton alloc] initWithFrame:CGRectMake(310.0f - 50.0f, 30.0f - 10.0f, 50.0f, 20.0f)];
    [navNext_1 setTitle:@"Next" forState:UIControlStateNormal];
    [navNext_1.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [navNext_1 addTarget:self action:@selector(navNext_1Action:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navNext_1];
    
    UIButton *navNext_2 = [[UIButton alloc] initWithFrame:CGRectMake(630.0f - 50.0f, 30.0f - 10.0f, 50.0f, 20.0f)];
    [navNext_2 setTitle:@"Next" forState:UIControlStateNormal];
    [navNext_2.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [navNext_2 addTarget:self action:@selector(navNext_2Action:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navNext_2];
    
    UIButton *navBack_2 = [[UIButton alloc] initWithFrame:CGRectMake(330.0f, 30.0f - 10.0f, 50.0f, 20.0f)];
    [navBack_2 setTitle:@"Back" forState:UIControlStateNormal];
    [navBack_2.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [navBack_2 addTarget:self action:@selector(navBack_2Action:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navBack_2];
    
    UIButton *navBack_3 = [[UIButton alloc] initWithFrame:CGRectMake(650.0f, 30.0f - 10.0f, 50.0f, 20.0f)];
    [navBack_3 setTitle:@"Back" forState:UIControlStateNormal];
    [navBack_3.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [navBack_3 addTarget:self action:@selector(navBack_3Action:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navBack_3];
    
    UIImage *navDoneImage = [UIImage imageNamed:@"button_done.png"];
    self.navDone = [[UIButton alloc] initWithFrame:CGRectMake(960.0f - 10.0f - navDoneImage.size.width, 30.0f - navDoneImage.size.width / 2, navDoneImage.size.width,  navDoneImage.size.height)];
    [self.navDone setImage:navDoneImage forState:UIControlStateNormal];
    [self.navDone addTarget:self action:@selector(navDonAction:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:self.navDone];

    
    UIImage *middleImageViewImage_1 = [UIImage imageNamed:@"profile_header_1.png"];
    UIImageView *middleImageView_1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, middleImageViewImage_1.size.width, middleImageViewImage_1.size.height)];
    middleImageView_1.image = middleImageViewImage_1;
    middleImageView_1.userInteractionEnabled = YES;
    [self.contentSV addSubview:middleImageView_1];
    
    UIImage *middleImageViewImage_2 = [UIImage imageNamed:@"profile_header_2.png"];
    UIImageView *middleImageView_2 = [[UIImageView alloc] initWithFrame:CGRectMake(320.0f, 0.0f, middleImageViewImage_2.size.width, middleImageViewImage_2.size.height)];
    middleImageView_2.image = middleImageViewImage_2;
    [self.contentSV addSubview:middleImageView_2];
    
    UIImage *middleImageVIewImage_3 = [UIImage imageNamed:@"profile_header_3.png"];
    UIImageView *middleImageView_3 = [[UIImageView alloc] initWithFrame:CGRectMake(640.0f, 0.0f, middleImageVIewImage_3.size.width, middleImageVIewImage_3.size.height)];
    middleImageView_3.image = middleImageVIewImage_3;
    middleImageView_3.userInteractionEnabled = YES;
    [self.contentSV addSubview:middleImageView_3];
    
    UILabel *middleImageViewText_2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 105.0f)];
    [middleImageViewText_2 setText:@"What's your startup about?"];
    middleImageViewText_2.textColor = [UIColor whiteColor];
    middleImageViewText_2.textAlignment = NSTextAlignmentCenter;
    [middleImageView_2 addSubview:middleImageViewText_2];
    
    UILabel *middleImageViewText_3 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 105.0f)];
    [middleImageViewText_3 setText:@"Add your social links"];
    middleImageViewText_3.textAlignment = NSTextAlignmentCenter;
    middleImageViewText_3.textColor = [UIColor whiteColor];
    [middleImageView_3 addSubview:middleImageViewText_3];
    
    UIButton *skipForNow = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 60.0f, middleImageView_3.bounds.size.width, 30.0f)];
    [skipForNow setTitle:@"Skip for now" forState:UIControlStateNormal];
    [skipForNow setTitleColor:[UIColor colorWithRed:41.0f/255.0f green:160.0f/255.0f blue:240.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    skipForNow.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    [skipForNow addTarget:self action:@selector(navDonAction:) forControlEvents:UIControlEventTouchUpInside];
    [middleImageView_3 addSubview:skipForNow];
    
    
    UIImage *imagePickerImage = [UIImage imageNamed:@"btn_image_upload.png"];
    
    self.imagePicker = [[UIButton alloc] initWithFrame:CGRectMake(160.0f - imagePickerImage.size.width / 2, middleImageView_1.bounds.size.height / 2 - imagePickerImage.size.height / 2, imagePickerImage.size.width, imagePickerImage.size.height)];
    [self.imagePicker setImage:imagePickerImage forState:UIControlStateNormal];
    [self.imagePicker addTarget:self action:@selector(imagePickerAction:) forControlEvents:UIControlEventTouchUpInside];
    [middleImageView_1 addSubview:self.imagePicker];
    
    
    // Textfields in first page
    self.displayNameTF = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, middleImageView_1.bounds.size.height, 300.0f, 55.0f)];
    self.displayNameTF.placeholder = @"Startup Name or Individual Name";
    self.displayNameTF.delegate = self;
    self.displayNameTF.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.displayNameTF becomeFirstResponder];
    [self.contentSV addSubview:self.displayNameTF];
    
    UIColor *lineColor = [UIColor colorWithWhite:0.9f alpha:0.7f];
    
    UIView *line_1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height, self.mainSV.contentSize.width, 1.0f)];
    [line_1 setBackgroundColor:lineColor];
    [self.contentSV addSubview:line_1];
    
    self.locationTF = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height, 300.0f, 55.0f)];
    self.locationTF.placeholder = @"Location";
    self.locationTF.autocorrectionType = UITextAutocorrectionTypeNo;
    //locationTF.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0f];
    [self.contentSV addSubview:self.locationTF];
    
    UIView *line_2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height + self.locationTF.bounds.size.height, self.mainSV.contentSize.width, 1.0f)];
    [line_2 setBackgroundColor:lineColor];
    [self.contentSV addSubview:line_2];
    
    self.user = [PFUser currentUser];
    self.userEmail = [self.user objectForKey:@"email"];
    
    self.emailTF = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height + self.locationTF.bounds.size.height, 300.0f, 55.0f)];
    self.emailTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if ([self.userEmail length] == 0) {
        self.emailTF.placeholder = @"Email";
        self.emailTF.userInteractionEnabled = YES;
    } else {
        self.emailTF.text = self.userEmail;
        self.emailTF.userInteractionEnabled = NO;
    }
    //websiteTF.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1.0f];
    [self.contentSV addSubview:self.emailTF];
    
    UIImage *locationDetectionButtionImage = [UIImage imageNamed:@"btn_auto_detect.png"];
    UIButton *locationDetectButton = [[UIButton alloc] initWithFrame:CGRectMake(320.0f - locationDetectionButtionImage.size.width, self.locationTF.frame.origin.y, locationDetectionButtionImage.size.width, 55.0f)];
    [locationDetectButton setImage:locationDetectionButtionImage forState:UIControlStateNormal];
    [locationDetectButton addTarget:self action:@selector(locationDetectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentSV addSubview:locationDetectButton];
    
    self.descriptionTV = [[UITextView alloc] initWithFrame:CGRectMake(320.0f, middleImageView_2.bounds.size.height, 320.0f, 55.0f)];
    self.descriptionTV.autocorrectionType = UITextAutocorrectionTypeNo;
    self.descriptionTV.delegate = self;
    //self.descriptionTV.contentInset = UIEdgeInsetsMake(10.0f, 10.0f, 0.0f, 0.0f);
    self.descriptionTV.contentInset = UIEdgeInsetsMake(10.0f, 5.0f, 0.0f, -5.0f);
    self.descriptionTV.text = @"Bio";
    self.descriptionTV.textColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    self.descriptionTV.font = [UIFont systemFontOfSize:17.0f];
    [self.contentSV addSubview:self.descriptionTV];
    
    self.wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f + 320.0f - 50.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height - 25.0f, 50.0f, 30.0f)];
    self.wordCountLabel.text = @"0/150";
    self.wordCountLabel.textAlignment = NSTextAlignmentCenter;
    self.wordCountLabel.font = [UIFont systemFontOfSize:10.0f];
    self.wordCountLabel.textColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    [self.contentSV addSubview:self.wordCountLabel];
    
    self.industry_datasource = [NSArray arrayWithObjects:@"Information Technology", @"Consumers", @"Enterprises", @"Media", @"Education", @"Health Care", @"Finance", @"Sales and Marketing", @"Fashion", @"Health and Wellness", @"Retail", @"Sports", @"UI/UX Design", @"Travel", @"Web Development", @"Real Estate", @"Recruiting", @"Entertainment", @"Clean Technology", @"Events", @"B2B", @"Restaurants", @"Lifestyle", @"Big Data Analytics", @"Music Services", @"Event Management", @"Non Profits", @"Discovery", @"Incubators", @"Other", nil];
    
    self.industry_button = [[UIButton alloc] initWithFrame:CGRectMake(330.0f, middleImageView_2.bounds.size.height + self.descriptionTV.bounds.size.height, 300.0f, 55.0f)];
    [self.industry_button setTitle:@"Industry / Market" forState:UIControlStateNormal];
    [self.industry_button setBackgroundColor:[UIColor clearColor]];
    //         [self.industry_button.titleLabel setTextColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
    [self.industry_button setTitleColor:[UIColor colorWithWhite:0.8f alpha:1.0f] forState:UIControlStateNormal];
    [self.industry_button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.industry_button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0]];
    [self.industry_button addTarget:self action:@selector(industry_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentSV addSubview:self.industry_button];
    
    UIImage *industry_buttonDropDownImage = [UIImage imageNamed:@"btn_dropdown.png"];
    UIImageView *industry_buttonDropDown = [[UIImageView alloc] initWithFrame:CGRectMake(self.industry_button.bounds.size.width - 5.0f - industry_buttonDropDownImage.size.width, self.industry_button.bounds.size.height / 2 - industry_buttonDropDownImage.size.height / 2, industry_buttonDropDownImage.size.width, industry_buttonDropDownImage.size.height)];
    [industry_buttonDropDown setImage:industry_buttonDropDownImage];
    [self.industry_button addSubview:industry_buttonDropDown];
    
    self.websiteTF = [[UITextField alloc] initWithFrame:CGRectMake(330.0f, middleImageView_2.bounds.size.height + self.descriptionTV.bounds.size.height + self.industry_button.bounds.size.height, 300.0f, 55.0f)];
    self.websiteTF.placeholder = @"Website";
    self.websiteTF.delegate = self;
    //websiteTF.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1.0f];
    [self.contentSV addSubview:self.websiteTF];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissIndustryPicker)];
    
    self.dimView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, [UIScreen mainScreen].bounds.size.height)];
    self.dimView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];
    self.dimView.hidden = YES;
    [self.dimView addGestureRecognizer:tapOutside];
    [self.view addSubview:self.dimView];
    
    
    // third screen
    
    self.twitterTF = [[UITextField alloc] initWithFrame:CGRectMake(650.0f, middleImageView_3.bounds.size.height, 300.0f, 55.0f)];
    self.twitterTF.delegate = self;
    self.twitterTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.twitterTF.placeholder = @"Twitter";
    [self.contentSV addSubview:self.twitterTF];
    
    self.angellistTF = [[UITextField alloc] initWithFrame:CGRectMake(650.0f, middleImageView_3.bounds.size.height + self.twitterTF.bounds.size.height, 300.0f, 55.0f)];
    self.angellistTF.delegate = self;
    self.angellistTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.angellistTF.placeholder = @"AngelList";
    [self.contentSV addSubview:self.angellistTF];
    
    self.linkedInTF = [[UITextField alloc] initWithFrame:CGRectMake(650.0f, middleImageView_3.bounds.size.height + self.twitterTF.bounds.size.height + self.angellistTF.bounds.size.height, 300.0f, 55.0f)];
    self.linkedInTF.delegate = self;
    self.linkedInTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.linkedInTF.placeholder = @"LinkedIn";
    [self.contentSV addSubview:self.linkedInTF];

}

# pragma - ()
-(void)hideSVProgressHUDWithDelay {
    [SVProgressHUD dismiss];
}

-(void)hideSVProgressHUDWithDelayCreateProfile {
    [SVProgressHUD dismiss];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Profile Created!" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = SUCCESSFUL;
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
    
}
-(void)navNext_1Action:(id)sender {
    [self.locationTF becomeFirstResponder];
    
    if ([self.displayNameTF.text length] > 0 && [self.locationTF.text length] > 0 && (([self.emailTF.text length] > 0 && [self NSStringIsValidEmail:self.emailTF.text]) || [self.userEmail length] > 0)) {
        if ([self.displayNameTF.text length] > 0 && [(AppDelegate*)[[UIApplication sharedApplication] delegate] isParseReachable]) {
            [SVProgressHUD showWithStatus:@"Validating User Name" maskType:SVProgressHUDMaskTypeBlack];
            
            self.displayNameTF.enabled = NO;
            PFQuery *query = [PFUser query];
            [query whereKey:@"displayName" equalTo:self.displayNameTF.text];
            [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                
                [self performSelector:@selector(hideSVProgressHUDWithDelay) withObject:nil afterDelay:1.5];
                
                self.displayNameTF.enabled = YES;
                
                if (!error) {
                    if ((number > 0 || [self.displayNameTF.text length] == 0) && (![[[PFUser currentUser] objectForKey:@"displayName"] isEqualToString:self.displayNameTF.text])) {
                        self.dimView.hidden = YES;
                        [self.view endEditing:YES];
                        self.displayNameTF.text = @"";
                        [self.displayNameTF becomeFirstResponder];
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Display name is already in use. Please choose another name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        alert.alertViewStyle = UIAlertViewStyleDefault;
                        [alert show];
                    } else {
                        if (([self.userEmail length] == 0) && [(AppDelegate*)[[UIApplication sharedApplication] delegate] isParseReachable]) {
                            [SVProgressHUD showWithStatus:@"Validating Email" maskType:SVProgressHUDMaskTypeBlack];
                            
                            PFQuery *userQuery = [PFUser query];
                            [userQuery whereKey:@"email" equalTo :self.emailTF.text];
                            [userQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                                [self performSelector:@selector(hideSVProgressHUDWithDelay) withObject:nil afterDelay:1.5];
                                
                                if (!error) {
                                    if (number > 0) {
                                        self.emailTF.text = @"";
                                        [self.emailTF becomeFirstResponder];
                                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The email address is already in use. Please use another email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        alert.alertViewStyle = UIAlertViewStyleDefault;
                                        [alert show];
                                    } else {
                                        [self.mainSV setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
                                        
                                        if ([UIScreen mainScreen].bounds.size.height == 480)
                                        [self.contentSV setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
                                    }
                                } else {
                                    NSLog(@"%@", error);
                                }
                            }];
                        } else {
                            
                            // mixpanel analytics
                            [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"New Profile Screen 2"}];
                            
                            // flightrecorder event analytics
                            [[FlightRecorder sharedInstance] trackEventWithCategory:@"new_profile_2_screen" action:@"viewing_new_profile_2" label:@"" value:@""];
                            
                            // flightrecorder analytics
                            [[FlightRecorder sharedInstance] trackPageView:@"New Profile Screen 2"];
                            
                            [self.mainSV setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
                            if ([UIScreen mainScreen].bounds.size.height == 480)
                                [self.contentSV setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
                        }
                    }
                } else {
                    NSLog(@"%@", error);
                }
                
                
            }];
        }
        
        
    } else {
        NSString *replacementString;

        if ([self.displayNameTF.text length] == 0) {
            replacementString = @"Please enter Display Name";
        } else if ([self.locationTF.text length] == 0) {
            replacementString = @"Please enter Location";
        } else if ([self.emailTF.text length] == 0){
            replacementString = @"Please enter Email";
        } else {
            replacementString = @"Invalid Email Address";
        }
            
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:replacementString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }

}

-(void)navNext_2Action:(id)sender {
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"New Profile Screen 3"}];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"New Profile Screen 3"];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"new_profile_3_screen" action:@"viewing_new_profile_3" label:@"" value:@""];
    
    [self.mainSV setContentOffset:CGPointMake(640.0f, 0.0f) animated:YES];
    
    if ([UIScreen mainScreen].bounds.size.height == 480)
        [self.contentSV setContentOffset:CGPointMake(640.0f, 0.0f) animated:YES];
    
}

-(void)navBack_2Action:(id)sender {
    [self.mainSV setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    
    if ([UIScreen mainScreen].bounds.size.height == 480)
        [self.contentSV setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

-(void)navBack_3Action:(id)sender {
    [self.mainSV setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
    
    if ([UIScreen mainScreen].bounds.size.height == 480)
        [self.contentSV setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(void)dismissIndustryPicker {
    self.dimView.hidden = YES;
    [self.industry_pickerView removeFromSuperview];
    [self.industry_chooseButton removeFromSuperview];
    [self.descriptionTV becomeFirstResponder];
    
}

-(void)navDonAction:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Creating Profile..." maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* companyName_input = self.displayNameTF.text;
    NSString* location_input = self.locationTF.text;
    NSString* description_input = self.descriptionTV.text;
    NSString* website_input = [self.websiteTF.text lowercaseString];
    NSString* twitter_input = self.twitterTF.text;
    NSString* industry_input = self.industry_button.titleLabel.text;
    NSString* linkedin_input = self.linkedInTF.text;
    NSString* angellist_input = self.angellistTF.text;
    NSString* email_input = self.emailTF.text;
    NSString* email_current_input = self.user[@"email"];
    
    [[Mixpanel sharedInstance] track:@"Pressed Done In Profile Screen" properties:@{@"New user email":email_input}];
    
    self.user[@"username"] = email_input;
    
    self.navDone.userInteractionEnabled = NO;
    
    if ([companyName_input length] > 0 && [location_input length] > 0 && (([email_input length] > 0 && [self NSStringIsValidEmail:email_input]) || email_current_input )) {
        
            UIImage *image = [UIImage imageNamed:@"default-pic.png"];
        
            UIImage *smallRoundedImage = [PAPUtility resizeImage:image width:84.0f height:84.0f];
            UIImage *resizedImage = [PAPUtility resizeImage:image width:200.0f height:200.0f];

            if (self.imageData_picker) {
                [self uploadImage_medium:self.imageData_picker];
            } else {
                self.imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
                [self uploadImage_medium:self.imageData_picker];
            }
            if (self.imageData_picker_small) {
                [self uploadImage_small:self.imageData_picker_small];
            } else {
                self.imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
                [self uploadImage_small:self.imageData_picker_small];
            }
        
            if ([companyName_input length] > 0) {
                self.user[@"displayName"] = companyName_input;
            }
            if ([location_input length] > 0) {
                self.user[@"location"] = location_input;
            }
            if ([description_input length] > 0 && ![description_input isEqualToString:@"Bio"]) {
                self.user[@"description"] = description_input;
            }
            if ([website_input length] > 0 && ![website_input isEqualToString:@"http://"]) {
                self.user[@"website"] = website_input;
            }
            if ([industry_input length] > 0 && ![industry_input isEqualToString:@"Industry / Market"]) {
                self.user[@"industry"] = industry_input;
            }
            if ([twitter_input length] > 0 && ![twitter_input isEqualToString:@"https://twitter.com/"]) {
                self.user[@"twitter_url"] = twitter_input;
            }
            if ([linkedin_input length] > 0 && ![linkedin_input isEqualToString:@"https://www.linkedin.com/in/"]) {
                self.user[@"linkedin_url"] = linkedin_input;
            }
            if ([angellist_input length] > 0 && ![angellist_input isEqualToString:@"https://angel.co/"]) {
                self.user[@"angellist_url"] = angellist_input;
            }
            if ([email_current_input length] == 0) {
                self.user[@"email"] = email_input;
            }
        
        bool profileExist = YES;
        NSNumber *profileExist_num = [NSNumber numberWithBool: profileExist ];
        [self.user setObject: profileExist_num forKey: @"profileExist"];
        
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self performSelector:@selector(hideSVProgressHUDWithDelayCreateProfile) withObject:nil afterDelay:1.5];
                if(succeeded){
                }else{
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your Information could not be saved. Please try again or Reach us at info@teamstoryapp.com" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                    self.navDone.userInteractionEnabled = YES;
                }
            }];

    }

}

-(void)locationDetectButtonAction:(id)sender{
    
    if(IS_WIDESCREEN){
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 16.0f)];
    }else{
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 76.0f)];
    }
    
    [SVProgressHUD show];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.locationManager.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                       [SVProgressHUD dismiss];
                       [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 0)];
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Autodetect location failed, please enter manually." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                           alert.alertViewStyle = UIAlertViewStyleDefault;
                           [alert show];
                           return;
                       }
                       
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       
                       NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                       NSLog(@"placemark.country %@",placemark.country);
                       NSLog(@"placemark.postalCode %@",placemark.postalCode);
                       NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                       NSLog(@"placemark.locality %@",placemark.locality);
                       NSLog(@"placemark.subLocality %@",placemark.subLocality);
                       NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                       
                       self.locationTF.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                       
                   }];
}


-(void)industry_buttonAction:(id)sender {
    [self.view endEditing:YES];
    self.dimView.hidden = NO;
    
    self.industry_pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 270.0f, 320.0f, 0.0f)];
    self.industry_pickerView.delegate = self;
    self.industry_pickerView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.95f];
    self.industry_pickerView.showsSelectionIndicator = YES;
    [self.view addSubview:self.industry_pickerView];
    
    self.industry_chooseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 54.0f, 320.0f, 54.0f)];
    [self.industry_chooseButton setBackgroundColor:[UIColor colorWithRed:91.0f/255.0f green:194.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
    [self.industry_chooseButton setTitle:@"Choose" forState:UIControlStateNormal];
    [self.industry_chooseButton addTarget:self action:@selector(industry_chooseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.industry_chooseButton];
    
}


- (void) industry_chooseButtonAction:(id)sender {
    self.dimView.hidden = YES;
    [self.industry_pickerView removeFromSuperview];
    [self.industry_chooseButton removeFromSuperview];
    
    [self.industry_button setTitle:[self.industry_datasource objectAtIndex:industry_pickerRow] forState:UIControlStateNormal];
    [self.industry_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.descriptionTV becomeFirstResponder];
}

-(void)imagePickerAction:(id)sender {
    [self photo_picker_init];
}

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

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    cameraUI.navigationBar.tintColor = [UIColor clearColor];
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.locationTF becomeFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.profilePictureImageView removeFromSuperview];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *smallRoundedImage = [PAPUtility resizeImage:image width:84.0f height:84.0f];
    UIImage *resizedImage = [PAPUtility resizeImage:image width:200.0f height:200.0f];

    // Upload image
    self.imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
    self.imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
    
    [self.imagePicker setImage:image forState:UIControlStateNormal];
    self.imagePicker.layer.cornerRadius = self.imagePicker.frame.size.width / 2;
    self.imagePicker.clipsToBounds = YES;
    [self.locationTF becomeFirstResponder];
}

-(void)uploadImage_small:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
    self.user = [PFUser currentUser];
    self.user[@"profilePictureSmall"] = imageFile;
    
    [self.user saveInBackground];
}

-(void)uploadImage_medium:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
    self.user = [PFUser currentUser];
    self.user[@"profilePictureMedium"] = imageFile;
    
    [self.user saveInBackground];
}


# pragma - UITextViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.mainSV) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        [self.pageControl setCurrentPage:page];
    }
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        if (scrollView == self.contentSV) {
            if (scrollView.contentOffset.x != 0) {
                CGPoint offset = scrollView.contentOffset;
                offset.x = 0;
                scrollView.contentOffset = offset;
            }
        }
    } else {
        
    }
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Bio"]) {
        textView.text = @"";
        self.descriptionTV.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    int textLength = (int)[textView.text length];
    self.wordCountLabel.text = [NSString stringWithFormat:@"%i/150", textLength];
    
    if (textLength >= 150) {
        self.descriptionTV.text = [self.descriptionTV.text substringToIndex:149];
    }
}

# pragma - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.twitterTF && [textField.text length] == 0) {
        self.twitterTF.text = @"https://twitter.com/";
    } else if (textField == self.linkedInTF && [textField.text length] == 0) {
        self.linkedInTF.text = @"https://www.linkedin.com/in/";
    } else if (textField == self.angellistTF && [textField.text length] == 0) {
        self.angellistTF.text = @"https://angel.co/";
    } else if (textField == self.websiteTF && [textField.text length] == 0) {
        self.websiteTF.text = @"http://";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.twitterTF && [textField.text isEqualToString:@"https://twitter.com/"]) {
        self.twitterTF.text = nil;
    } else if (textField == self.linkedInTF && [textField.text isEqualToString:@"https://www.linkedin.com/in/"]) {
        self.linkedInTF.text = nil;
    } else if (textField == self.angellistTF && [textField.text isEqualToString:@"https://angel.co/"]) {
        self.angellistTF.text = nil;
    } else if (textField == self.websiteTF && [textField.text isEqualToString:@"http://"]) {
        self.websiteTF.text = nil;
    }
    
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
    return [self.industry_datasource objectAtIndex:row];
}

# pragma - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SUCCESSFUL) {
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Signed Up" properties:@{}];
        
        // intercom analytics
        [Intercom logEventWithName:@"signed-up" optionalMetaData:nil
                        completion:^(NSError *error) {}];

        
        NSLog(@"login Sucessful");
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
    }
}

@end
