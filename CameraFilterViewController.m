//
//  CameraFilterViewController.m
//  Anypic
//
//  Created by Freddy Hidalgo-Monchez on 1/15/2014.
//
//

#import "CameraFilterViewController.h"
#import "PAPEditPhotoViewController.h"
#import "PAPTabBarController.h"
#import "UIImage+ResizeAdditions.h"


@interface CameraFilterViewController ()

@property (nonatomic, assign) BOOL didCancel;
@property (nonatomic, strong) NSDictionary *filters;
@property (nonatomic, strong) NSMutableDictionary *filteredImages;

@end

@implementation CameraFilterViewController
@synthesize croppedImage;
@synthesize croppedImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated{
    
    if(self.didCancel){
        // if view disappearing because of cancel button
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    self.navigationItem.title = @"Edit";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelEdit:)];
    
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit:)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    
    self.didCancel = NO;
    
    [self.croppedImageView setImage:self.croppedImage];

    // init filters, orginal image, and filtered images
    self.filters = [[NSDictionary alloc] initWithObjectsAndKeys:
                         @"CIPhotoEffectChrome", @"Chrome", @"CIPhotoEffectFade",
                             @"Fade",@"CIPhotoEffectInstant", @"Instant", @"CIPhotoEffectMono",
                             @"Mono",@"CIPhotoEffectProcess", @"Process", @"CIPhotoEffectTransfer",
                             @"Transfer", nil]; //nil to signify end of objects and keys.
    
    // create corelmage type with image's core graphics
    CIImage *originalImage = [CIImage imageWithCGImage:[self.croppedImage CGImage]];
    self.filteredImages = [NSMutableDictionary new];
    
    // add filter
    for(NSString *filterName in self.filters) {
        
        // Filter the image
        CIFilter *filter = [CIFilter filterWithName:[self.filters objectForKey:filterName]];
        [filter setValue:originalImage forKey:kCIInputImageKey];
       
        // Create a CG-back UIImage
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
        UIImage *filteredImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        
        // add to our filtered list
        [self.filteredImages setObject:filteredImage forKey:filterName];
        
    }
}

- (IBAction)selectFilter:(id)sender{
    
    // get name of filter through button title, set selected image
    UIButton *button = (UIButton *)sender;
    NSString *selectedFilter = button.currentTitle;
    
    self.croppedImage = [self.filteredImages objectForKey:selectedFilter];
    
    [self.croppedImageView setImage:self.croppedImage];
}

- (IBAction)removeFilter:(id)sender{
    [croppedImageView setImage:self.croppedImage];
}

- (IBAction)saveEdit:(id)sender{
    
    PAPEditPhotoViewController *editController = [[PAPEditPhotoViewController alloc] initWithImage:self.croppedImage];
    [self.navigationController pushViewController:editController animated:YES];
}

- (IBAction)cancelEdit:(UIBarButtonItem *)sender {
    
    // get tab bar from root nav stack and return to camera
    PAPTabBarController *tabBarController = [[self.navigationController viewControllers] objectAtIndex:1];
    [tabBarController shouldPresentPhotoCaptureController];
    
    // return to camera flag
    self.didCancel = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
