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
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) PFImageView* profilePictureImageView;
@property (nonatomic, strong) PFFile *imageProfileFile;
@property (nonatomic, strong) UIView *startOverlay;


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
@synthesize backgroundView;
@synthesize profilePictureImageView;
@synthesize imageProfileFile;
@synthesize startOverlay;




#pragma mark - Initialization

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    user = [PFUser currentUser];
    
    // creating another method to call later for the freshing purpose.
    [self refreshView];
}

- (void)refreshView {
    bool profileExist = self.user[@"profileExist"];
    location_user = self.user[@"location"];
    website_user = self.user[@"website"];
    displayName_user = self.user[@"displayName"];
    description_user = self.user[@"description"];
    dropDownSelection = self.user[@"userType"];
    imageProfileFile = [self.user objectForKey:@"profilePictureMedium"];
    
    if ([location_user length] == 0) {
        location_user = @"Location";
    }
    if ([website_user length] == 0) {
        website_user = @"Website";
    }
    if ([displayName_user length] == 0) {
        displayName_user = @"Display Name";
    }
    if ([description_user length] == 0) {
        description_user = @"Description";
    }
    
    if (profileExist != true) {
        self.startOverlay = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.startOverlay];
        
        UIImageView *startOverlay_image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        UIButton *proceed_button = [[UIButton alloc] init];
        
        if ([UIScreen mainScreen].bounds.size.height == 480) {
            [startOverlay_image setImage:[UIImage imageNamed:@"intro1-iphone4.png"]];
            [proceed_button setFrame:CGRectMake(35.0f, 416.0f, 250.0f, 43.0f)];
        } else {
            [startOverlay_image setImage:[UIImage imageNamed:@"intro1-iphone5.png"]];
            [proceed_button setFrame:CGRectMake(35.0f, 504.0f, 250.0f, 43.0f)];
        }
        
        [self.startOverlay addSubview:startOverlay_image];
        
        [proceed_button addTarget:self action:@selector(proceed_button_action:) forControlEvents:UIControlEventTouchUpInside];
        [self.startOverlay addSubview:proceed_button];
    }
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    // Initialization
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *lineColor = [UIColor colorWithWhite:245.0f/255.0f alpha:1.0];
    UIFont *fonts = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    
    NSLog(@"%f", self.view.bounds.size.height);
    
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height - 270.0f, self.view.bounds.size.width, 270.0f)];
    [backgroundView setBackgroundColor:backgroundColor];
    [self.view addSubview:backgroundView];
    
    
    UIButton *profileImagePicker = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        profileImagePicker.frame = CGRectMake( 110.0f, 87.0f, 100.0f, 100.0f );
    } else {
        profileImagePicker.frame = CGRectMake( 110.0f, 130.0f, 100.0f, 100.0f );
    }
    [profileImagePicker setImage:[UIImage imageNamed:@"profilepicture.png"] forState:UIControlStateNormal];
    
    [profileImagePicker addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:profileImagePicker];
    
    
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 110.0f, 87.0f, 100.0f, 100.0f)];
    } else {
        profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 110.0f, 130.0f, 100.0f, 100.0f)];
    }
    [self.view addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    
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
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [profileImagePicker addGestureRecognizer:swipeUpGestureRecognizer];
    
    
    // Do not display back button if user is first time logging in.
    if (profileExist == true) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake( 0.0f, 0.0f, 22.0f, 22.0f)];
        [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    
     
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake( 0.0f, 0.0f, 22.0f, 22.0f)];
    [[saveButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [saveButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"button_done.png"] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"button_done_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    [self createdropDownButton:(@"Select User Type")];
    
    UIImageView *userTypeImageview = [[UIImageView alloc] initWithImage:nil];
    [userTypeImageview setImage:[UIImage imageNamed:@"profileType.png"]];
    [userTypeImageview setFrame:CGRectMake( 15.0f, 7.0f, 40.0f, 40.0f)];
    [backgroundView addSubview:userTypeImageview];
    
    UIImageView *companyImageView = [[UIImageView alloc] initWithImage:nil];
    [companyImageView setImage:[UIImage imageNamed:@"companyName.png"]];
    [companyImageView setFrame:CGRectMake( 15.0f, 61.0f, 40.0f, 40.0f)];
    [backgroundView addSubview:companyImageView];
    
    UIImageView *locationImageView = [[UIImageView alloc] initWithImage:nil];
    [locationImageView setImage:[UIImage imageNamed:@"profileLocation.png"]];
    [locationImageView setFrame:CGRectMake( 15.0f, 115.0f, 40.0f, 40.0f)];
    [backgroundView addSubview:locationImageView];
    
    UIImageView *descriptionImageView = [[UIImageView alloc] initWithImage:nil];
    [descriptionImageView setImage:[UIImage imageNamed:@"profileDescription.png"]];
    [descriptionImageView setFrame:CGRectMake( 15.0f, 169.0f, 40.0f, 40.0f)];
    [backgroundView addSubview:descriptionImageView];
    
    UIImageView *websiteImageView = [[UIImageView alloc] initWithImage:nil];
    [websiteImageView setImage:[UIImage imageNamed:@"profileWebsite.png"]];
    [websiteImageView setFrame:CGRectMake( 15.0f, 223.0f, 40.0f, 40.0f)];
    [backgroundView addSubview:websiteImageView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 54.0f, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = lineColor;
    [backgroundView addSubview:lineView];

    CGRect companyName_frame = CGRectMake( 80.0f, 68.0f, 205.0f, 25.0f);
    companyName = [[UITextField alloc] initWithFrame:companyName_frame];
    [companyName setBackgroundColor:backgroundColor];
    [companyName setFont:fonts];
    //companyName.borderStyle = UITextBorderStyleRoundedRect;
    companyName.placeholder = displayName_user;
    //[companyName setText:[self.appUserInfo objectForKey:@"companyName"]];
    companyName.userInteractionEnabled = YES;
    companyName.delegate = self;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [backgroundView addSubview:companyName];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 108.0f, self.view.bounds.size.width, 1)];
    lineView1.backgroundColor = lineColor;
    [backgroundView addSubview:lineView1];

    CGRect location_frame = CGRectMake( 80.0f, 122.0f, 205.0f, 25.0f);
    location = [[UITextField alloc] initWithFrame:location_frame];
    [location setBackgroundColor:backgroundColor];
    [location setFont:fonts];
    //location.borderStyle = UITextBorderStyleRoundedRect;
    location.placeholder = location_user;
    location.userInteractionEnabled = YES;
    location.delegate = self;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [location resignFirstResponder];
    [backgroundView addSubview:location];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 162.0f, self.view.bounds.size.width, 1)];
    lineView2.backgroundColor = lineColor;
    [backgroundView addSubview:lineView2];
    
    CGRect description_frame = CGRectMake( 80.0f, 176.0f, 205.0f, 25.0f);
    description = [[UITextField alloc] initWithFrame:description_frame];
    [description setBackgroundColor:backgroundColor];
    [description setFont:fonts];
    //description.borderStyle = UITextBorderStyleRoundedRect;
    description.placeholder = description_user;
    description.userInteractionEnabled = YES;
    description.delegate = self;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [description resignFirstResponder];
    [backgroundView addSubview:description];
    
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 216.0f, self.view.bounds.size.width, 1)];
    lineView3.backgroundColor = lineColor;
    [backgroundView addSubview:lineView3];
    
    CGRect website_frame = CGRectMake( 80.0f, 230.0f, 205.0f, 25.0f);
    website = [[UITextField alloc] initWithFrame:website_frame];
    [website setBackgroundColor:backgroundColor];
    [website setFont:fonts];
    //website.borderStyle = UITextBorderStyleRoundedRect;
    website.placeholder = website_user;
    website.userInteractionEnabled = YES;
    website.delegate = self;
    //companyName.keyboardAppearance = UIKeyboardAppearanceDefault;
    [website resignFirstResponder];
    [backgroundView addSubview:website];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
}


