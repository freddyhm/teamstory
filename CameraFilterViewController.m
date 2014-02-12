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


@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *currentButton;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIImage *editableImage;

- (IBAction)cancelEdit:(UIBarButtonItem *)sender;
- (IBAction)saveEdit:(id)sender;



@end

@implementation CameraFilterViewController

@synthesize context;
@synthesize editableImage;
@synthesize croppedImage;
@synthesize croppedImageView;
@synthesize imageSource;
@synthesize prevButton;
@synthesize currentButton;
@synthesize filterList;


- (id)initWithImage:(UIImage *)aImage nib:(NSString *)nibNameOrNil source:(NSString *)imgSource {
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.croppedImage = aImage;
        self.imageSource = imgSource;
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
    
    // collectionview cell setup for filters
    UINib *cellNib = [UINib nibWithNibName:@"FilterCell" bundle:nil];
    [self.filterList registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
        
    // needed for img manipulation (re-init context everytime slows filter selection down so stored as class variable instead)
    self.editableImage = [CIImage imageWithCGImage:[self.croppedImage CGImage]];
    
    // creates a context using GPU for faster processing
    EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
    self.context = [CIContext contextWithEAGLContext:myEAGLContext options:options];
    
    
    // init nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // set color of nav bar to custom grey
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(79/255.0) green:(91/255.0) blue:(100/255.0) alpha:(0.0/255.0)];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = @"Filters";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelEdit:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit:)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    // flag used to signal user exit
    self.didCancel = NO;
    
    // init filters, orginal image, and filtered images
    self.filters = [[NSDictionary alloc] initWithObjectsAndKeys: @"", @"Normal",
                    @"CIPhotoEffectChrome", @"Silicon Valley", @"CIPhotoEffectFade",
                    @"NYC",@"CIPhotoEffectInstant", @"London", @"CIPhotoEffectMono",
                    @"Paris",@"CIPhotoEffectProcess", @"LA", @"CIPhotoEffectTransfer",
                    @"Vancouver", @"CIPhotoEffectNoir", @"Toronto", @"CIPhotoEffectTonal", @"Waterloo", nil];
    
  [self.croppedImageView setImage:self.croppedImage];
}

- (IBAction)selectFilter:(id)sender{
    
    // get name of filter through button title, set selected image
    self.currentButton = (UIButton *)sender;
    NSString *selectedFilter = self.currentButton.currentTitle;
    
    // swap button colors for active/non-active
    
    //grey-ish
    [self.prevButton setTitleColor:[UIColor colorWithRed:(154/255.0) green:(154/255.0) blue:(154/255.0) alpha:1] forState:UIControlStateNormal];
    
    //aqua-ish
    [self.currentButton setTitleColor:[UIColor colorWithRed:(69/255.0) green:(204/255.0) blue:(197/255.0) alpha:1] forState:UIControlStateNormal];
    self.prevButton = self.currentButton;
    
    // treat original as removal of filter, set to initial image
    if([selectedFilter isEqualToString:@"Normal"]){
        [self.croppedImageView setImage:self.croppedImage];
    }else{
    
        // set filter and get output image
        CIFilter *filter = [CIFilter filterWithName:[self.filters objectForKey:selectedFilter]];
        [filter setValue:self.editableImage forKey:kCIInputImageKey];
        CIImage *outputImage = [filter outputImage];
        
        CGImageRef cgimg = [self.context createCGImage:outputImage
                                              fromRect:[outputImage extent]];
        
        UIImage *newImage = [UIImage imageWithCGImage:cgimg];
        
        [self.croppedImageView setImage:newImage];
        
        CGImageRelease(cgimg);
    }
}

- (IBAction)saveEdit:(id)sender{
    
    // send selected image to edit controller
    PAPEditPhotoViewController *editController = [[PAPEditPhotoViewController alloc] initWithImage:[self.croppedImageView image]];
    
    [self.navigationController pushViewController:editController animated:YES];
}

- (IBAction)cancelEdit:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Collection
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.filters count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // define order for filter names
    NSArray *sortedFilterNames = [[NSArray alloc] initWithObjects:@"Normal", @"Silicon Valley", @"NYC", @"London", @"Paris", @"Toronto", @"LA", @"Waterloo", @"Vancouver", nil];
    NSString *filterName = [sortedFilterNames objectAtIndex:indexPath.row];
   
    static NSString *cellIdentifier = @"cvCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // set filter button
    UIButton *filterBtn = (UIButton *)[cell viewWithTag:100];
    [filterBtn setTitle:filterName forState:UIControlStateNormal];
    [filterBtn addTarget:self action:@selector(selectFilter:) forControlEvents:UIControlEventTouchUpInside];
    filterBtn.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    
    return cell;
}


@end
