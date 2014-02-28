//
//  BFViewController.m
//  CropDemo
//
//  Created by John Nichols on 2/28/13.
//  Copyright (c) 2013 John Nichols. All rights reserved.
//

#import "BFViewController.h"
#import "PAPTabBarController.h"
#import "CameraFilterViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "MBProgressHUD.h"

@interface BFViewController ()

@property (nonatomic, assign) BOOL didCancel;
@property (nonatomic, retain) UIImage *croppedImg;

@end

@implementation BFViewController
@synthesize imageSource;

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
    
    //The following piece of code makes images fit inside the scrollview
    //by either their width or height, depending on which is smaller.
    //I.e, portrait images will fit horizontally in the scrollview,
    //allowing user to scroll vertically, while landscape images will fit vertically,
    //allowing user to scroll horizontally.
    CGFloat imageWidth = CGImageGetWidth(self.originalImage.CGImage);
    CGFloat imageHeight = CGImageGetHeight(self.originalImage.CGImage);
    
    int scrollWidth = self.moveImage.frame.size.width;
    int scrollHeight = self.moveImage.frame.size.height;
    
    //Limit by width or height, depending on which is smaller in relation to
    //the scrollview dimension.
    float scaleX = scrollWidth / imageWidth;
    float scaleY = scrollHeight / imageHeight;
    float scaleScroll =  (scaleX < scaleY ? scaleY : scaleX);
    
    self.moveImage.bounds = CGRectMake(0, 0,imageWidth , imageHeight );
    self.moveImage.frame = CGRectMake(0, 0, scrollWidth, scrollHeight);
    
    self.displayImage = [[UIImageView alloc] initWithImage: self.originalImage ];
    self.moveImage.delegate = self;
    
    self.moveImage.contentSize = self.originalImage.size;
    self.moveImage.pagingEnabled = NO;
    self.moveImage.maximumZoomScale = scaleScroll*3;
    self.moveImage.minimumZoomScale = scaleScroll;
    self.moveImage.zoomScale = scaleScroll;
    
    
    [self.moveImage addSubview:self.displayImage];
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
        
        
        CGRect selectedArea = [self calculateCropArea:self.moveImage];
        UIImage *croppedImage = [self cropImage:self.originalImage newRect:&selectedArea];
        [self resizeImage:croppedImage];
        
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

- (void)resizeImage:(UIImage *)image{
    
    //Resize cropped image
    
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
    
    self.croppedImg = resizedImg;
}

- (CGRect) calculateCropArea:(UIScrollView *)scrollView
{
    //Calculate the required area from the scrollview
    CGRect visibleRect;
    float scale = 1.0f/scrollView.zoomScale;
    visibleRect.origin.x = scrollView.contentOffset.x * scale;
    visibleRect.origin.y = (scrollView.contentOffset.y + 53) * scale;
    visibleRect.size.width = scrollView.bounds.size.width * scale;
    visibleRect.size.height = 307 * scale;
    
    return visibleRect;
}

- (UIImage *) cropImage:(UIImage*)srcImage newRect:(CGRect *)rect
{
    CGImageRef cr = CGImageCreateWithImageInRect([srcImage CGImage], *rect);
    UIImage* cropped = [[UIImage alloc] initWithCGImage:cr];
    CGImageRelease(cr);
    return cropped;
}



@end