#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *smallRoundedImage = [image thumbnailImage:84.0f transparentBorder:0 cornerRadius:0.0f interpolationQuality:kCGInterpolationHigh];
    UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(200.0f, 200.0f) interpolationQuality:kCGInterpolationHigh];
    
    // Upload image
    imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
    imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);

    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        cameraButton.frame = CGRectMake( 110.0f, 87.0f, 100.0f, 100.0f );
        cameraButton.center = CGPointMake(160.0f, 137.0f);
    } else {
        cameraButton.frame = CGRectMake( 110.0f, 130.0f, 100.0f, 100.0f );
        cameraButton.center = CGPointMake(160.0f, 180.0f);
    }

    cameraButton.frame = CGRectIntegral(cameraButton.frame);
    [cameraButton setImage:resizedImage forState:UIControlStateNormal];
    //cameraButton.clipsToBounds = YES;
    [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [cameraButton addGestureRecognizer:swipeUpGestureRecognizer];

}

-(void)uploadImage_small:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
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
            user[@"profilePictureSmall"] = imageFile;
            
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

-(void)uploadImage_medium:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
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
            user[@"profilePictureMedium"] = imageFile;
            
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

- (void)photoCaptureButtonAction:(id)sender {
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
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
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
    NSString* website_input = [self.website.text lowercaseString];
    bool profileExist_user = self.user[@"profileExist"];
    
    if (profileExist_user == YES) {
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
        if ([dropDownSelection length] > 0) {
            self.user[@"userType"] = dropDownSelection;
        }
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        alert.tag = SUCCESSFUL;
        [alert show];
    } else {
        if ([companyName_input length] > 0 && [location_input length] > 0 && [dropDownSelection length] > 0) {
            
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
            
            self.user[@"displayName"] = companyName_input;
            self.user[@"description"] = description_input;
            self.user[@"website"] = website_input;
            self.user[@"userType"] = dropDownSelection;
            self.user[@"location"] = location_input;
            
            //Checking profile existence.
            bool profileExist = YES; // either YES or NO
            NSNumber *profileBoolNum = [NSNumber numberWithBool: profileExist];
            [[PFUser currentUser] setObject: profileBoolNum forKey: @"profileExist"];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            alert.tag = SUCCESSFUL;
            [alert show];

        } else {
            if ([companyName_input length] == 0) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter Display Name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
                
            } else if ([location_input length] == 0) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your Location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
            } else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please choose User Type." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
            }
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SUCCESSFUL) {
        if (buttonIndex == 0) {
            NSLog(@"Logged In Sucessfully");
            self.startOverlay = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            [[[[UIApplication sharedApplication] delegate] window] addSubview:self.startOverlay];
            
            UIImageView *startOverlay_image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            UIButton *proceed_button = [[UIButton alloc] init];
            
            if ([UIScreen mainScreen].bounds.size.height == 480) {
                [startOverlay_image setImage:[UIImage imageNamed:@"intro2-iphone4.png"]];
                [proceed_button setFrame:CGRectMake(35.0f, 416.0f, 250.0f, 43.0f)];
            } else {
                [startOverlay_image setImage:[UIImage imageNamed:@"intro2-iphone5.png"]];
                [proceed_button setFrame:CGRectMake(35.0f, 504.0f, 250.0f, 43.0f)];
            }
            
            [self.startOverlay addSubview:startOverlay_image];
            
            [proceed_button addTarget:self action:@selector(firstLoginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.startOverlay addSubview:proceed_button];
        }
    } else if (alertView.tag == IMAGE_NIL) {
        if (buttonIndex == 1) {
            [self performSelector:@selector(photoCaptureButtonAction:)];
        } else if (buttonIndex == 0) {
            NSString* companyName_input = self.companyName.text;
            NSString* location_input = self.location.text;
            NSString* description_input = self.description.text;
            NSString* website_input = [self.website.text lowercaseString];
            bool profileExist_user = self.user[@"profileExist"];
            
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
            if ([dropDownSelection length] > 0) {
                self.user[@"userType"] = dropDownSelection;
            }
            
            if (profileExist_user == NO) {
                UIImage *image = [UIImage imageNamed:@"default-pic.png"];
                
                UIImage *smallRoundedImage = [image thumbnailImage:84.0f transparentBorder:0 cornerRadius:0.0f interpolationQuality:kCGInterpolationHigh];
                UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(200.0f, 200.0f) interpolationQuality:kCGInterpolationHigh];
                
                // Upload image
                imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
                imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);
                
                [self uploadImage_small:imageData_picker_small];
                [self uploadImage_medium:imageData_picker];
            }
            
            bool profileExist = YES; // either YES or NO
            NSNumber *profileBoolNum = [NSNumber numberWithBool: profileExist];
            [[PFUser currentUser] setObject: profileBoolNum forKey: @"profileExist"];
            
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            alert.tag = SUCCESSFUL;
            [alert show];
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField: textField up: YES];
}

