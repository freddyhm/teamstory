//
//  PAPProfileSettingViewController.m
//  TeamStory
//

#import "PAPProfileSettingViewController.h"
#import "PAPAccountViewController.h"
#import "AppDelegate.h"
#import "UIImage+ResizeAdditions.h"
#define SUCCESSFUL 1
#define IMAGE_NIL 2

@interface PAPProfileSettingViewController() {
    BOOL smallImage;
    int movementDistance;
}

@property (nonatomic,strong) UINavigationController *navController;
@property (nonatomic, strong) PAPAccountViewController *accountViewController_tabBar;
@property (nonatomic, strong) NSData *imageData_picker;
@property (nonatomic, strong) NSData *imageData_picker_small;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIButton *dropDownButton;
@property (nonatomic, strong) UIButton *dropDownButton1;
@property (nonatomic, strong) UIButton *dropDownButton2;
@property (nonatomic, strong) UIButton *dropDownButton3;
@property (nonatomic, strong) NSString *dropDownSelection;
@property (nonatomic, strong) NSString *location_user;
@property (nonatomic, strong) NSString *website_user;
@property (nonatomic, strong) NSString *displayName_user;
@property (nonatomic, strong) NSString *description_user;

@end

@implementation PAPProfileSettingViewController
@synthesize companyName;
@synthesize location;
@synthesize description;
@synthesize website;
@synthesize collaborator;
@synthesize navController;
@synthesize accountViewController_tabBar;
@synthesize imageData_picker;
@synthesize imageData_picker_small;
@synthesize user;
@synthesize dropDownButton;
@synthesize dropDownButton1;
@synthesize dropDownButton2;
@synthesize dropDownButton3;
@synthesize dropDownSelection;
@synthesize location_user;
@synthesize website_user;
@synthesize displayName_user;
@synthesize description_user;




#pragma mark - Initialization

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    user = [PFUser currentUser];
    
    // creating another method to call later for the freshing purpose.
    [self refreshView];
}

