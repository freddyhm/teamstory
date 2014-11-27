//
//  PostPicViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-11-24.
//
//

#import "PostPicViewController.h"
#import "PAPUtility.h"
#import "SVProgressHUD.h"
#import "PAPEditPhotoViewController.h"
#import "PAPTabBarController.h"
#import "PAPHomeViewController.h"

@interface PostPicViewController ()

@property (nonatomic, strong) UIScrollView *cropScrollView;
@property (nonatomic, strong) UIImageView *cropImgView;
@property (nonatomic, strong) UIImage *originalImg;
@property (nonatomic, strong) UIImage *croppedImg;
@property (nonatomic, strong) UIBarButtonItem *rightNavButton;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

@implementation PostPicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil originalImg:(UIImage *)originalImg bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        if (!originalImg) {
            return nil;
        }
        
        self.originalImg = originalImg;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // set logo and nav bar buttons
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    // set color of nav bar to custom grey
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(79/255.0) green:(91/255.0) blue:(100/255.0) alpha:(0.0/255.0)];
    
    self.rightNavButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(cropPressed)];
    self.rightNavButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.rightNavButton;
    
    // scrollview set up
    self.cropScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 400.0)];
    [self.cropScrollView setDelegate:self];
    [self.cropScrollView setShowsHorizontalScrollIndicator:NO];
    [self.cropScrollView setShowsVerticalScrollIndicator:NO];
    [self.cropScrollView setMaximumZoomScale:2.0];
    
    // image view set up
    self.cropImgView = [[UIImageView alloc] initWithImage:self.originalImg];
    [self.cropImgView setBackgroundColor:[UIColor redColor]];
    [self.cropImgView setFrame:CGRectMake(0.0, 0.0, self.originalImg.size.width, self.originalImg.size.height)];
    [self.cropScrollView setContentSize:self.originalImg.size];
    
    // calculate minimum zoom for selected image
    CGRect scrollViewFrame = self.cropScrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.cropScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.cropScrollView.contentSize.height;
    CGFloat minScale = MAX(scaleWidth,scaleHeight);
    
    // set imageview and add to scrollview
    [self.cropScrollView setMinimumZoomScale:minScale];
    [self.cropScrollView setZoomScale:minScale];
    [self.cropScrollView addSubview:self.cropImgView];
    
    // center image by manipulting scrollview's offset
    CGFloat newContentOffsetX = (self.cropScrollView.contentSize.width/2) - (self.cropScrollView.bounds.size.width/2);
    [self.cropScrollView setContentOffset:CGPointMake(newContentOffsetX, 0)];

    [self.view addSubview:self.cropScrollView];
}

- (void)backButtonAction{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)cropImage:(UIImage *)aImage {
    float zoomScale = 1.0 / [self.cropScrollView zoomScale];
    
    CGRect rect;
    rect.origin.x = [self.cropScrollView contentOffset].x * zoomScale;
    rect.origin.y = [self.cropScrollView contentOffset].y * zoomScale;
    rect.size.width = [self.cropScrollView bounds].size.width * zoomScale;
    rect.size.height = [self.cropScrollView bounds].size.height * zoomScale;
    
    CGImageRef cr = CGImageCreateWithImageInRect([[self.cropImgView image] CGImage], rect);
    
    UIImage *cropped = [UIImage imageWithCGImage:cr];
    
    CGImageRelease(cr);
    
    return cropped;
}

- (UIImage *)processImage:(UIImage *)aImage {
    
    // Cropping & resizing picture
    UIImage *resizedCroppedPic = [PAPUtility resizeImage:[self cropImage:aImage] width:640 height:640];
    
    return resizedCroppedPic;
}

- (void)cropPressed {
    
    //[self shouldUploadImage:self.croppedImg];
    
    // show spinning indicator
    [SVProgressHUD show];
    //resize cropped image and send to filter controller (work on background thread)
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // crop and resize image from scroll view
        self.croppedImg = [self processImage:self.croppedImg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self startUploadProcess:self.croppedImg];
        });
    });
}

- (void)startUploadProcess:(UIImage *)anImage {
    
    UIImage *thumbnailImage = [PAPUtility resizeImage:anImage width:86.0f height:86.0f];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %d for Teamstory photo upload", (int)self.fileUploadBackgroundTaskId);
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Thumbnail uploaded successfully");
                    
                    [self uploadFinishedImage:anImage];
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
}

- (void)uploadFinishedImage:(UIImage *)anImage {

    if (!self.photoFile || !self.thumbnailFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    // both files have finished uploading
    
    // create a photo object
    PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
    [photo setObject:@"picture" forKey:kPAPPhotoType];
    [photo setObject:[NSNumber numberWithInt:0] forKey:@"discoverCount"];
    

    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // save
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded");
            
            [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
        } else {
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo :( Check your internet connection or contact us at info@teamstoryapp.com" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        
        [SVProgressHUD dismiss];
        [self exitPhoto];
    }];
}

- (void)exitPhoto{
    
    // set color of nav bar back to teal
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    
    // hide custom grey bar and pop to home
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // get tab bar and home controller from stack
    PAPTabBarController *tabBarController =[[self.navigationController viewControllers] objectAtIndex:1];
    NSArray *tabBarViewControllers = [tabBarController viewControllers];
    
    // get home and phototimeline, if there are children pop 'em to get back to timeline
    PAPHomeViewController *homeViewController = [tabBarViewControllers objectAtIndex:0];
    PhotoTimelineViewController *photoViewController = [homeViewController.childViewControllers objectAtIndex:0];
    
    if([homeViewController.childViewControllers count] > 1){
        [photoViewController.navigationController popViewControllerAnimated:NO];
    }
    
    [tabBarController setSelectedViewController:homeViewController];
    
    // push tab bar with home controller now selected
    [self.navigationController popToViewController:tabBarController animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.cropImgView;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