- (void) createdropDownButton:(NSString *) userType {
    dropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton setFrame:CGRectMake( 80.0f, 12.0f, 220.0f, 30.0f)];
    [dropDownButton setBackgroundImage:[UIImage imageNamed:@"dropdown_arrow.png"] forState:UIControlStateNormal];
    [dropDownButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [dropDownButton setTitle:userType forState:UIControlStateNormal];
    [dropDownButton setTitleColor:[UIColor colorWithWhite:200.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    dropDownButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];;
    [dropDownButton addTarget:self action:@selector(dropDownButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:dropDownButton];
}

- (void) dropDownButtonAction:(id) sender {
    NSLog(@"dropdown button pressed");
    UIFont *fonts = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    dropDownButton.enabled = NO;
    
    dropDownButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton1 setFrame:CGRectMake( 80.0f, 43.0f, 200.0f, 30.0f)];
    [dropDownButton1 setBackgroundImage:[UIImage imageNamed:@"bg_dropdown.png"] forState:UIControlStateNormal];
    [dropDownButton1 setTitle:@"Prospect" forState:UIControlStateNormal];
    //[dropDownButton1 setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton1 addTarget:self action:@selector(dropDownButtonPressedAction1:) forControlEvents:UIControlEventTouchUpInside];
    [dropDownButton1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    dropDownButton1.titleLabel.font = fonts;
    [dropDownButton1 setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
    [backgroundView addSubview:dropDownButton1];
    
    dropDownButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton2 setFrame:CGRectMake( 80.0f, 73.0f, 200.0f, 30.0f)];
    [dropDownButton2 setBackgroundImage:[UIImage imageNamed:@"bg_dropdown.png"] forState:UIControlStateNormal];
    [dropDownButton2 setTitle:@"Entrepreneur & Start Up" forState:UIControlStateNormal];
    //[dropDownButton2 setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton2 addTarget:self action:@selector(dropDownButtonPressedAction2:) forControlEvents:UIControlEventTouchUpInside];
    [dropDownButton2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    dropDownButton2.titleLabel.font = fonts;
    [dropDownButton2 setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
    [backgroundView addSubview:dropDownButton2];
    
    dropDownButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton3 setFrame:CGRectMake( 80.0f, 103.0f, 200.0f, 30.0f)];
    [dropDownButton3 setBackgroundImage:[UIImage imageNamed:@"bg_dropdown.png"] forState:UIControlStateNormal];
    [dropDownButton3 setTitle:@"Incubator" forState:UIControlStateNormal];
    //[dropDownButton3 setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [dropDownButton3 addTarget:self action:@selector(dropDownButtonPressedAction3:) forControlEvents:UIControlEventTouchUpInside];
    [dropDownButton3 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    dropDownButton3.titleLabel.font = fonts;
    [dropDownButton3 setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
    [backgroundView addSubview:dropDownButton3];
}

- (void) dropDownButtonPressedAction1:(id) sender {
    [dropDownButton1 removeFromSuperview];
    [dropDownButton2 removeFromSuperview];
    [dropDownButton3 removeFromSuperview];
    dropDownSelection = @"Prospect";
    [dropDownButton removeFromSuperview];

    [self createdropDownButton:(dropDownSelection)];
}

- (void) dropDownButtonPressedAction2:(id) sender {
    [dropDownButton1 removeFromSuperview];
    [dropDownButton2 removeFromSuperview];
    [dropDownButton3 removeFromSuperview];
    dropDownSelection = @"Entrepreneur & Start Up";
    [dropDownButton removeFromSuperview];

    
    
    [self createdropDownButton:(dropDownSelection)];
}

- (void) dropDownButtonPressedAction3:(id) sender {
    [dropDownButton1 removeFromSuperview];
    [dropDownButton2 removeFromSuperview];
    [dropDownButton3 removeFromSuperview];
    dropDownSelection = @"Incubator";
    [dropDownButton removeFromSuperview];

    
    
    [self createdropDownButton:(dropDownSelection)];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    float movementDuration = 0.2f; // tweak as needed
    
    if (textField == companyName) {
        movementDistance = 104; // tweak as needed
    }
    else if (textField == location) {
        movementDistance = 158; // tweak as needed
     }
    else if (textField == description) {
        movementDistance = 214; // tweak as needed
    }
    else if (textField == website) {
        movementDistance = 214; // tweak as needed
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
    [dropDownButton1 removeFromSuperview];
    [dropDownButton2 removeFromSuperview];
    [dropDownButton3 removeFromSuperview];
    [dropDownButton removeFromSuperview];
    
    if ([dropDownSelection length] > 0){
         [self createdropDownButton:(dropDownSelection)];
    } else {
         [self createdropDownButton:(@"Select User Type")];
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
    HUD = nil;
}

- (void) proceed_button_action:(id)sender {
    [self.startOverlay removeFromSuperview];
}

- (void) firstLoginButtonAction:(id)sender {
    [self.startOverlay removeFromSuperview];
    [website resignFirstResponder];
    [description resignFirstResponder];
    [location resignFirstResponder];
    [companyName resignFirstResponder];
    
    [PFUser user];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
    return;
}

@end