- (void)refreshView {
    location_user = self.user[@"location"];
    website_user = self.user[@"website"];
    displayName_user = self.user[@"displayName"];
    description_user = self.user[@"description"];
    dropDownSelection = self.user[@"userType"];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"backgroundleather.png"] drawInRect:self.view.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    
    UIButton *profileImagePicker = [UIButton buttonWithType:UIButtonTypeCustom];
    profileImagePicker.frame = CGRectMake( 50.0f, 50.0f, 100.0f, 100.0f );
    [profileImagePicker setImage:[UIImage imageNamed:@"profilePic.png"] forState:UIControlStateNormal];
    //[cameraButton setImage:[UIImage imageNamed:@"ButtonCameraSelected.png"] forState:UIControlStateHighlighted];
    [profileImagePicker addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:profileImagePicker];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [profileImagePicker addGestureRecognizer:swipeUpGestureRecognizer];
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake( 0.0f, 0.0f, 52.0f, 32.0f)];
    [backButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake( self.view.bounds.size.width - 50.0f, 10.0f, 52.0f, 32.0f)];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    //[saveButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[saveButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [saveButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"ButtonNavigationBar.png"] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"ButtonNavigationBarSelected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    dropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton setFrame:CGRectMake( 80.0f, 160.0f, 205.0f, 25.0f)];
    [dropDownButton setBackgroundImage:[UIImage imageNamed:@"dropDownMenu.png"] forState:UIControlStateNormal];
    [dropDownButton setTitle:@"Select User Type" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton addTarget:self action:@selector(dropDownButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dropDownButton];
    
    UIImageView *profilePicture = [[UIImageView alloc] initWithImage:nil];
    [profilePicture setImage:[UIImage imageNamed:@"profileAddNew.png"]];
    [profilePicture setFrame:CGRectMake( 0.0f, 0.0f, 320.0f, 145.0f)];
    [self.view addSubview:profilePicture];
    
    UIImageView *userTypeImageview = [[UIImageView alloc] initWithImage:nil];
    [userTypeImageview setImage:[UIImage imageNamed:@"companyName.png"]];
    [userTypeImageview setFrame:CGRectMake( 15.0f, 147.0f, 50.0f, 50.0f)];
    [self.view addSubview:userTypeImageview];
    
    UIImageView *companyImageView = [[UIImageView alloc] initWithImage:nil];
    [companyImageView setImage:[UIImage imageNamed:@"companyName.png"]];
    [companyImageView setFrame:CGRectMake( 15.0f, 187.0f, 50.0f, 50.0f)];
    [self.view addSubview:companyImageView];
    
    UIImageView *descriptionImageView = [[UIImageView alloc] initWithImage:nil];
    [descriptionImageView setImage:[UIImage imageNamed:@"profileDescription.png"]];
    [descriptionImageView setFrame:CGRectMake( 15.0f, 227.0f, 50.0f, 50.0f)];
    [self.view addSubview:descriptionImageView];
    
    UIImageView *locationImageView = [[UIImageView alloc] initWithImage:nil];
    [locationImageView setImage:[UIImage imageNamed:@"profileLocation.png"]];
    [locationImageView setFrame:CGRectMake( 15.0f, 267.0f, 50.0f, 50.0f)];
    [self.view addSubview:locationImageView];
    
    UIImageView *websiteImageView = [[UIImageView alloc] initWithImage:nil];
    [websiteImageView setImage:[UIImage imageNamed:@"profileWebsite.png"]];
    [websiteImageView setFrame:CGRectMake( 15.0f, 307.0f, 50.0f, 50.0f)];
    [self.view addSubview:websiteImageView];
    
    /*
    UIImageView *collaboratorImageView = [[UIImageView alloc] initWithImage:nil];
    [collaboratorImageView setImage:[UIImage imageNamed:@"profileCollaborator.png"]];
    [collaboratorImageView setFrame:CGRectMake( 15.0f, 307.0f, 50.0f, 50.0f)];
    [self.view addSubview:collaboratorImageView];
     */
    
    NSLog(@"%@", displayName_user);
    NSLog(@"%@", location_user);
    NSLog(@"%@", description_user);
    NSLog(@"%@", website_user);
    
    
    CGRect companyName_frame = CGRectMake( 80.0f, 200.0f, 205.0f, 25.0f);
    companyName = [[UITextField alloc] initWithFrame:companyName_frame];
    [companyName setBackgroundColor:[UIColor whiteColor]];
    [companyName setFont:[UIFont systemFontOfSize:10]];
    companyName.borderStyle = UITextBorderStyleRoundedRect;
    companyName.placeholder = displayName_user;
    //[companyName setText:[self.appUserInfo objectForKey:@"companyName"]];
    companyName.userInteractionEnabled = YES;
    companyName.delegate = self;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [self.view addSubview:companyName];

    CGRect location_frame = CGRectMake( 80.0f, 240.0f, 205.0f, 25.0f);
    location = [[UITextField alloc] initWithFrame:location_frame];
    [location setBackgroundColor:[UIColor whiteColor]];
    [location setFont:[UIFont systemFontOfSize:10]];
    location.borderStyle = UITextBorderStyleRoundedRect;
    location.placeholder = location_user;
    location.userInteractionEnabled = YES;
    location.delegate = self;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [location resignFirstResponder];
    [self.view addSubview:location];
    
    CGRect description_frame = CGRectMake( 80.0f, 280.0f, 205.0f, 25.0f);
    description = [[UITextField alloc] initWithFrame:description_frame];
    [description setBackgroundColor:[UIColor whiteColor]];
    [description setFont:[UIFont systemFontOfSize:10]];
    description.borderStyle = UITextBorderStyleRoundedRect;
    description.placeholder = description_user;
    description.userInteractionEnabled = YES;
    description.delegate = self;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [description resignFirstResponder];
    [self.view addSubview:description];
    
    CGRect website_frame = CGRectMake( 80.0f, 320.0f, 205.0f, 25.0f);
    website = [[UITextField alloc] initWithFrame:website_frame];
    [website setBackgroundColor:[UIColor whiteColor]];
    [website setFont:[UIFont systemFontOfSize:10]];
    website.borderStyle = UITextBorderStyleRoundedRect;
    website.placeholder = website_user;
    website.userInteractionEnabled = YES;
    website.delegate = self;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [website resignFirstResponder];
    [self.view addSubview:website];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissKeyboard];
    [self dismissModalViewControllerAnimated:NO];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Dismiss controller
    [picker dismissModalViewControllerAnimated:YES];
    
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationLow];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(250, 250));
    [image drawInRect: CGRectMake(0, 0, 640, 640)];
    
    //UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    imageData_picker = UIImageJPEGRepresentation(image, 0.05f);
    imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);

    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake( 50.0f, 50.0f, 100.0f, 100.0f );
    [cameraButton setImage:image forState:UIControlStateNormal];
    //[cameraButton setImage:[UIImage imageNamed:@"ButtonC34ameraSelected.png"] forState:UIControlStateHighlighted];
    [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [cameraButton addGestureRecognizer:swipeUpGestureRecognizer];

}

