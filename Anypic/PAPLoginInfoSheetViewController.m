//
//  PAPLoginInfoSheetViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/20/15.
//
//

#import "PAPLoginInfoSheetViewController.h"
#import "AppDelegate.h"
#import "PAPrecomUsersViewController.h"
#import "SVProgressHUD.h"

@interface PAPLoginInfoSheetViewController () <CLLocationManagerDelegate> {
    BOOL hasProfilePicChanged;
    BOOL displayNameCheckResult;
}
@property (strong, nonatomic) IBOutlet UIButton *profilePickerButton;
@property (nonatomic, strong) NSData *imageData_picker;
@property (nonatomic, strong) NSData *imageData_picker_small;
@property (strong, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) NSString *twitterDescription;
@property (strong, nonatomic) IBOutlet UILabel *errorMessageBox;

@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation PAPLoginInfoSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.companyNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.locationTextField.delegate = self;
    
    hasProfilePicChanged = NO;
    self.bioTextView.delegate = self;
    self.mainScrollView.delegate = self;
    
    self.profilePickerButton.layer.cornerRadius = self.profilePickerButton.bounds.size.width / 2;
    self.profilePickerButton.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
    PFUser *user = [PFUser currentUser];
    
    if ([user objectForKey:@"email"]) {
        self.emailTextField.text = [user objectForKey:@"email"];
        self.emailTextField.enabled = NO;
    }
    
    if ([PFTwitterUtils isLinkedWithUser:user]) {
        //NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", user.username];
        
        NSString * requestString = @"https://api.twitter.com/1.1/users/show.json?screen_name=toboklee";
        
        NSURL *verify = [NSURL URLWithString:requestString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
        [[PFTwitterUtils twitter] signRequest:request];
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:nil];
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        self.companyNameTextField.text = [result objectForKey:@"name"];
        self.locationTextField.text = [result objectForKey:@"location"];
        self.twitterDescription = [result objectForKey:@"description"];
        UIImage *twitterProfilePicture = [self getImageFromURL:[result objectForKey:@"profile_image_url_https"]];
        [self.profilePickerButton setBackgroundImage:twitterProfilePicture forState:UIControlStateNormal];
        
        UIImage *smallRoundedImage = [PAPUtility resizeImage:twitterProfilePicture width:84.0f height:84.0f];
        UIImage *resizedImage = [PAPUtility resizeImage:twitterProfilePicture width:200.0f height:200.0f];
        self.imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
        self.imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
    }
    
    if (self.locationTextField.text.length == 0) {
        [self detectLocation];
    }
}

- (void) detectLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (self.twitterDescription.length > 0) {
        self.bioTextView.text = self.twitterDescription;
    } else {
        [self.bioTextView setTextColor:[UIColor colorWithWhite:0.8 alpha:1.0f]];
        self.bioTextView.text = @"Bio";
    }

}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

- (IBAction)profilePickerButtonAction:(id)sender {
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    hasProfilePicChanged = YES;
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *smallRoundedImage = [PAPUtility resizeImage:image width:84.0f height:84.0f];
    UIImage *resizedImage = [PAPUtility resizeImage:image width:200.0f height:200.0f];
    
    // Upload image
    self.imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
    self.imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
    
    [self.profilePickerButton setBackgroundImage:image forState:UIControlStateNormal];
    self.profilePickerButton.backgroundColor = [UIColor clearColor];
    self.profilePickerButton.layer.cornerRadius = self.profilePickerButton.frame.size.width / 2;
    self.profilePickerButton.clipsToBounds = YES;
}

-(void)uploadImage_small:(NSData *)imageData {
    if (imageData) {
        PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
        [[PFUser currentUser] setObject:imageFile forKey:@"profilePictureSmall"];
    }
}

-(void)uploadImage_medium:(NSData *)imageData {
    if (imageData) {
        PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
        [[PFUser currentUser] setObject:imageFile forKey:@"profilePictureMedium"];
    }
}

