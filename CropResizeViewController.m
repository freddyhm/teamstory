//
//  BFViewController.m
//  CropDemo
//
//  Created by John Nichols on 2/28/13.
//  Copyright (c) 2013 John Nichols. All rights reserved.
//

#import "CropResizeViewController.h"
#import "PAPTabBarController.h"
#import "CameraFilterViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "MBProgressHUD.h"

@interface CropResizeViewController ()

@property (nonatomic, assign) BOOL didCancel;
@property (nonatomic, retain) UIImage *croppedImg;
@property (nonatomic, readwrite, strong) UIView *overlayView;
@property (nonatomic,strong) NSString *imageSource;
@property (nonatomic, strong) UIImageView *displayImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIScrollView *moveImage;

@end

@implementation CropResizeViewController

- (id)initWithImage:(UIImage *)aImage nib:(NSString *)nibNameOrNil source:(NSString *)imgSource {
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.originalImage = aImage;
        self.imageSource = imgSource;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    if(self.didCancel){
        // if view disappearing because of cancel button
        [self.navigationController popViewControllerAnimated:NO];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // init nav bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    // set color of nav bar to custom grey
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(79/255.0) green:(91/255.0) blue:(100/255.0) alpha:(0.0/255.0)];
    
     self.navigationController.navigationBar.translucent = NO;

    
    self.navigationItem.title = @"Scale & Crop";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelEdit:)];
    
    self.navigationItem.RightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(cropPressed:)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    // set scrollview

    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGSize cropSize = CGSizeMake(screenSize.size.width - 40.0,
                                 screenSize.size.width - 40.0);
    
    self.moveImage = [[UIScrollView alloc] initWithFrame:
                      CGRectInset(self.view.bounds, (self.view.frame.size.width - cropSize.width) / 2,
                                  (self.view.frame.size.height - cropSize.height) / 2)];
    
    [self.moveImage setDelegate:self];
    [self.moveImage setAlwaysBounceVertical:YES];
    [self.moveImage setAlwaysBounceHorizontal:YES];
    [self.moveImage setShowsVerticalScrollIndicator:NO];
    [self.moveImage setShowsHorizontalScrollIndicator:NO];
    [self.moveImage.layer setMasksToBounds:NO];
    [self.moveImage setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin)];
    
    // set imageview
    
    self.displayImage = [[UIImageView alloc] initWithFrame:self.moveImage.bounds];
    [self.displayImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.displayImage setImage:self.originalImage];
    [self.displayImage sizeToFit];
    
    CGFloat zoomScale = 1.0;
    
    if (self.displayImage.frame.size.width < self.displayImage.frame.size.height) {
        zoomScale = (self.moveImage.frame.size.width / self.displayImage.frame.size.width);
    } else {
        zoomScale = (self.moveImage.frame.size.height / self.displayImage.frame.size.height);
    }
    
    [self.moveImage setContentSize:self.displayImage.frame.size];
    [self.moveImage setMinimumZoomScale:zoomScale];
    [self.moveImage setMaximumZoomScale:1.0];
    [self.moveImage setZoomScale:zoomScale];
    [self.moveImage setContentOffset:CGPointMake((self.displayImage.frame.size.width - self.moveImage.frame.size.width) / 2,
                                                  (self.displayImage.frame.size.height - self.moveImage.frame.size.height) / 2)];
    [self.moveImage addSubview:self.displayImage];
    [self.view addSubview:self.moveImage];
    
    // add box overlay
    
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.overlayView setUserInteractionEnabled:NO];
    [self.overlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight)];
    [self.view addSubview:self.overlayView];
    
    [self updateOverlay];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.displayImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cropPressed:(id)sender {
    
    // show spinning indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //resize cropped image and send to filter controller (work on background thread)
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // crop and resize image from scroll view
        self.croppedImg = [self processImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [MBProgressHUD hideHUDForView:self.view animated:YES];

            // add to filters
            CameraFilterViewController *filterController = [[CameraFilterViewController alloc]initWithImage:self.croppedImg nib:@"CameraFilterViewController" source:self.imageSource];
            
            // push filter controller to nav stack
            [self.navigationController pushViewController:filterController animated:YES];
        });
    });
}

- (IBAction)cancelEdit:(UIBarButtonItem *)sender {
    
    // get tab bar from root nav stack and return to camera
    PAPTabBarController *tabBarController = [[self.navigationController viewControllers] objectAtIndex:1];
    [tabBarController shouldPresentController:self.imageSource];
    
    // return to camera flag
    self.didCancel = YES;
}

- (void)updateOverlay {
    
    UIView *borderView = [[UIView alloc] initWithFrame:self.moveImage.frame];
    
    [borderView.layer setBorderColor:[[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor]];
    [borderView.layer setBorderWidth:1.0];
    [borderView setBackgroundColor:[UIColor clearColor]];
    [borderView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin)];
    
    [self.overlayView addSubview:borderView];
}

- (UIImage *)resizeImage:(UIImage *)image{
    
    // Create a graphics image context
    CGSize newSize = CGSizeMake(640, 640);
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* resizedImg = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    
    return resizedImg;
}


-(UIImage *)cropImage:(UIScrollView *)scrollView{
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, YES, scale);
    
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    
    [scrollView.layer renderInContext:graphicsContext];
    
    UIImage *finalImage = nil;
    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGRect targetFrame = CGRectMake(scrollView.contentOffset.x * scale,
                                    scrollView.contentOffset.y * scale,
                                    scrollView.frame.size.width * scale,
                                    scrollView.frame.size.height * scale);
    
    CGImageRef contextImage = CGImageCreateWithImageInRect([sourceImage CGImage], targetFrame);
    
    if (contextImage != NULL) {
        finalImage = [UIImage imageWithCGImage:contextImage
                                         scale:scale
                                   orientation:UIImageOrientationUp];
        
        CGImageRelease(contextImage);
    }
    
    UIGraphicsEndImageContext();
    
    return  finalImage;
}

- (UIImage *)processImage {
    
    // Cropping & resizing picture
    UIImage *resizedCroppedPic = [self resizeImage:[self cropImage:self.moveImage]];
    
    return resizedCroppedPic;
}



@end