-(void)uploadImage:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:@"profilePic.jpg" data:imageData];
    
    //HUD creation here (see example for code)
    refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:refreshHUD];
    
    // Register for HUD callbacks so we can remove it from the window at the right time
    refreshHUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [refreshHUD show:YES];
    
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if (smallImage == YES) {
                smallImage = NO;
                user[@"profilePictureSmall"] = imageFile;
            } else if (smallImage == NO) {
                smallImage = YES;
                user[@"profilePic"] = imageFile;
            }
            
                NSLog(@"Picture has been uploaded successfully (NO HUD)");
                //profilePic.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [user refresh];
                        [self refreshView];
                        NSLog(@"Picture has been uploaded successfully (WITH HUD)");
                    }
                    else{
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
                [refreshHUD removeFromSuperview];

        }
        else{
            [HUD hide:YES];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        HUD.progress = (float)percentDone/100;
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


#pragma mark - PAPTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

#pragma mark - ()

- (void)photoCaptureButtonAction:(id)sender {
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        //UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        //[actionSheet showFromTabBar:self.tabBar];
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
    
    [self presentModalViewController:cameraUI animated:YES];
    
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
    
    [self presentModalViewController:cameraUI animated:YES];
    
    return YES;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self shouldPresentPhotoCaptureController];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Return Key Pressed");
    if (textField == companyName) {
        [companyName resignFirstResponder];
    }
    else if (textField == location) {
        [location resignFirstResponder];
    }
    else if (textField == description) {
        [description resignFirstResponder];
    }
    else if (textField == website) {
        [website resignFirstResponder];
    }
    else {
        [collaborator resignFirstResponder];
    }
    
    return YES;
}


#pragma mark - ()

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonAction:(id)sender {
    NSString* companyName_input = self.companyName.text;
    NSString* location_input = self.location.text;
    NSString* description_input = self.description.text;
    NSString* website_input = self.website.text;
    
    if ([companyName_input length] > 0 && [location_input length] > 0 && [description_input length] > 0 && [website_input length] > 0) {
        
        if (!imageData_picker) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You did not select any image. Would you like to update the image?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            alert.tag = IMAGE_NIL;
            [alert show];
            return;
            
        } else {
            smallImage = NO;
            [self uploadImage:imageData_picker];
            [self uploadImage:imageData_picker_small];
        }
        
        self.user[@"displayName"] = companyName_input;
        self.user[@"location"] = location_input;
        self.user[@"description"] = description_input;
        self.user[@"website"] = website_input;
        self.user[@"userType"] = dropDownSelection;
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        alert.tag = SUCCESSFUL;
        [alert show];
        
        //Checking profile existence.
        bool profileExist = YES; // either YES or NO
        NSNumber *profileBoolNum = [NSNumber numberWithBool: profileExist];
        [[PFUser currentUser] setObject: profileBoolNum forKey: @"profileExist"];
        
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please update all of your information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SUCCESSFUL) {
        if (buttonIndex == 0) {
            NSLog(@"Logged In Sucessfully");
            [PFUser user];
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
            return;
        }
    } else if (alertView.tag == IMAGE_NIL) {
        if (buttonIndex == 1) {
            [self performSelector:@selector(photoCaptureButtonAction:)];
        } else if (buttonIndex == 0) {
            NSString* companyName_input = self.companyName.text;
            NSString* location_input = self.location.text;
            NSString* description_input = self.description.text;
            NSString* website_input = self.website.text;
            
            self.user[@"displayName"] = companyName_input;
            self.user[@"location"] = location_input;
            self.user[@"description"] = description_input;
            self.user[@"website"] = website_input;
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            alert.tag = SUCCESSFUL;
            [alert show];
        }
    }
    /*
    if (buttonIndex == 0) {

        UINavigationController *backToAccountView = self.tabBarController.viewControllers[PAPProfileTabBarItemIndex];
        self.tabBarController.selectedViewController = backToAccountView;

        [accountViewController_tabBar setUser:[PFUser currentUser]];
        [backToAccountView pushViewController:accountViewController_tabBar animated:YES];
        
        //[self.navigationController popViewControllerAnimated:YES];

    }
     */
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField: textField up: YES];
}

