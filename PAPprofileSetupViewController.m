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

@property (nonatomic, strong) UILabel *wordCountLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation PAPprofileSetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    
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
    
    // Nav Labels.
    UILabel *profileSetupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, navBar.bounds.size.height)];
    [profileSetupLabel setText:@"Profile Setup"];
    profileSetupLabel.textAlignment = NSTextAlignmentCenter;
    profileSetupLabel.textColor = [UIColor whiteColor];
    [navBar addSubview:profileSetupLabel];
    
    UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f, 0.0f, 320.0f, navBar.bounds.size.height)];
    [aboutLabel setText:@"About"];
    aboutLabel.textAlignment = NSTextAlignmentCenter;
    aboutLabel.textColor = [UIColor whiteColor];
    [navBar addSubview:aboutLabel];
    
    UILabel *linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(640.0f, 0.0f, 320.0f, navBar.bounds.size.height)];
    [linkLabel setText:@"Links"];
    linkLabel.textAlignment = NSTextAlignmentCenter;
    linkLabel.textColor = [UIColor whiteColor];
    [navBar addSubview:linkLabel];
    
    UIPageControl *pageControl_bar = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 60.0f, 320.0f, 20.0f)];
    [self setPageControl:pageControl_bar];
    [pageControl_bar setPageIndicatorTintColor:[UIColor colorWithRed:79.0f/255.0f green:91.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
    [pageControl_bar setCurrentPageIndicatorTintColor:[UIColor colorWithRed:205.0f/255.0f green:208.0f/255.0f blue:210.0f/255.0f alpha:1.0f]];
    [self.pageControl setNumberOfPages:3];
    [self.view addSubview:pageControl_bar];
    
    UIImage *buttonCancelImage = [UIImage imageNamed:@"button_cancel.png"];
    UIButton *navExit = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 30.0f - buttonCancelImage.size.width / 2, buttonCancelImage.size.width, buttonCancelImage.size.height)];
    [navExit setImage:buttonCancelImage forState:UIControlStateNormal];
    [navExit addTarget:self action:@selector(navExitAction:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navExit];
    
    UIImage *navNextImage = [UIImage imageNamed:@"arrow_right_white.png"];
    UIButton *navNext_1 = [[UIButton alloc] initWithFrame:CGRectMake(310.0f - navNextImage.size.width, 30.0f - navNextImage.size.width / 2, navNextImage.size.width, navNextImage.size.height)];
    [navNext_1 setImage:navNextImage forState:UIControlStateNormal];
    [navNext_1 addTarget:self action:@selector(navNext_1Action:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navNext_1];
    
    UIButton *navNext_2 = [[UIButton alloc] initWithFrame:CGRectMake(630.0f - navNextImage.size.width, 30.0f - navNextImage.size.width / 2, navNextImage.size.width, navNextImage.size.height)];
    [navNext_2 setImage:navNextImage forState:UIControlStateNormal];
    [navNext_2 addTarget:self action:@selector(navNext_2Action:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navNext_2];
    
    UIImage *navBackImage = [UIImage imageNamed:@"arrow_left_white.png"];
    UIButton *navBack_2 = [[UIButton alloc] initWithFrame:CGRectMake(330.0f, 30.0f - navBackImage.size.width / 2, navBackImage.size.width, navBackImage.size.height)];
    [navBack_2 setImage:navBackImage forState:UIControlStateNormal];
    [navBack_2 addTarget:self action:@selector(navBack_2Action:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navBack_2];
    
    UIButton *navBack_3 = [[UIButton alloc] initWithFrame:CGRectMake(650.0f, 30.0f - navBackImage.size.width / 2, navBackImage.size.width, navBackImage.size.height)];
    [navBack_3 setImage:navBackImage forState:UIControlStateNormal];
    [navBack_3 addTarget:self action:@selector(navBack_3Action:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:navBack_3];

    
    UIView *middleImageView_1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, navBar.bounds.size.height, 320.0f, 105.0f)];
    middleImageView_1.backgroundColor = [UIColor greenColor];
    [self.mainSV addSubview:middleImageView_1];
    
    UIView *middleImageView_2 = [[UIView alloc] initWithFrame:CGRectMake(320.0f, navBar.bounds.size.height, 320.0f, 105.0f)];
    middleImageView_2.backgroundColor = [UIColor redColor];
    [self.mainSV addSubview:middleImageView_2];
    
    UIView *middleImageView_3 = [[UIView alloc] initWithFrame:CGRectMake(640.0f, navBar.bounds.size.height, 320.0f, 105.0f)];
    middleImageView_3.backgroundColor = [UIColor blueColor];
    [self.mainSV addSubview:middleImageView_3];
    
    UILabel *middleImageViewText_2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 105.0f)];
    [middleImageViewText_2 setText:@"What's your startup about?"];
    middleImageViewText_2.textAlignment = NSTextAlignmentCenter;
    [middleImageView_2 addSubview:middleImageViewText_2];
    
    UILabel *middleImageViewText_3 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 105.0f)];
    [middleImageViewText_3 setText:@"Add your social links"];
    middleImageViewText_3.textAlignment = NSTextAlignmentCenter;
    [middleImageView_3 addSubview:middleImageViewText_3];
    
    
    // Textfields in first page
    self.displayNameTF = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, middleImageView_1.bounds.size.height + navBar.bounds.size.height, 300.0f, 55.0f)];
    self.displayNameTF.placeholder = @"Startup Name or Individual Name";
    //displayNameTF.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0f];
    [self.displayNameTF becomeFirstResponder];
    [self.mainSV addSubview:self.displayNameTF];
    
    UIColor *lineColor = [UIColor colorWithWhite:0.9f alpha:0.7f];
    
    UIView *line_1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height + navBar.bounds.size.height, self.mainSV.contentSize.width, 1.0f)];
    [line_1 setBackgroundColor:lineColor];
    [self.mainSV addSubview:line_1];
    
    self.locationTF = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height + navBar.bounds.size.height, 300.0f, 55.0f)];
    self.locationTF.placeholder = @"Location";
    //locationTF.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0f];
    [self.mainSV addSubview:self.locationTF];
    
    UIView *line_2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height + self.locationTF.bounds.size.height + navBar.bounds.size.height, self.mainSV.contentSize.width, 1.0f)];
    [line_2 setBackgroundColor:lineColor];
    [self.mainSV addSubview:line_2];
    
    self.websiteTF = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height + self.locationTF.bounds.size.height + navBar.bounds.size.height, 300.0f, 55.0f)];
    self.websiteTF.placeholder = @"Website";
    //websiteTF.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1.0f];
    [self.mainSV addSubview:self.websiteTF];
    
    UIButton *locationDetectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.locationTF.bounds.size.width - 60.0f, 0.0f, 50.0f, self.locationTF.bounds.size.height)];
    [locationDetectButton setBackgroundColor:[UIColor redColor]];
    [locationDetectButton addTarget:self action:@selector(locationDetectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.locationTF addSubview:locationDetectButton];
    
    self.descriptionTV = [[UITextView alloc] initWithFrame:CGRectMake(320.0f, middleImageView_2.bounds.size.height + navBar.bounds.size.height, 320.0f, 110.0f)];
    self.descriptionTV.delegate = self;
    self.descriptionTV.contentInset = UIEdgeInsetsMake(10.0f, 10.0f, 0.0f, 0.0f);
    self.descriptionTV.text = @"Bio";
    self.descriptionTV.textColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    self.descriptionTV.font = [UIFont systemFontOfSize:17.0f];
    [self.mainSV addSubview:self.descriptionTV];
    
    self.wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f + 320.0f - 60.0f, middleImageView_1.bounds.size.height + self.displayNameTF.bounds.size.height + self.locationTF.bounds.size.height + navBar.bounds.size.height - 30.0f, 50.0f, 30.0f)];
    self.wordCountLabel.text = @"0/150";
    self.wordCountLabel.textAlignment = NSTextAlignmentCenter;
    self.wordCountLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.mainSV addSubview:self.wordCountLabel];
    
    self.dimView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, [UIScreen mainScreen].bounds.size.height)];
    self.dimView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];
    self.dimView.hidden = YES;
    [self.view addSubview:self.dimView];
    
    
    self.industry_datasource = [NSArray arrayWithObjects:@"Information Technology", @"Consumers", @"Enterprises", @"Media", @"Education", @"Health Care", @"Finance", @"Sales and Marketing", @"Fashion", @"Health and Wellness", @"Retail", @"Sports", @"UI/UX Design", @"Travel", @"Web Development", @"Real Estate", @"Recruiting", @"Entertainment", @"Clean Technology", @"Events", @"B2B", @"Restaurants", @"Lifestyle", @"Big Data Analytics", @"Music Services", @"Event Management", @"Non Profits", @"Discovery", @"Incubators", @"Other", nil];
    
    self.industry_button = [[UIButton alloc] initWithFrame:CGRectMake(330.0f, middleImageView_2.bounds.size.height + navBar.bounds.size.height + self.descriptionTV.bounds.size.height, 300.0f, 55.0f)];
    [self.industry_button setTitle:@"Industry / Market" forState:UIControlStateNormal];
    [self.industry_button setBackgroundColor:[UIColor clearColor]];
    //         [self.industry_button.titleLabel setTextColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
    [self.industry_button setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
    [self.industry_button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.industry_button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0]];
    [self.industry_button addTarget:self action:@selector(industry_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainSV addSubview:self.industry_button];
    

}

# pragma - ()
-(void)navExitAction:(id)sender {
}

-(void)navNext_1Action:(id)sender {
    [self.mainSV setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
}

-(void)navNext_2Action:(id)sender {
    [self.mainSV setContentOffset:CGPointMake(640.0f, 0.0f) animated:YES];
    
}

-(void)navBack_2Action:(id)sender {
    [self.mainSV setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

-(void)navBack_3Action:(id)sender {
    [self.mainSV setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
}

-(void)locationDetectButtonAction:(id)sender{
    [SVProgressHUD show];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.locationManager.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                       [SVProgressHUD dismiss];
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
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
                       
                       self.locationTF.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.country];
                       
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


# pragma - UITextViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[self.pageControl setCurrentPage:page];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Bio"]) {
        textView.text = @"";
        self.descriptionTV.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    int textLength = [textView.text length];
    self.wordCountLabel.text = [NSString stringWithFormat:@"%i/150", textLength];
    
    if (textLength >= 150) {
        self.descriptionTV.text = [self.descriptionTV.text substringToIndex:149];
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


@end
