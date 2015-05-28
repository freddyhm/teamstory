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
#import "PAPLoginSelectionViewController.h"
#import "PAPMessageListViewController.h"

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
@property (nonatomic, strong) UIView *photoPostView;
@property (nonatomic, strong) UIView *thoughtPostView;
@property (nonatomic, strong) UIView *linkPostView;

@end

@implementation PAPTabBarController
@synthesize navController;
@synthesize camera;
@synthesize imagePickerInfo;
@synthesize imageSource;
@synthesize popoverController;
@synthesize linkPostButton;

#pragma mark - UIViewController

- (void)viewDidLayoutSubviews
{
    // fix for iOS7 bug in UITabBarController
    self.selectedViewController.view.superview.frame = self.view.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"BackgroundTabBar.png"]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    self.navController = [[UINavigationController alloc] init];
    
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float offsetImage = 30.0f;
    float offsetLabel = 15.0f;
    UIFont *labelFonts = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
    
    UIImage *postButtonImage = [UIImage imageNamed:@"btn_new_post.png"];
    
    self.postMenuButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80.0f, screenHeight - 125.0f, postButtonImage.size.width, postButtonImage.size.height)];
    [self.postMenuButton setBackgroundImage:postButtonImage forState:UIControlStateNormal];
    [self.postMenuButton setBackgroundImage:[UIImage imageNamed:@"btn_new_post_tap.png"] forState:UIControlStateHighlighted];
    [self.postMenuButton setBackgroundImage:[UIImage imageNamed:@"btn_post_close.png"] forState:UIControlStateSelected];
    [self.postMenuButton addTarget:self action:@selector(postMenuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.postMenuButton];
    
    // create post menu
    self.postMenu = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.postMenu.backgroundColor = [UIColor colorWithRed:54.0f/255.0f green:54.0f/255.0f blue:56.0f/255.0f alpha:0.9f];

    UIImage *photoPostImage = [UIImage imageNamed:@"Moment Popup.png"];
    
    self.photoPostView = [[UIView alloc] initWithFrame:CGRectMake(35.0f, screenHeight / 2 - offsetImage, photoPostImage.size.width, photoPostImage.size.height + offsetLabel)];
    [self.postMenu addSubview:self.photoPostView];
    // photo button

    self.photoPostButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, photoPostImage.size.width, photoPostImage.size.height)];
    [self.photoPostButton setBackgroundImage:photoPostImage forState:UIControlStateNormal];
    [self.photoPostButton setBackgroundImage:[UIImage imageNamed:@"Moment Popup_selected.png"] forState:UIControlStateSelected];
    [self.photoPostButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.photoPostView addSubview:self.photoPostButton];
    
    UILabel *photoPostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, photoPostImage.size.height, photoPostImage.size.width, offsetLabel)];
    [photoPostLabel setText:@"Moment"];
    [photoPostLabel setTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]];
    [photoPostLabel setFont:labelFonts];
    photoPostLabel.textAlignment = NSTextAlignmentCenter;
    [self.photoPostView addSubview:photoPostLabel];
    
    // thought button
    UIImage *thoughtPostImage = [UIImage imageNamed:@"Thought Popup.png"];
    self.thoughtPostView = [[UIView alloc] initWithFrame:CGRectMake(120.0f, screenHeight / 2 - offsetImage, thoughtPostImage.size.width, thoughtPostImage.size.height + offsetLabel)];
    [self.postMenu addSubview:self.thoughtPostView];
    
    self.thoughtPostButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, thoughtPostImage.size.width, thoughtPostImage.size.height)];
    [self.thoughtPostButton setBackgroundImage:thoughtPostImage forState:UIControlStateNormal];
    [self.thoughtPostButton setBackgroundImage:[UIImage imageNamed:@"Thought Popup_selected.png"] forState:UIControlStateSelected];
    [self.thoughtPostButton addTarget:self action:@selector(thoughtButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.thoughtPostView addSubview:self.thoughtPostButton];
    
    UILabel *thoughtPostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, thoughtPostImage.size.height, thoughtPostImage.size.width, offsetLabel)];
    [thoughtPostLabel setText:@"Thought"];
    [thoughtPostLabel setTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]];
    [thoughtPostLabel setFont:labelFonts];
    thoughtPostLabel.textAlignment = NSTextAlignmentCenter;
    [self.thoughtPostView addSubview:thoughtPostLabel];
    
    // link post button
    
    UIImage *linkPostImage = [UIImage imageNamed:@"Link Popup.png"];
    
    self.linkPostView = [[UIView alloc] initWithFrame:CGRectMake(205.0f, screenHeight / 2 - offsetImage, linkPostImage.size.width, linkPostImage.size.height + offsetLabel)];
    [self.postMenu addSubview:self.linkPostView];
    
    self.linkPostButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, linkPostImage.size.width, linkPostImage.size.height)];
    [self.linkPostButton setBackgroundImage:linkPostImage forState:UIControlStateNormal];
    [self.linkPostButton setBackgroundImage:[UIImage imageNamed:@"Link Popup_selected.png"] forState:UIControlStateSelected];
    [self.linkPostButton addTarget:self action:@selector(linkPostButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.linkPostView addSubview:self.linkPostButton];
    
    UILabel *linkPostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, linkPostImage.size.height, linkPostImage.size.width, offsetLabel)];
    [linkPostLabel setText:@"Link"];
    [linkPostLabel setTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]];
    [linkPostLabel setFont:labelFonts];
    linkPostLabel.textAlignment = NSTextAlignmentCenter;
    [self.linkPostView addSubview:linkPostLabel];
    
    // hide by default
    self.postMenu.hidden = YES;
    
    // Handle outside tap gesture.
    UITapGestureRecognizer *postMenuOutside = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postMenuOutsideAction:)];
    
    [self.postMenu addGestureRecognizer:postMenuOutside];
    [self.postMenu setUserInteractionEnabled:YES];
    [self.view addSubview:self.postMenu];
    [self.view bringSubviewToFront:self.postMenuButton];
}


