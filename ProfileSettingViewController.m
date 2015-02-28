//
//  ProfileSettingViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-02-15.
//
//

#import "ProfileSettingViewController.h"

#define WEBSITE_TAG_NUM 6
#define TWITTER_TAG_NUM 7
#define LINKEDIN_TAG_NUM 8
#define ANGELIST_TAG_NUM 9

@interface ProfileSettingViewController ()

@property (nonatomic, strong) PFUser *user;
@property BOOL didEditProfile;

// picker variables

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) PFFile *imageProfileFile;
@property (nonatomic, strong) NSData *imageData_picker;
@property (nonatomic, strong) NSData *imageData_picker_small;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) NSArray *industry_dataSource;
@property int industry_pickerRow;

// server data variables

@property (nonatomic, strong) NSString *email_user;
@property (nonatomic, strong) NSString *industry_user;
@property (nonatomic, strong) NSString *twitter_user;
@property (nonatomic, strong) NSString *linkedin_user;
@property (nonatomic, strong) NSString *angelist_user;
@property (nonatomic, strong) NSString *location_user;
@property (nonatomic, strong) NSString *website_user;
@property (nonatomic, strong) NSString *displayName_user;
@property (nonatomic, strong) NSString *description_user;

@end

@implementation ProfileSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // set user
        self.user = [PFUser currentUser];
        
        // set industry data
        self.industry_dataSource = [NSArray arrayWithObjects:@"Information Technology", @"Consumers", @"Enterprises", @"Media", @"Education", @"Health Care", @"Finance", @"Sales and Marketing", @"Fashion", @"Health and Wellness", @"Retail", @"Sports", @"UI/UX Design", @"Travel", @"Web Development", @"Real Estate", @"Recruiting", @"Entertainment", @"Clean Technology", @"Events", @"B2B", @"Restaurants", @"Lifestyle", @"Big Data Analytics", @"Music   Services", @"Event Management", @"Non Profits", @"Discovery", @"Incubators", @"Other", nil];
        
        // flag to check for changes
        self.didEditProfile = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set logo on nav bar
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];

    // set back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake( 0.0f, 0.0f, 22.0f, 22.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // set save button
    UIButton *navSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navSaveButton setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 22.0f)];
    [navSaveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [navSaveButton setBackgroundImage:[UIImage imageNamed:@"button_done.png"] forState:UIControlStateNormal];
    [navSaveButton setBackgroundImage:[UIImage imageNamed:@"button_done_selected.png"] forState:UIControlStateHighlighted];
    
    // set right button of nav bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navSaveButton];
    
    // placeholder image for profile
    [self.profilePictureImageView setImage:[UIImage imageNamed:@"icon-upload.png"]];
    
    UITapGestureRecognizer *tapProfileImg = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(photoCaptureButtonAction:)];
    [self.profilePictureImageView addGestureRecognizer:tapProfileImg];
    
    
    // set industry button and label
    [self.industry addTarget:self action:@selector(industry_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.industry_buttonAction addTarget:self action:@selector(industry_chooseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self refreshUserInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Edit Profile"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"edit_profile_screen" action:@"viewed_edit_profile" label:@"" value:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshUserInfo{
    
    [SVProgressHUD show];
    
    [self.user refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        if(!error){
            
            self.user = (PFUser *)object;
            
            // grab profile data from db
            self.imageProfileFile = [self.user objectForKey:@"profilePictureMedium"];
            self.location_user = self.user[@"location"];
            self.website_user = self.user[@"website"];
            self.displayName_user = self.user[@"displayName"];
            self.description_user = self.user[@"description"];
            self.email_user = self.user[@"email"];
            self.industry_user = self.user[@"industry"];
            self.twitter_user = self.user[@"twitter_url"];
            self.linkedin_user = self.user[@"linkedin_url"];
            self.angelist_user = self.user[@"angellist_url"];
            
            // keep default industry placeholder if no industry set
            NSString *industryTitle = [self.user[@"industry"] length] > 0 ? self.user[@"industry"] : self.industry.titleLabel.text;
            [self.industry setTitle:industryTitle forState:UIControlStateNormal];
         
            // set textfields with db inputs
            self.twitter_textfield.text = self.twitter_user;
            self.linkedin_textfield.text = self.linkedin_user;
            self.angellist_textfield.text = self.angelist_user;
            
            self.location.text = self.location_user;
            self.website.text = self.website_user;
            self.displayName.text = self.displayName_user;
            
            // set textview text and change text color
            if([self.user[@"description"] length] > 0 ){
                self.userDescription.text = self.user[@"description"];
                // set text color to teamstory color
                [self.userDescription setTextColor:[UIColor colorWithRed:87.0f/255.0f green:185.0f/255.0f blue:158.0f/255.0f alpha:1.0f]];
            }else{
                // set text color to light gray for placeholder
                [self.userDescription setTextColor:[UIColor lightGrayColor]];
            }
            
            self.email_address.text = self.email_user;
        
            // load picture if image present
            if (self.imageProfileFile) {
                
                // set file and load in background
                [self.profilePictureImageView setFile:self.imageProfileFile];
                [self.profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
                    if (!error) {
                        [UIView animateWithDuration:0.05f animations:^{
                            self.profilePictureImageView.alpha = 1.0f;
                        }];
                    }
                }];
            }
            
            [self.profilePictureImageView setContentMode:UIViewContentModeScaleToFill];
          
            UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(tappedOutside)];
            
            [self.view addGestureRecognizer:tapOutside];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Profile fetch failed. Check your network connection and try again" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert show];
        }
        
        [SVProgressHUD dismiss];
    }];
    
}

