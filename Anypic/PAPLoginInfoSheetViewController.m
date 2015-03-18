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
#import "PostPicViewController.h"

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
@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;
@property (assign) NSUInteger cameraRollIndex;
@property (nonatomic,strong) UIImagePickerController *camera;
@property (nonatomic, strong) ELCImagePickerController *elcPicker;

@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation PAPLoginInfoSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type": @"New Profile Screen 1"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"viewed_screen" action:@"new_profile_1" label:@"" value:@""];

    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"New Profile Screen 1"];
    
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
        NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@",  [PFTwitterUtils twitter].screenName];
        
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
    self.locationTextField.placeholder = @"Loading Location...";
    
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
    // init asset library
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    self.specialLibrary = library;
    
    NSMutableArray *groups = [NSMutableArray array];
    
    // keep track of camera roll index
    self.cameraRollIndex = 0;
    
    // fetch all albums and set first pop up to camera roll
    [_specialLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group) {
            
            [groups addObject:group];
            
            NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
            
            if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"]) {
                // display camera roll first
                self.cameraRollIndex = [groups indexOfObject:group];
            }
        } else {
            [self displayPickerForGroup:[groups objectAtIndex:self.cameraRollIndex]];
        }
    } failureBlock:^(NSError *error) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"A problem occured %@", [error description]);
        // an error here means that the asset groups were inaccessable.
        // Maybe the user or system preferences refused access.
    }];
}

- (void)displayPickerForGroup:(ALAssetsGroup *)group
{
    ELCAssetTablePicker *tablePicker = [[ELCAssetTablePicker alloc] initWithStyle:UITableViewStylePlain];
    
    // set title with arrow
    NSString *albumName = [group valueForProperty:ALAssetsGroupPropertyName];
    [tablePicker setButtonTitle:albumName];
    
    tablePicker.singleSelection = YES;
    tablePicker.immediateReturn = NO;
    
    self.elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:tablePicker];
    self.elcPicker.maximumImagesCount = 1;
    self.elcPicker.imagePickerDelegate = self;
    self.elcPicker.defaultImagePickerDelegate = self;
    self.elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    tablePicker.parent = self.elcPicker;
    
    // Move me
    tablePicker.assetGroup = group;
    
    [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    
    [self presentViewController:self.elcPicker animated:YES completion:nil];
}

- (UIImagePickerController *)shouldStartCameraController {
    /* starts camera, sets tabbarcontroller as delegate, and returns image picker */
    
    self.camera = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        self.camera.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        self.camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            self.camera.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            self.camera.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return nil;
    }
    
    self.camera.allowsEditing = NO;
    self.camera.showsCameraControls = YES;
    self.camera.delegate = self;
    
    [SVProgressHUD dismiss];
    
    return self.camera;
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
    
    [SVProgressHUD show];
    
    PFQuery *displayNameCheck = [PFUser query];
    [displayNameCheck whereKey:@"displayName" equalTo:self.companyNameTextField.text];
    [displayNameCheck getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error && object) {
            self.errorMessageBox.text = @"Your username is already being used.";
        } else {
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
            
            // disable to prevent double tapping
            self.nextButton.enabled = NO;
            [SVProgressHUD show];
            
            if (self.imageData_picker && hasProfilePicChanged) {
                // upload image from library
                [self uploadImage_medium:self.imageData_picker];
            } else if (!hasProfilePicChanged && !self.imageData_picker) {
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
            } else if (!hasProfilePicChanged && !self.imageData_picker_small) {
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
                // TODO display a new screen
                if (!error) {
                    //successful
                    PAPrecomUsersViewController *recomUsersViewController = [[PAPrecomUsersViewController alloc] initWithNibName:@"PAPrecomUsersViewController" bundle:nil];
                    [self presentViewController:recomUsersViewController animated:YES completion:nil];
                } else {
                    
                    // re-enable once the it fails to log in
                    self.nextButton.enabled = YES;
                    if ([error code] == 203) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign up error"
                                                                        message:@"Email you've entered is already being used"
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"Dismiss", nil];
                        [alert show];
                    } else {
                        NSString *errorMessage = [error localizedDescription];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign up failed"
                                                                        message:errorMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"Dismiss", nil];
                        [alert show];
                    }
                }
                [SVProgressHUD dismiss];
            }];

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
}

- (IBAction)locationDetectionButtonAction:(id)sender {
    [self detectLocation];
}

#pragma CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.count > 0) {
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error){
                NSLog(@"Geocode failed with error: %@", error);
                return;
                
            }
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            /*
             -----------Available Fields------------
            NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
            NSLog(@"placemark.country %@",placemark.country);
            NSLog(@"placemark.postalCode %@",placemark.postalCode);
            NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
            NSLog(@"placemark.locality %@",placemark.locality);
            NSLog(@"placemark.subLocality %@",placemark.subLocality);
            NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
            */
            
            self.locationTextField.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationTextField.placeholder = @"Location";
}

#pragma mark - ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    UIImage *image = [[info objectAtIndex:0] objectForKey:UIImagePickerControllerOriginalImage];
    
    [self processPickedImage:image];
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    hasProfilePicChanged = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self processPickedImage:image];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.elcPicker dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    hasProfilePicChanged = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma Custom
- (void)processPickedImage:(UIImage *)image {
    hasProfilePicChanged = YES;
    
    UIImage *smallRoundedImage = [PAPUtility resizeImage:image width:84.0f height:84.0f];
    UIImage *resizedImage = [PAPUtility resizeImage:image width:200.0f height:200.0f];
    
    // Upload image
    self.imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
    self.imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
    
    [self.profilePickerButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.profilePickerButton setBackgroundImage:image forState:UIControlStateNormal];
    self.profilePickerButton.backgroundColor = [UIColor clearColor];
    self.profilePickerButton.layer.cornerRadius = self.profilePickerButton.frame.size.width / 2;
    self.profilePickerButton.clipsToBounds = YES;
}


@end
