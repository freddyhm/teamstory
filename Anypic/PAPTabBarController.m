//
//  PAPTabBarController.m
//  Teamstory
//
//

#import "PAPTabBarController.h"
#import  "CameraFilterViewController.h"
#import "MBProgressHUD.h"
#import "CropResizeViewController.h"
#import "ThoughtPostViewController.h"
#import "PAPlinkPostViewController.h"

@interface PAPTabBarController ()
@property (nonatomic,strong) NSString *imageSource;
@property (nonatomic,strong) UINavigationController *navController;
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic,strong) NSDictionary *imagePickerInfo;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIImageView *postMenuBkgd;

@property (nonatomic, strong) UIButton *photoPostButton;
@property (nonatomic, strong) UIButton *thoughtPostButton;
@property (nonatomic, strong) UIButton *linkPostButton;
@property (nonatomic, strong) UIImageView *photoPostButtonIcon;
@property (nonatomic, strong) UIImageView *thoughtPostButtonIcon;
@property (nonatomic, strong) UILabel *photoPostTitle;
@property (nonatomic, strong) UILabel *thoughtPostTitle;

@property (nonatomic, strong) UIButton *postButton;

@end

@implementation PAPTabBarController
@synthesize navController;
@synthesize imagePicker;
@synthesize imagePickerInfo;
@synthesize imageSource;
@synthesize popoverController;
@synthesize linkPostButton;
@synthesize postButton;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"BackgroundTabBar.png"]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    //[[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"BackgroundTabBarItemSelected.png"]];
    
    self.navController = [[UINavigationController alloc] init];
   
    
    // create post menu
    self.postMenu = [[UIView alloc]initWithFrame:CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y - self.tabBar.frame.size.height - 35, self.tabBar.frame.size.width, self.tabBar.frame.size.height + 25)];
        
    // photo button
    UIImage *photoPostImage = [UIImage imageNamed:@"Moment Popup.png"];
    self.photoPostButton = [[UIButton alloc] initWithFrame:CGRectMake(40.0f, 0.0f, photoPostImage.size.width, photoPostImage.size.height)];
    [self.photoPostButton setBackgroundImage:photoPostImage forState:UIControlStateNormal];
    [self.photoPostButton setBackgroundImage:[UIImage imageNamed:@"Moment Popup_selected.png"] forState:UIControlStateSelected];
    [self.photoPostButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.postMenu addSubview:self.photoPostButton];
    
    // thought button
    UIImage *thoughtPostImage = [UIImage imageNamed:@"Thought Popup.png"];
    self.thoughtPostButton = [[UIButton alloc] initWithFrame:CGRectMake(125.0f, 0.0f, thoughtPostImage.size.width, thoughtPostImage.size.height)];
    [self.thoughtPostButton setBackgroundImage:thoughtPostImage forState:UIControlStateNormal];
    [self.thoughtPostButton setBackgroundImage:[UIImage imageNamed:@"Thought Popup_selected.png"] forState:UIControlStateSelected];
    [self.thoughtPostButton addTarget:self action:@selector(thoughtButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.postMenu addSubview:self.thoughtPostButton];
    
    // link post button
    
    UIImage *linkPostImage = [UIImage imageNamed:@"Link Popup.png"];
    self.linkPostButton = [[UIButton alloc] initWithFrame:CGRectMake(210.0f, 0.0f, linkPostImage.size.width, linkPostImage.size.height)];
    [self.linkPostButton setBackgroundImage:linkPostImage forState:UIControlStateNormal];
    [self.linkPostButton setBackgroundImage:[UIImage imageNamed:@"Link Popup_selected.png"] forState:UIControlStateSelected];
    [self.linkPostButton addTarget:self action:@selector(linkPostButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.postMenu addSubview:self.linkPostButton];
    
    // hide by default
    self.postMenu.hidden = YES;
    
    [self.view addSubview:self.postMenu];
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setImage:[UIImage imageNamed:@"nav_post.png"] forState:UIControlStateNormal];
    [postButton setImage:[UIImage imageNamed:@"btn_close_timeline.png"] forState:UIControlStateSelected];
    postButton.frame = CGRectMake( (self.tabBar.bounds.size.width / 5) * 2, 0.0f, 63.0f, 50.0f);
    postButton.backgroundColor = [UIColor colorWithRed:88.0f/255.0f green:186.0f/255.0f blue:159.0f/255.0f alpha:1.0f];

    [postButton addTarget:self action:@selector(postButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:postButton];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [postButton addGestureRecognizer:swipeUpGestureRecognizer];
}


#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // hide nav bar when exiting picker
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.imageSource = self.imageSource != nil ? self.imageSource : @"Album";
    
    // Check if pic is in correct position, fix rotation if not (pic from camera roll)
    UIImage *selectedImg = [self fixrotation:[info objectForKey:UIImagePickerControllerOriginalImage]];
    
    CropResizeViewController *cropViewController = [[CropResizeViewController alloc] initWithImage:selectedImg nib:nil source:self.imageSource];
    
    [self.navigationController pushViewController:cropViewController animated:NO];
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.imageSource = @"Camera";
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        self.imageSource = @"Album";
        [self shouldStartPhotoLibraryPickerController];
    }
}

#pragma mark - UINavigationControllerDelegate


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // keep status bar white, in ios7 changes in imagepicker
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // set nav controller to picker's nav controller so we can access it in backToPhotoAlbum
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

#pragma mark - PAPTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

#pragma mark - ()

- (void)postButtonAction:(id)sender {
    postButton.selected = self.postButton.selected ? NO : YES;
    
    // hide/show post menu toggle
    self.postMenu.hidden = self.postMenu.hidden ? NO : YES;
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
}

- (void)cameraButtonAction:(id)sender{
    postButton.selected = self.postButton.selected ? NO : YES;
    self.postMenu.hidden = YES;
    
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        [actionSheet showFromTabBar:self.tabBar];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

- (void)linkPostButtonAction:(id)sender {
    self.postMenu.hidden = YES;
    postButton.selected = self.postButton.selected ? NO : YES;
    
    PAPlinkPostViewController *linkPostViewController = [[PAPlinkPostViewController alloc] init];
    [self.navigationController pushViewController:linkPostViewController animated:YES];
}

- (void)thoughtButtonAction:(id)sender{
    postButton.selected = self.postButton.selected ? NO : YES;
    self.postMenu.hidden = YES;
    
    ThoughtPostViewController *thoughtPostViewController = [[ThoughtPostViewController alloc] init];
    [self.navigationController pushViewController:thoughtPostViewController animated:YES];
}

- (BOOL)shouldStartCameraController {
      
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        self.imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    self.imagePicker.allowsEditing = NO;
    self.imagePicker.showsCameraControls = YES;
    self.imagePicker.delegate = self;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
    return YES;
}


- (BOOL)shouldStartPhotoLibraryPickerController {
    
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    self.imagePicker.allowsEditing = NO;
    self.imagePicker.delegate = self;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
    return YES;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self shouldPresentPhotoCaptureController];
}

#pragma mark - Custom
-(void)backToPhotoAlbum{
    
    // triggered when in selected picture in picker
    [self.navController popViewControllerAnimated:YES];
}

-(void)shouldPresentController:(NSString *)typeController{
    
    if ([typeController isEqualToString:@"Camera"]) {
        [self shouldStartCameraController];
    } else if ([typeController isEqualToString:@"Album"]) {
        [self shouldStartPhotoLibraryPickerController];
    }
}

- (UIImage *)fixrotation:(UIImage *)image{
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr…
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}



@end