- (void) dropDownButtonAction:(id) sender {
    NSLog(@"dropdown button pressed");
    
    dropDownButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton1 setFrame:CGRectMake( 80.0f, 185.0f, 205.0f, 25.0f)];
    [dropDownButton1 setBackgroundImage:[UIImage imageNamed:@"dropDownMenu.png"] forState:UIControlStateNormal];
    [dropDownButton1 setTitle:@"Prospect" forState:UIControlStateNormal];
    //[dropDownButton1 setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton1 addTarget:self action:@selector(dropDownButtonPressedAction1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dropDownButton1];
    
    dropDownButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton2 setFrame:CGRectMake( 80.0f, 210.0f, 205.0f, 25.0f)];
    [dropDownButton2 setBackgroundImage:[UIImage imageNamed:@"dropDownMenu.png"] forState:UIControlStateNormal];
    [dropDownButton2 setTitle:@"Entrepreneur & Start Up" forState:UIControlStateNormal];
    //[dropDownButton2 setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton2 addTarget:self action:@selector(dropDownButtonPressedAction2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dropDownButton2];
    
    dropDownButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton3 setFrame:CGRectMake( 80.0f, 235.0f, 205.0f, 25.0f)];
    [dropDownButton3 setBackgroundImage:[UIImage imageNamed:@"dropDownMenu.png"] forState:UIControlStateNormal];
    [dropDownButton3 setTitle:@"Incubator" forState:UIControlStateNormal];
    //[dropDownButton3 setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton3 addTarget:self action:@selector(dropDownButtonPressedAction3:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dropDownButton3];
}

- (void) dropDownButtonPressedAction1:(id) sender {
    [dropDownButton1 removeFromSuperview];
    [dropDownButton2 removeFromSuperview];
    [dropDownButton3 removeFromSuperview];
    dropDownSelection = @"Prospect";
    [dropDownButton removeFromSuperview];
    
    
    dropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton setFrame:CGRectMake( 80.0f, 160.0f, 205.0f, 25.0f)];
    [dropDownButton setBackgroundImage:[UIImage imageNamed:@"dropDownMenu.png"] forState:UIControlStateNormal];
    [dropDownButton setTitle:@"Prospect" forState:UIControlStateNormal];
    //[dropDownButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton addTarget:self action:@selector(dropDownButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dropDownButton];
}

- (void) dropDownButtonPressedAction2:(id) sender {
    [dropDownButton1 removeFromSuperview];
    [dropDownButton2 removeFromSuperview];
    [dropDownButton3 removeFromSuperview];
    dropDownSelection = @"Entrepreneur & Start Up";
    [dropDownButton removeFromSuperview];
    
    
    dropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton setFrame:CGRectMake( 80.0f, 160.0f, 205.0f, 25.0f)];
    [dropDownButton setBackgroundImage:[UIImage imageNamed:@"dropDownMenu.png"] forState:UIControlStateNormal];
    [dropDownButton setTitle:@"Entrepreneur & Start Up" forState:UIControlStateNormal];
    //[dropDownButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton addTarget:self action:@selector(dropDownButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dropDownButton];
}

- (void) dropDownButtonPressedAction3:(id) sender {
    [dropDownButton1 removeFromSuperview];
    [dropDownButton2 removeFromSuperview];
    [dropDownButton3 removeFromSuperview];
    dropDownSelection = @"Incubator";
    [dropDownButton removeFromSuperview];
    
    
    dropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton setFrame:CGRectMake( 80.0f, 160.0f, 205.0f, 25.0f)];
    [dropDownButton setBackgroundImage:[UIImage imageNamed:@"dropDownMenu.png"] forState:UIControlStateNormal];
    [dropDownButton setTitle:@"Incubator" forState:UIControlStateNormal];
    //[dropDownButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton addTarget:self action:@selector(dropDownButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dropDownButton];
    
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    float movementDuration = 0.3f; // tweak as needed
    
    if (textField == companyName) {
        movementDistance = 50; // tweak as needed
    }
    else if (textField == location) {
        movementDistance = 100; // tweak as needed
     }
    else if (textField == description) {
        movementDistance = 150; // tweak as needed
    }
    else if (textField == website) {
        movementDistance = 150; // tweak as needed
    }

    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)dismissKeyboard {
    [website resignFirstResponder];
    [description resignFirstResponder];
    [location resignFirstResponder];
    [companyName resignFirstResponder];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
    HUD = nil;
}

@end

