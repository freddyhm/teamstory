//
//  PAPfirstPicViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/26/15.
//
//

#import "PAPfirstPicViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface PAPfirstPicViewController ()

@property (nonatomic,strong) UIImagePickerController *camera;
@property (assign) NSUInteger cameraRollIndex;
@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;
@property (nonatomic,strong) NSDictionary *imagePickerInfo;
@property (nonatomic,strong) NSString *imageSource;
@property (nonatomic, strong) UINavigationController *navController;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end

@implementation PAPfirstPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navController = [[UINavigationController alloc] init];
    
    self.mainScrollView.delegate = self;
    self.mainScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 600);
}
- (IBAction)momentButtonAction:(id)sender {
    // init asset library
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    self.specialLibrary = library;
    
    NSMutableArray *groups = [NSMutableArray array];
    
    // keep track of camera roll index
    self.cameraRollIndex = 0;
    
    // fetch all albums and set first pop up to camera roll
    [self.specialLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
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

- (IBAction)thoughtButtonAction:(id)sender {
    ThoughtPostViewController *thoughtPostViewController = [[ThoughtPostViewController alloc] init];
    thoughtPostViewController.delegate = self;
    
    // nav controller here serves to display nav bar easily
    UINavigationController *thoughtNavController = [[UINavigationController alloc]initWithRootViewController:thoughtPostViewController];
    
    [self presentViewController:thoughtNavController animated:YES completion:nil];
    
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

#pragma mark - Custom

- (void)sendPicToCrop:(UIImage *)image{
    [self dismissViewControllerAnimated:NO completion:^{
        // Fix rotation
        UIImage *fixedImg = [self fixrotation:image];
        
        PostPicViewController *postPicController = [[PostPicViewController alloc] initWithImage:fixedImg source:self.imageSource];
        UINavigationController *postNavController = [[UINavigationController alloc]initWithRootViewController:postPicController];
        
        [self presentViewController:postNavController animated:YES completion:^{
            postPicController.firstPicViewController = YES;
        }];
    }];
}

-(void)backToPhotoAlbum{
    // triggered when in selected picture in picker
    [self.navController popViewControllerAnimated:YES];
    
}
- (IBAction)skipButtonAction:(id)sender {
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
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

-(void)didUploadThought{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
