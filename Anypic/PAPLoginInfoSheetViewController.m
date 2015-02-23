//
//  PAPLoginInfoSheetViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/20/15.
//
//

#import "PAPLoginInfoSheetViewController.h"

@interface PAPLoginInfoSheetViewController ()
@property (strong, nonatomic) IBOutlet UIButton *profilePickerButton;
@property (nonatomic, strong) NSData *imageData_picker;
@property (nonatomic, strong) NSData *imageData_picker_small;
@property (strong, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextView *bioTextView;

@end

@implementation PAPLoginInfoSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profilePickerButton.layer.cornerRadius = self.profilePickerButton.bounds.size.width / 2;
    self.profilePickerButton.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
    PFUser *user = [PFUser currentUser];
    
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
        [user setObject:[result objectForKey:@"profile_image_url_https"]
                 forKey:@"picture"];
        // does this thign help?
        [user setUsername:[result objectForKey:@"screen_name"]];
        
        NSLog(@"%@", result);
        
        self.companyNameTextField.text = [result objectForKey:@"name"];
        self.locationTextField.text = [result objectForKey:@"location"];
        self.bioTextView = [result objectForKey:@"description"];
        UIImage *twitterProfilePicture = [self getImageFromURL:[result objectForKey:@"profile_image_url_https"]];
        [self.profilePickerButton setBackgroundImage:twitterProfilePicture forState:UIControlStateNormal];
        
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

- (IBAction)cancelButtonAction:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

@end
