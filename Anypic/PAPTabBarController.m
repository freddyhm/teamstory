//
//  PAPTabBarController.m
//  Teamstory
//
//

#import "PAPTabBarController.h"
#import "MBProgressHUD.h"
#import "ThoughtPostViewController.h"
#import "PAPlinkPostViewController.h"
#import "PostPicViewController.h"
#import "SVProgressHUD.h"
#import "Mixpanel.h"

@interface PAPTabBarController ()
@property (nonatomic,strong) NSString *imageSource;
@property (nonatomic,strong) UINavigationController *navController;
@property (nonatomic,strong) UIImagePickerController *camera;
@property (assign) NSUInteger cameraRollIndex;
@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;
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


@end

@implementation PAPTabBarController
@synthesize navController;
@synthesize camera;
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
    
    self.navController = [[UINavigationController alloc] init];
    
    // create post menu
    self.postMenu = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    // photo button
    UIImage *photoPostImage = [UIImage imageNamed:@"Moment Popup.png"];
    self.photoPostButton = [[UIButton alloc] initWithFrame:CGRectMake(40.0f, screenHeight - 130.0f, photoPostImage.size.width, photoPostImage.size.height)];
    [self.photoPostButton setBackgroundImage:photoPostImage forState:UIControlStateNormal];
    [self.photoPostButton setBackgroundImage:[UIImage imageNamed:@"Moment Popup_selected.png"] forState:UIControlStateSelected];
    [self.photoPostButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.postMenu addSubview:self.photoPostButton];
    
    // thought button
    UIImage *thoughtPostImage = [UIImage imageNamed:@"Thought Popup.png"];
    self.thoughtPostButton = [[UIButton alloc] initWithFrame:CGRectMake(125.0f, screenHeight - 130.0f, thoughtPostImage.size.width, thoughtPostImage.size.height)];
    [self.thoughtPostButton setBackgroundImage:thoughtPostImage forState:UIControlStateNormal];
    [self.thoughtPostButton setBackgroundImage:[UIImage imageNamed:@"Thought Popup_selected.png"] forState:UIControlStateSelected];
    [self.thoughtPostButton addTarget:self action:@selector(thoughtButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.postMenu addSubview:self.thoughtPostButton];
    
    // link post button
    
    UIImage *linkPostImage = [UIImage imageNamed:@"Link Popup.png"];
    self.linkPostButton = [[UIButton alloc] initWithFrame:CGRectMake(210.0f, screenHeight - 130.0f, linkPostImage.size.width, linkPostImage.size.height)];
    [self.linkPostButton setBackgroundImage:linkPostImage forState:UIControlStateNormal];
    [self.linkPostButton setBackgroundImage:[UIImage imageNamed:@"Link Popup_selected.png"] forState:UIControlStateSelected];
    [self.linkPostButton addTarget:self action:@selector(linkPostButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.postMenu addSubview:self.linkPostButton];
    
    // hide by default
    self.postMenu.hidden = YES;
    
    // Handle outside tap gesture.
    UITapGestureRecognizer *postMenuOutside = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postMenuOutsideAction:)];
    
    [self.postMenu addGestureRecognizer:postMenuOutside];
    [self.postMenu setUserInteractionEnabled:YES];
    [self.view addSubview:self.postMenu];
}



#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.postButton setImage:[UIImage imageNamed:@"nav_post.png"] forState:UIControlStateNormal];
    [self.postButton setImage:[UIImage imageNamed:@"btn_close_timeline.png"] forState:UIControlStateSelected];
    self.postButton.frame = CGRectMake( (self.tabBar.bounds.size.width / 5) * 2, 0.0f, 63.0f, 50.0f);
    self.postButton.backgroundColor = [UIColor colorWithRed:88.0f/255.0f green:186.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
    
    [self.postButton addTarget:self action:@selector(postButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:self.postButton];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [self.postButton addGestureRecognizer:swipeUpGestureRecognizer];
}


#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *selectedImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.imageSource = @"Camera";
    
    [self sendPicToCrop:selectedImg];
}


#pragma mark - ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    UIImage *selectedImg = [[info objectAtIndex:0] objectForKey:UIImagePickerControllerOriginalImage];
    
    self.imageSource = @"Album";
    
    [self sendPicToCrop:selectedImg];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ()