- (void)backButtonAction:(id)sender {
    
    // prompt to save unsaved changes
    if(self.didEditProfile){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsaved Changes" message:@"Save your changes?" delegate:self  cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
        [alert show];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)saveButtonAction:(id)sender {

    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Changed Profile"}];
    
    [SVProgressHUD show];
    
    // disable button while we save info
    self.saveButton.userInteractionEnabled = NO;

    // validate email
    BOOL isEmailValid = [self validateEmail:self.email_address.text];
  
    // validate name and wait for the callback
    [self validateDisplayName:self.displayName.text block:^(BOOL succeeded) {
       
        if(succeeded && isEmailValid){
            
            /* get current text and set server variables */
            
            self.user[@"displayName"] = self.displayName.text;
            self.user[@"email"] = self.email_address.text;
            self.user[@"location"] = self.location.text;
            
            // set to empty string if custom placeholder is present
            self.user[@"description"] = [self.userDescription.text isEqualToString:@"What's your story?"] ? @"" : self.userDescription.text;
            
            self.user[@"website"] = self.website.text;
            self.user[@"twitter_url"] = self.twitter_textfield.text;
            
            // set to empty string if custom placeholder is present
            self.user[@"industry"] = [self.industry.titleLabel.text isEqualToString:@"What's your industry?"] ? @"" : self.industry.titleLabel.text;
            
            self.user[@"angellist_url"] = self.angellist_textfield.text;
            self.user[@"linkedin_url"] = self.linkedin_textfield.text;
            
            // upload image if picker has data
            if (self.imageData_picker) {
                [self uploadImage_medium:self.imageData_picker];
                [self uploadImage_small:self.imageData_picker_small];
            }
            
            // save to server
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                [SVProgressHUD dismiss];
                
                NSString *messageTitle = succeeded ? @"Saved" : @"Error";
                NSString *messageBody = succeeded ? @"Your Information has been saved!" : @"Your Information could not be saved. Reach us at info@teamstoryapp.com";
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle message:messageBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }];
        }
        
        self.saveButton.userInteractionEnabled = YES;
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}


#pragma mark - AlertView Delegate 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if([alertView.title isEqualToString:@"Saved"]){
        
        // Notify timeline so a refresh is triggered
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPProfileSettingViewControllerUserChangedProfile object:nil userInfo:nil];
        
        // remove controller from stack
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if ([alertView.title isEqualToString:@"Unsaved Changes"]){
        
        // trigger saving method if user selects ok when going back
        if(buttonIndex == 1){
            [self saveButtonAction:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Upload Image Methods

-(void)uploadImage_small:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
    [SVProgressHUD show];
    
    self.user[@"profilePictureSmall"] = imageFile;
    [self.user saveInBackground];
    
    [SVProgressHUD dismiss];
}

-(void)uploadImage_medium:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
    [SVProgressHUD show];
    
    self.user[@"profilePictureMedium"] = imageFile;
    [self.user saveInBackground];
    
    [SVProgressHUD dismiss];
}


-(BOOL)validateEmail:(NSString *)checkString {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)validateDisplayName:(NSString *)name block:(void (^)(BOOL succeeded))completionBlock{
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"displayName" equalTo:name];

    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [SVProgressHUD dismiss];
    
        if (!error) {
            if ((number > 0 || [name length] == 0) && (![[[PFUser currentUser] objectForKey:@"displayName"] isEqualToString:name])) {
        
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Name is already in use. Please choose another." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
            }else{
                return completionBlock(YES);
            }
        } else {
            return completionBlock(NO);
        }
        
    }];
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    // flag to detect changes
    self.didEditProfile = YES;
    
    // add prepopulated url on first edit
    if([textField.text length] == 0){
        
        // get unique tag for textfield
        NSInteger tagNum = textField.tag;
        
        if(tagNum == WEBSITE_TAG_NUM){
            textField.text = @"http://";
        }else if(tagNum == TWITTER_TAG_NUM){
            textField.text = @"https://twitter.com/";
        }else if(tagNum == LINKEDIN_TAG_NUM){
            textField.text = @"https://linkedin.com/in/";
        }else if(tagNum == ANGELIST_TAG_NUM){
            textField.text = @"https://angel.co/";
        }
    }
}