- (IBAction)nextButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.mainScrollView setContentOffset:CGPointZero animated:YES];
    
    if (self.companyNameTextField.text.length == 0) {
        self.errorMessageBox.text = @"Please fill out the 4 fields to help us get to know you better.";
        return;
    }
    
    if (!displayNameCheckResult) {
        self.errorMessageBox.text = @"Your username is already being used.";
        return;
    }
    
    if (self.emailTextField.text.length == 0) {
        self.errorMessageBox.text = @"Please fill out the 4 fields to help us get to know you better.";
        return;
    }
    
    if (![self NSStringIsValidEmail:self.emailTextField.text]) {
        self.errorMessageBox.text = @"Please use a valid email.";
        return;
    }
    
    if (self.locationTextField.text.length == 0) {
        self.errorMessageBox.text = @"Please fill out the 4 fields to help us get to know you better.";
        return;
    }
    
    if (self.bioTextView.text.length == 0 || [self.bioTextView.text isEqualToString:@"Bio"]) {
        self.errorMessageBox.text = @"Please fill out the 4 fields to help us get to know you better.";
        self.errorMessageBox.textColor = [UIColor redColor];
        return;
    }
    
    if (self.imageData_picker && hasProfilePicChanged) {
        // upload image from library
        [self uploadImage_medium:self.imageData_picker];
    } else if (!hasProfilePicChanged && [self.profilePickerButton backgroundImageForState:UIControlStateNormal] == nil) {
        // Nothing picked. Mount a default image
        UIImage *image = [UIImage imageNamed:@"default-pic.png"];
        UIImage *resizedImage = [PAPUtility resizeImage:image width:200.0f height:200.0f];
        
        self.imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
        [self uploadImage_medium:self.imageData_picker];
    } else {
        // upload image for twitter
        [self uploadImage_medium:self.imageData_picker];
    }
    
    if (self.imageData_picker_small && hasProfilePicChanged) {
        // upload image from library
        [self uploadImage_small:self.imageData_picker_small];
    } else if (!hasProfilePicChanged && [self.profilePickerButton backgroundImageForState:UIControlStateNormal] == nil) {
        // Nothing picked. Mount a default image
        UIImage *image = [UIImage imageNamed:@"default-pic.png"];
        UIImage *smallRoundedImage = [PAPUtility resizeImage:image width:84.0f height:84.0f];
        
        self.imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
        [self uploadImage_small:self.imageData_picker_small];
    } else {
        // upload image for twitter
        [self uploadImage_small:self.imageData_picker_small];
    }
    
    // If all validation processes pass, save data and display a new-comer screen.
    PFUser *targetUser = [PFUser currentUser];
    [SVProgressHUD show];
    
    bool profileExist = YES;
    NSNumber *profileExist_num = [NSNumber numberWithBool:profileExist];
    [targetUser setObject: profileExist_num forKey:@"profileExist"];
    
    [targetUser setObject:self.companyNameTextField.text forKey:@"displayName"];
    [targetUser setObject:self.locationTextField.text forKey:@"location"];
    [targetUser setObject:self.bioTextView.text forKey:@"description"];
    [targetUser setObject:[NSNumber numberWithInt:100] forKey:@"activityPoints"];
    
    // only save set email when emailTextField enabled.
    if (self.emailTextField.enabled == YES) {
        [targetUser setObject:self.emailTextField.text forKey:@"email"];
    }
    
    [targetUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        // TODO display a new screen
        if (!error) {
            //successful
            PAPrecomUsersViewController *recomUsersViewController = [[PAPrecomUsersViewController alloc] initWithNibName:@"PAPrecomUsersViewController" bundle:nil];
            [self presentViewController:recomUsersViewController animated:YES completion:nil];
        } else {
            if ([error code] == 203) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                message:@"Email you've entered is already being used"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSString *errorMessage = [error localizedDescription];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }
    }];
    
}

- (IBAction)cancelButtonAction:(id)sender {
    [PFUser logOut];
    
    [self.view endEditing:YES];
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!error) {
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
        } else {
            NSLog(@"Anonymous login failed");
        }
    }];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    textView.textColor = [UIColor blackColor];
    
    if ([textView.text isEqualToString:@"Bio"]) {
        textView.text = @"";
    }
    
    CGPoint scrollPoint = CGPointMake(0, textView.frame.origin.y - 50);
    [self.mainScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"Bio";
        textView.textColor = [UIColor colorWithWhite:0.8 alpha:1.0f];
    }
    [self.mainScrollView setContentOffset:CGPointZero animated:YES];
}

#pragma UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    float offsetValue = 50.0f;
    
    CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y - offsetValue);
    [self.mainScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.mainScrollView setContentOffset:CGPointZero animated:YES];
    
    if (textField == self.companyNameTextField) {
        PFQuery *displayNameCheck = [PFUser query];
        [displayNameCheck whereKey:@"displayName" equalTo:self.companyNameTextField.text];
        [displayNameCheck getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error && object) {
                displayNameCheckResult = NO;
            } else {
                displayNameCheckResult = YES;
            }
        }];
    }
}

- (IBAction)locationDetectionButtonAction:(id)sender {
    [self detectLocation];
}

#pragma CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.locationTextField.text = [locations lastObject];
}

@end
