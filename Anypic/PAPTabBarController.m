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

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"BackgroundTabBar.png"]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    //[[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"BackgroundTabBarItemSelected.png"]];
    
    self.navController = [[UINavigationController alloc] init];
   
    
    // create post menu
    self.postMenu = [[UIView alloc]initWithFrame:CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y - self.tabBar.frame.size.height - 25, self.tabBar.frame.size.width, self.tabBar.frame.size.height + 25)];
        
    // photo button
    UIImage *bubbleLeft = [UIImage imageNamed:@"bubble_left.png"];
    self.photoPostButton = [[UIButton alloc] initWithFrame:CGRectMake(self.tabBar.frame.origin.x, 9.0f, bubbleLeft.size.width, bubbleLeft.size.height)];
    [self.photoPostButton setBackgroundImage:bubbleLeft forState:UIControlStateNormal];
    [self.photoPostButton setBackgroundImage:[UIImage imageNamed:@"bubble_left_selected.png"] forState:UIControlStateSelected];
    [self.photoPostButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // photo title
    self.photoPostTitle = [[UILabel alloc] initWithFrame:CGRectMake(56.0f, 26.5f, 110.0, 10)];
    //self.photoPostTitle.backgroundColor= [UIColor grayColor];
    self.photoPostTitle.text = @"Share Moment";
    self.photoPostTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
    self.photoPostTitle.textColor = [UIColor whiteColor];
   
    // photo icon
    self.photoPostButtonIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"post_camera.png"]];
    self.photoPostButtonIcon.frame = CGRectMake(20.0f, 21.0f, self.photoPostButtonIcon.frame.size.width, self.photoPostButtonIcon.frame.size.height);
    
    // add to proper views
    [self.photoPostButton addSubview:self.photoPostTitle];
    [self.photoPostButton addSubview:self.photoPostButtonIcon];
    [self.postMenu addSubview:self.photoPostButton];
    
    // thought button
    UIImage *bubbleRight = [UIImage imageNamed:@"bubble_right.png"];
    self.thoughtPostButton = [[UIButton alloc] initWithFrame:CGRectMake(self.tabBar.frame.size.width/2, 9.0f, bubbleRight.size.width, bubbleRight.size.height)];
    [self.thoughtPostButton setBackgroundImage:[UIImage imageNamed:@"bubble_right.png"] forState:UIControlStateNormal];
    [self.thoughtPostButton setBackgroundImage:[UIImage imageNamed:@"bubble_right_selected.png"] forState:UIControlStateSelected];
    [self.thoughtPostButton addTarget:self action:@selector(thoughtButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // thought title
    self.thoughtPostTitle = [[UILabel alloc] initWithFrame:CGRectMake(44.0f, 23.0f, 110.0, 15.0f)];
    //self.photoPostTitle.backgroundColor= [UIColor grayColor];
    self.thoughtPostTitle.text = @"Share Thought";
    self.thoughtPostTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
    self.thoughtPostTitle.textColor = [UIColor whiteColor];
    
    // thought icon
    self.thoughtPostButtonIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"post_thought.png"]];
    self.thoughtPostButtonIcon.frame = CGRectMake(12.0f, 21.0f, self.thoughtPostButtonIcon.frame.size.width, self.thoughtPostButtonIcon.frame.size.height);
    
    // add to proper views
    [self.thoughtPostButton addSubview:self.thoughtPostTitle];
    [self.thoughtPostButton addSubview:self.thoughtPostButtonIcon];
    [self.postMenu addSubview:self.thoughtPostButton];
    
    // hide by default
    self.postMenu.hidden = YES;
    
    [self.view addSubview:self.postMenu];
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setImage:[UIImage imageNamed:@"nav_post.png"] forState:UIControlStateNormal];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self sendPicToCrop:selectedImg];
}


#pragma mark - ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    UIImage *selectedImg = [[info objectAtIndex:0] objectForKey:UIImagePickerControllerOriginalImage];
    [self sendPicToCrop:selectedImg];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - ()

- (void)postButtonAction:(id)sender {
    
    // hide/show post menu toggle
    self.postMenu.hidden = self.postMenu.hidden ? NO : YES;
}

- (void)cameraButtonAction:(id)sender{
    
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
    
    self.postMenu.hidden = YES;
    
    ThoughtPostViewController *thoughtPostViewController = [[ThoughtPostViewController alloc]init];
    [self.navigationController pushViewController:thoughtPostViewController animated:YES];
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
        return NO;
    }
    
    self.camera.allowsEditing = NO;
    self.camera.showsCameraControls = YES;
    self.camera.delegate = self;

    return self.camera;
}




- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
 //   [self shouldPresentPhotoCaptureController];
}

#pragma mark - Custom

- (void)sendPicToCrop:(UIImage *)image{
    
    // Fix rotation
    UIImage *fixedImg = [self fixrotation:image];
    
    CropResizeViewController *cropViewController = [[CropResizeViewController alloc] initWithImage:fixedImg nib:nil source:self.imageSource];
    
    [self.navigationController pushViewController:cropViewController animated:NO];
    
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