-(void)postMenuButtonAction:(id)sender {
    self.postMenu.hidden = self.postMenu.hidden ? NO : YES;
    
    if (self.postMenuButton.selected == NO) {
        [self.postMenuButton setBackgroundImage:[UIImage imageNamed:@"btn_post_close_tap.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
        self.postMenuButton.selected = YES;
    } else {
        [self.postMenuButton setBackgroundImage:[UIImage imageNamed:@"btn_new_post_tap.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
        self.postMenuButton.selected = NO;
    }
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    /*
    self.messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.messageButton setImage:[UIImage imageNamed:@"nav_chat.png"] forState:UIControlStateNormal];
    [self.messageButton setImage:[UIImage imageNamed:@"nav_chat_selected.png"] forState:UIControlStateSelected];
    self.messageButton.frame = CGRectMake( (self.tabBar.bounds.size.width / 5) * 2, 0.0f, 63.0f, 50.0f);
    
    [self.messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:self.messageButton];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [self.messageButton addGestureRecognizer:swipeUpGestureRecognizer];
     */
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
    self.postMenuButton.selected = self.postMenuButton.selected ? NO : YES;
    self.postMenu.hidden = self.postMenu.hidden ? NO : YES;
}

- (void)messageButtonAction:(id)sender {
    // new analytics
    //[[Mixpanel sharedInstance] track:@"Viewed Post Menu" properties:@{}];
    
    PAPMessageListViewController *messageListViewController = [[PAPMessageListViewController alloc] init];
    [self.navigationController pushViewController:messageListViewController animated:YES];

    //[[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
}

- (void)cameraButtonAction:(id)sender{
    // If the user is logged in with an anonymous account, show login page.
    [self navigateToLoginPage];
    
    // new analytics
    [[Mixpanel sharedInstance] track:@"Viewed Post Menu" properties:@{@"Selected": @"Camera"}];
    
    self.postMenuButton.selected = self.postMenuButton.selected ? NO : YES;
    
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
    // If the user is logged in with an anonymous account, show login page.
    [self navigateToLoginPage];
    
    // new analytics
    [[Mixpanel sharedInstance] track:@"Viewed Post Menu" properties:@{@"Selected": @"Link"}];
    
    self.postMenu.hidden = YES;
    self.postMenuButton.selected = self.postMenuButton.selected ? NO : YES;
    
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
    // If the user is logged in with an anonymous account, show login page.
    [self navigateToLoginPage];
    
    // new analytics
    [[Mixpanel sharedInstance] track:@"Viewed Post Menu" properties:@{@"Selected": @"Thought"}];
    
    self.postMenuButton.selected = self.postMenuButton.selected ? NO : YES;
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

- (void) navigateToLoginPage {
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        PAPLoginSelectionViewController *loginSelectionViewController = [[PAPLoginSelectionViewController alloc] initWithNibName:@"PAPLoginSelectionViewController" bundle:nil];
        [self.view.window.rootViewController presentViewController:loginSelectionViewController animated:YES completion:nil];
        return;
    }
}

@end
