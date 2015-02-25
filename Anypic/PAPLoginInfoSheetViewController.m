//
//  PAPLoginInfoSheetViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/20/15.
//
//

#import "PAPLoginInfoSheetViewController.h"
#import "AppDelegate.h"

@interface PAPLoginInfoSheetViewController () {
    BOOL hasProfilePicChanged;
}
@property (strong, nonatomic) IBOutlet UIButton *profilePickerButton;
@property (nonatomic, strong) NSData *imageData_picker;
@property (nonatomic, strong) NSData *imageData_picker_small;
@property (strong, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

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
    
    if ([PFTwitterUtils isLinkedWithUser:user]) {
        NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", user.username];
        
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
        self.bioTextView.text = [result objectForKey:@"description"];
        UIImage *twitterProfilePicture = [self getImageFromURL:[result objectForKey:@"profile_image_url_https"]];
        [self.profilePickerButton setBackgroundImage:twitterProfilePicture forState:UIControlStateNormal];
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.bioTextView setTextColor:[UIColor colorWithWhite:0.8 alpha:1.0f]];
    self.bioTextView.text = @"Bio";
    

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
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
    
    [[PFUser currentUser] setObject:imageFile forKey:@"profilePictureSmall"];
    [[PFUser currentUser] saveInBackground];
}

-(void)uploadImage_medium:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
    [[PFUser currentUser] setObject:imageFile forKey:@"profilePictureMedium"];
    [[PFUser currentUser] saveInBackground];
}

- (IBAction)nextButtonAction:(id)sender {
    if (self.companyNameTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Company Name" message:@"Please insert a Company Name" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (self.emailTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please insert an email address" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (![self NSStringIsValidEmail:self.emailTextField.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please insert a valid email" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (self.locationTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Location" message:@"Please insert a location" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (self.bioTextView.text.length == 0 && [self.bioTextView.text isEqualToString:@"Bio"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Bio" message:@"Please insert a valid bio" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    // If all validation processes pass, save data and display a new-comer screen.
    PFUser *user = [PFUser currentUser];
    
    bool profileExist = YES;
    NSNumber *profileExist_num = [NSNumber numberWithBool:profileExist];
    [user setObject: profileExist_num forKey: @"profileExist"];
    
    [user setObject:self.companyNameTextField.text forKey:@"displayName"];
    [user setObject:self.emailTextField.text forKey:@"email"];
    [user setObject:self.locationTextField.text forKey:@"location"];
    [user setObject:self.bioTextView.text forKey:@"description"];
    
    if (self.imageData_picker && hasProfilePicChanged) {
        [self uploadImage_medium:self.imageData_picker];
    } else if (!hasProfilePicChanged && ![self.profilePickerButton backgroundImageForState:UIControlStateNormal]) {
        UIImage *image = [UIImage imageNamed:@"default-pic.png"];
        UIImage *smallRoundedImage = [PAPUtility resizeImage:image width:84.0f height:84.0f];
        
        self.imageData_picker = UIImageJPEGRepresentation(smallRoundedImage, 1);
        [self uploadImage_medium:self.imageData_picker];
        
    }
    
    if (self.imageData_picker_small && hasProfilePicChanged) {
        [self uploadImage_medium:self.imageData_picker_small];
    } else if (!hasProfilePicChanged && ![self.profilePickerButton backgroundImageForState:UIControlStateNormal]) {
        UIImage *image = [UIImage imageNamed:@"default-pic.png"];
        UIImage *resizedImage = [PAPUtility resizeImage:image width:200.0f height:200.0f];
        self.imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
        [self uploadImage_medium:self.imageData_picker];
    }
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // TODO display a new screen
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
    textView.text = @"";
    
    CGPoint scrollPoint = CGPointMake(0, textView.frame.origin.y);
    [self.mainScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"Bio";
        textView.textColor = [UIColor colorWithWhite:0.8 alpha:1.0f];
    }
}

#pragma UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    float offsetValue = 5.0f;
    
    CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y - offsetValue);
    [self.mainScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.mainScrollView setContentOffset:CGPointZero animated:YES];
}


@end