#pragma mark - TextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    // flag to detect changes
    self.didEditProfile = YES;
    
    if([textView.text isEqualToString:@"What's your story?"]){
        textView.text = @"";
        // set text color to teamstory color
        [self.userDescription setTextColor:[UIColor colorWithRed:87.0f/255.0f green:185.0f/255.0f blue:158.0f/255.0f alpha:1.0f]];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if([textView.text isEqualToString:@""]){
        // set to placeholder light gray
        [self.userDescription setTextColor:[UIColor lightGrayColor]];
        textView.text = @"What's your story?";
    }
}


#pragma mark - Keyboard Related Methods

-(void)tappedOutside {
    
    // dismiss keyboard if present
    [self.view endEditing:YES];
    
    // hide pickerview if visible
    if(!self.industryView.isHidden){
        [self.industryView setHidden:YES];
    }
}


#pragma mark - Image Picker Methods


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // flag to detect changes
    self.didEditProfile = YES;
    
    // retrieve image from picker selection
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Dismiss media picker controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // resize to thumbnail and post format
    UIImage *smallRoundedImage = [PAPUtility resizeImage:image width:84.0f height:84.0f];
    UIImage *resizedImage = [PAPUtility resizeImage:image width:200.0f height:200.0f];
    
    // Upload image
    self.imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
    self.imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
    
    // set image for our profile image view
    [self.profilePictureImageView setImage:smallRoundedImage];
}


- (void)photoCaptureButtonAction:(id)sender {
    [self photo_picker_init];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self shouldPresentPhotoCaptureController];
}

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
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

#pragma mark - Industry Picker Delegate & Methods

- (void)industry_buttonAction:(id)sender{
    
    // dismiss keyboard if present
    [self.view endEditing:YES];
    
    [self.industryView setHidden:NO];
}

- (void)industry_chooseButtonAction:(id)sender {
    [self.industryView setHidden:YES];
    [self.industry setTitle:[self.industry_dataSource objectAtIndex:self.industry_pickerRow] forState:UIControlStateNormal];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 30;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 30;
    
    return numRows;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    self.industry_pickerRow = (int)row;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.industry_dataSource objectAtIndex:row];
}

#pragma mark - UINavigationControllerDelegate

/* The below methods help us customize the nav bar of apple's image picker */

-(void)backToPhotoAlbum{
    // check if navigation controller has been set from image picker
    if(self.navController){
        // triggered when in selected picture in picker
        [self.navController popViewControllerAnimated:YES];
    }
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // store a pointer to the image pickers nav controller for user
    self.navController = navigationController;
    
    // keep status bar white, in ios7 changes in imagepicker
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

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


@end