- (void)postMenuOutsideAction:(id)sender {
    self.postButton.selected = self.postButton.selected ? NO : YES;
    self.postMenu.hidden = self.postMenu.hidden ? NO : YES;
}

- (void)postButtonAction:(id)sender {
    
    // analytics
    [PAPUtility captureEventGA:@"Testing" action:@"Pressed Post" label:nil];
    
    // new analytics
    [[Mixpanel sharedInstance] track:@"Viewed Post Menu" properties:@{}];
    
    self.postButton.selected = self.postButton.selected ? NO : YES;
    
    // hide/show post menu toggle
    self.postMenu.hidden = self.postMenu.hidden ? NO : YES;
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
}

- (void)cameraButtonAction:(id)sender{
    
    // analytics
    [PAPUtility captureEventGA:@"Testing" action:@"Pressed Camera" label:nil];
    
    // new analytics
    [[Mixpanel sharedInstance] track:@"Viewed Post Menu" properties:@{@"Selected": @"Camera"}];
    
    postButton.selected = self.postButton.selected ? NO : YES;
    
    self.postMenu.hidden = YES;
    
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


- (void)linkPostButtonAction:(id)sender {
    
    // analytics
    [PAPUtility captureEventGA:@"Testing" action:@"Pressed Link" label:nil];
    
    // new analytics
    [[Mixpanel sharedInstance] track:@"Viewed Post Menu" properties:@{@"Selected": @"Link"}];
    
    self.postMenu.hidden = YES;
    postButton.selected = self.postButton.selected ? NO : YES;
    
    PAPlinkPostViewController *linkPostViewController = [[PAPlinkPostViewController alloc] init];
    [self.navigationController pushViewController:linkPostViewController animated:YES];
}

- (void)displayPickerForGroup:(ALAssetsGroup *)group
{
    ELCAssetTablePicker *tablePicker = [[ELCAssetTablePicker alloc] initWithStyle:UITableViewStylePlain];
    
    // set title with arrow
    NSString *albumName = [group valueForProperty:ALAssetsGroupPropertyName];
    [tablePicker setButtonTitle:albumName];
    
    tablePicker.singleSelection = YES;
    tablePicker.immediateReturn = NO;
    
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:tablePicker];
    elcPicker.maximumImagesCount = 1;
    elcPicker.imagePickerDelegate = self;
    elcPicker.defaultImagePickerDelegate = self;
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    tablePicker.parent = elcPicker;
    
    // Move me
    tablePicker.assetGroup = group;
    
    [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    
    [self presentViewController:elcPicker animated:YES completion:nil];
    
}

- (void)thoughtButtonAction:(id)sender{
    
    // analytics
    [PAPUtility captureEventGA:@"Testing" action:@"Pressed Thought" label:nil];
    
    // new analytics
    [[Mixpanel sharedInstance] track:@"Viewed Post Menu" properties:@{@"Selected": @"Thought"}];
    
    postButton.selected = self.postButton.selected ? NO : YES;
    self.postMenu.hidden = YES;
    
    ThoughtPostViewController *thoughtPostViewController = [[ThoughtPostViewController alloc] init];
    thoughtPostViewController.delegate = self;
    
    // nav controller here serves to display nav bar easily
    UINavigationController *thoughtNavController = [[UINavigationController alloc]initWithRootViewController:thoughtPostViewController];
    
    [self.navigationController presentViewController:thoughtNavController animated:YES completion:nil];
}

-(void)didUploadThought{
    
    // move to home view controller
    [self setSelectedIndex:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIImagePickerController *)shouldStartCameraController {
    
    // analytics
    [PAPUtility captureEventGA:@"Camera & Album" action:@"Picked Camera" label:@"Photo"];

    [[Mixpanel sharedInstance] track:@"Took Camera Picture" properties:@{}];
        
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




- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    //   [self shouldPresentPhotoCaptureController];
}

#pragma mark - Custom

- (void)sendPicToCrop:(UIImage *)image{
    
    // Fix rotation
    UIImage *fixedImg = [self fixrotation:image];
    
    PostPicViewController *postPicController = [[PostPicViewController alloc]initWithImage:fixedImg source:self.imageSource];
    [self.navigationController pushViewController:postPicController animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)backToPhotoAlbum{
    
    // triggered when in selected picture in picker
    [self.navController popViewControllerAnimated:YES];
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
