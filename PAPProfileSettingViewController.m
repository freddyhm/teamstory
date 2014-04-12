//
//  PAPProfileSettingViewController.m
//  TeamStory
//

#import "PAPProfileSettingViewController.h"
#import "PAPAccountViewController.h"
#import "AppDelegate.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPprofileApprovalViewController.h"
#import "SVProgressHUD.h"

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
@property (nonatomic, strong) NSString *location_user;
@property (nonatomic, strong) NSString *website_user;
@property (nonatomic, strong) NSString *displayName_user;
@property (nonatomic, strong) NSString *description_user;
@property (nonatomic, strong) NSString *email_user;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) PFImageView* profilePictureImageView;
@property (nonatomic, strong) PFFile *imageProfileFile;
@property (nonatomic, strong) UIButton *saveButton;


@end

@implementation PAPProfileSettingViewController
@synthesize companyName;
@synthesize location;
@synthesize description;
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




#pragma mark - Initialization

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    user = [PFUser currentUser];
    
    // creating another method to call later for the freshing purpose.
    [self refreshView];
}

- (void)refreshView {
    [self.navigationItem setHidesBackButton:YES];
    
    [SVProgressHUD show];
    
    NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
    bool profileExist = [profilExist_num boolValue];
    
    // Initialization
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *lineColor = [UIColor colorWithWhite:245.0f/255.0f alpha:1.0];
    UIFont *fonts = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    
    backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:backgroundColor];
    [self.view addSubview:backgroundView];
    
    UIButton *profileImagePicker = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro.png"]];
    
    [profileImagePicker setImage:[UIImage imageNamed:@"icon-upload.png"] forState:UIControlStateNormal];
    [profileImagePicker addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:profileImagePicker];
    
    [self.user refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if(!error){
            
            self.user = (PFUser *)object;
            
            location_user = self.user[@"location"];
            website_user = self.user[@"website"];
            displayName_user = self.user[@"displayName"];
            description_user = self.user[@"description"];
            email_user = self.user[@"email"];
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
                
                if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
                    profileImagePicker.frame = CGRectMake( 122.5f, 95.0f, 75.0f, 75.0f );
                    backgroundView.frame = CGRectMake(0.0f, self.view.bounds.size.height - 280.0f, self.view.bounds.size.width, 345.0f);
                    saveButton.frame = CGRectMake(35.0f, backgroundView.bounds.size.height - 60.0f, 250.0f, 45.0f);
                    profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 122.5f, 95.0f, 75.0f, 75.0f )];
                } else {
                    profileImagePicker.frame = CGRectMake( 122.5f, 135.0f, 75.0f, 75.0f );
                    backgroundView.frame = CGRectMake(0.0f, self.view.bounds.size.height - 280.0f, self.view.bounds.size.width, 370.0f);
                    saveButton.frame = CGRectMake(35.0f, backgroundView.bounds.size.height - 70.0f, 250.0f, 45.0f);
                    profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 122.5f, 135.0f, 75.0f, 75.0f )];
                }
                
            } else {
                
                saveButton = [[UIButton alloc] init];
                
                if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
                    profileImagePicker.frame = CGRectMake( 122.5f, 35.0f, 75.0f, 75.0f );
                    backgroundView.frame = CGRectMake(0.0f, self.view.bounds.size.height - 345.0f, self.view.bounds.size.width, 345.0f);
                    saveButton.frame = CGRectMake(35.0f, backgroundView.bounds.size.height - 60.0f, 250.0f, 45.0f);
                    profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 122.5f, 35.0f, 75.0f, 75.0f )];
                } else {
                    profileImagePicker.frame = CGRectMake( 122.5f, 85.0f, 75.0f, 75.0f );
                    backgroundView.frame = CGRectMake(0.0f, self.view.bounds.size.height - 370.0f, self.view.bounds.size.width, 370.0f);
                    saveButton.frame = CGRectMake(35.0f, backgroundView.bounds.size.height - 70.0f, 250.0f, 45.0f);
                    profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 122.5f, 85.0f, 75.0f, 75.0f )];
                    
                    UILabel *applyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, 320.0f, 45.0f)];
                    [applyLabel setTextColor:[UIColor whiteColor]];
                    [applyLabel setText:@"Apply for Teamstory"];
                    [applyLabel setTextAlignment:NSTextAlignmentCenter];
                    [applyLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]];
                    [self.view addSubview:applyLabel];
                }
            }
            
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
            

            
            /*
            UIImageView *companyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"companyName.png"]];
            [companyImageView setFrame:CGRectMake( 15.0f, 61.0f, 40.0f, 40.0f)];
            [backgroundView addSubview:companyImageView];
             */
            UIImageView *companyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"companyName.png"]];
            [companyImageView setFrame:CGRectMake( 15.0f, 7.0f, 40.0f, 40.0f)];
            [backgroundView addSubview:companyImageView];
            
            UIImageView *emailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-email.png"]];
            [emailImageView setFrame:CGRectMake( 15.0f, 61.0f, 40.0f, 40.0f)];
            [backgroundView addSubview:emailImageView];
            
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
            
            CGRect companyName_frame = CGRectMake( 80.0f, 14.0f, 205.0f, 25.0f);
            self.companyName = [[UITextField alloc] initWithFrame:companyName_frame];
            [self.companyName setBackgroundColor:backgroundColor];
            [self.companyName setFont:fonts];
            self.companyName.placeholder = displayName_user;
            self.companyName.userInteractionEnabled = YES;
            self.companyName.delegate = self;
            [backgroundView addSubview:self.companyName];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 54.0f, self.view.bounds.size.width, 1)];
            lineView.backgroundColor = lineColor;
            [backgroundView addSubview:lineView];

            CGRect email_address_frame = CGRectMake( 80.0f, 68.0f, 205.0f, 25.0f);
            self.email_address = [[UITextField alloc] initWithFrame:email_address_frame];
            [self.email_address setBackgroundColor:backgroundColor];
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
            [backgroundView addSubview:self.email_address];
            
            UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 108.0f, self.view.bounds.size.width, 1)];
            lineView1.backgroundColor = lineColor;
            [backgroundView addSubview:lineView1];

            CGRect location_frame = CGRectMake( 80.0f, 122.0f, 205.0f, 25.0f);
            self.location = [[UITextField alloc] initWithFrame:location_frame];
            [self.location setBackgroundColor:backgroundColor];
            [self.location setFont:fonts];
            self.location.placeholder = location_user;
            self.location.userInteractionEnabled = YES;
            self.location.delegate = self;
            [self.location resignFirstResponder];
            [backgroundView addSubview:self.location];
            
            UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 162.0f, self.view.bounds.size.width, 1)];
            lineView2.backgroundColor = lineColor;
            [backgroundView addSubview:lineView2];
            
            CGRect description_frame = CGRectMake( 80.0f, 176.0f, 205.0f, 25.0f);
            self.description = [[UITextField alloc] initWithFrame:description_frame];
            [self.description setBackgroundColor:backgroundColor];
            [self.description setFont:fonts];
            self.description.placeholder = description_user;
            self.description.userInteractionEnabled = YES;
            self.description.delegate = self;
            [self.description resignFirstResponder];
            [backgroundView addSubview:self.description];
            
            UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 216.0f, self.view.bounds.size.width, 1)];
            lineView3.backgroundColor = lineColor;
            [backgroundView addSubview:lineView3];
            
            CGRect website_frame = CGRectMake( 80.0f, 230.0f, 205.0f, 25.0f);
            self.website = [[UITextField alloc] initWithFrame:website_frame];
            [self.website setBackgroundColor:backgroundColor];
            [self.website setFont:fonts];
            self.website.placeholder = website_user;
            self.website.userInteractionEnabled = YES;
            self.website.delegate = self;
            self.website.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [self.website resignFirstResponder];
            [backgroundView addSubview:self.website];
            
            UIView *lineView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 270.0f, self.view.bounds.size.width, 1)];
            lineView4.backgroundColor = lineColor;
            [backgroundView addSubview:lineView4];
            
            UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(dismissKeyboard)];
            
            [self.view addGestureRecognizer:tapOutside];
            
            [SVProgressHUD dismiss];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Profile fetch failed. Check your network connection and try again" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.profilePictureImageView removeFromSuperview];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *smallRoundedImage = [image thumbnailImage:84.0f transparentBorder:0 cornerRadius:0.0f interpolationQuality:kCGInterpolationHigh];
    UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(200.0f, 200.0f) interpolationQuality:kCGInterpolationHigh];
    
    // Upload image
    imageData_picker = UIImageJPEGRepresentation(resizedImage, 1);
    imageData_picker_small = UIImagePNGRepresentation(smallRoundedImage);

    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
    bool profileExist_user = [profilExist_num boolValue];
    
    if (!profileExist_user) {
        if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
            cameraButton.frame = CGRectMake( 122.5f, 35.0f, 75.0f, 75.0f );
            cameraButton.center = CGPointMake(160.0f, 73.0f);
        } else {
            cameraButton.frame = CGRectMake( 122.5f, 85.0f, 75.0f, 75.0f );
            cameraButton.center = CGPointMake(160.0f, 123.0f);
        }
    } else {
        if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
            cameraButton.frame = CGRectMake( 122.5f, 35.0f, 75.0f, 75.0f );
            cameraButton.center = CGPointMake(160.0f, 132.0f);
        } else {
            cameraButton.frame = CGRectMake( 122.5f, 85.0f, 75.0f, 75.0f );
            cameraButton.center = CGPointMake(160.0f, 172.0f);
        }
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
    
    [SVProgressHUD show];
    
    user = [PFUser currentUser];
    user[@"profilePictureSmall"] = imageFile;
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"uploadImage_small: %@ %@", error, [error userInfo]);
        }
        [SVProgressHUD dismiss];
    }];
}

-(void)uploadImage_medium:(NSData *)imageData {
    PFFile *imageFile = [PFFile fileWithName:nil data:imageData];
    
    [SVProgressHUD show];
    user = [PFUser currentUser];
    user[@"profilePictureMedium"] = imageFile;
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"uploadImage_medium: %@ %@", error, [error userInfo]);
        } else {
            NSLog(@"successful");
        }
        [SVProgressHUD dismiss];
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
    if (textField == self.companyName) {
        [self.companyName resignFirstResponder];
    }
    else if (textField == self.location) {
        [self.location resignFirstResponder];
    }
    else if (textField == self.description) {
        [self.description resignFirstResponder];
    }
    else if (textField == self.website) {
        [self.website resignFirstResponder];
    }
    else if (textField == self.email_address) {
        [self.email_address resignFirstResponder];
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
    NSString* email_input = self.email_address.text;
    NSString* email_current_input = self.user[@"email"];
    NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
    bool profileExist_user = [profilExist_num boolValue];
    
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
        if (([email_input length] > 0 && [self NSStringIsValidEmail:email_input]) || email_current_input) {
            self.user[@"email"] = email_input;
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your email input is not valid." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
            return;
        }
        
        [[PFUser currentUser] saveInBackground];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        alert.tag = SUCCESSFUL;
        [alert show];
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
            [membershipReceived saveInBackground];
            [[PFUser currentUser] saveInBackground];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your Information has been saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = SUCCESSFUL;
            alert.alertViewStyle = UIAlertViewStyleDefault;
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
            } else if ([email_input length] == 0 || !self.user[@"email"] || ![self NSStringIsValidEmail:email_input]){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your Email input is not valid." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
            [self.view endEditing:YES];
            
            NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
            bool profileExist_user = [profilExist_num boolValue];
            
            if (profileExist_user != true) {
                //Checking profile existence.
                bool profileExist = YES; // either YES or NO
                NSNumber *profileBoolNum = [NSNumber numberWithBool: profileExist];
                [[PFUser currentUser] setObject: profileBoolNum forKey: @"profileExist"];
                [[PFUser currentUser] saveInBackground];
                
                PAPprofileApprovalViewController *approvalViewController = [[PAPprofileApprovalViewController alloc] init];
                [self.navigationController pushViewController:approvalViewController animated:YES];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } else if (alertView.tag == IMAGE_NIL) {
        if (buttonIndex == 1) {
            [self.view endEditing:YES];
            NSLog(@"image_nil tag");
            
            [self photo_picker_init];
            
        } else if (buttonIndex == 0) {
            NSString* companyName_input = self.companyName.text;
            NSString* location_input = self.location.text;
            NSString* description_input = self.description.text;
            NSString* website_input = [self.website.text lowercaseString];
            NSString* email_input = self.email_address.text;
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
            if ([email_input length] > 0 ) {
                self.user[@"email"] = email_input;
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
                
                PFObject *membershipReceived = [PFObject objectWithClassName:kPAPActivityClassKey];
                [membershipReceived setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                [membershipReceived setObject:@"membership" forKey:@"type"];
                
                PFACL *membershipACL = [PFACL ACL];
                [membershipACL setPublicReadAccess:YES];
                membershipReceived.ACL = membershipACL;
                
                // make sure our join activity is always earlier than a follow
                [membershipReceived saveInBackground];
            }
            
            [[PFUser currentUser] saveInBackground];
            
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


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField: textField up: NO];
    
    if (textField == companyName) {
        [SVProgressHUD showWithStatus:@"Validating User Name"];
        [self textfieldUserInteractionControl:NO];
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"displayName" equalTo:textField.text];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            [SVProgressHUD dismiss];
            
            [self textfieldUserInteractionControl:YES];
            
            if (!error) {
                if (number > 0 || [textField.text length] == 0) {
                    companyName.text = @"";
                    [companyName becomeFirstResponder];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Display name is already in use. Please choose another name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                }
            } else {
                NSLog(@"%@", error);
            }
            
        }];
    } else if (textField == email_address) {
        [SVProgressHUD showWithStatus:@"Validating Email"];
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"email" equalTo:email_address.text];
        [userQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            [SVProgressHUD dismiss];
            
            if (!error) {
                if (number > 0) {
                    email_address.text = @"";
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The email address is already in use. Please use another email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    [alert show];
                }
            } else {
                NSLog(@"%@", error);
            }
        }];
        
    }
    
}

- (void) textfieldUserInteractionControl:(BOOL) enable {
    [location setUserInteractionEnabled:enable];
    [description setUserInteractionEnabled:enable];
    [website setUserInteractionEnabled:enable];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    [SVProgressHUD dismiss];
    float movementDuration = 0.1f; // tweak as needed
    
    if (textField == companyName) {
        movementDistance = 50; // tweak as needed
    }
    else if (textField == email_address) {
        movementDistance = 104; // tweak as needed
    }
    else if (textField == location) {
        movementDistance = 158; // tweak as needed
     }
    else if (textField == description) {
        movementDistance = 214; // tweak as needed
    }
    else if (textField == self.website) {
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

@end

