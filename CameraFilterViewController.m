//
//  CameraFilterViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 1/15/2014.
//
//

#import "CameraFilterViewController.h"
#import "PAPEditPhotoViewController.h"
#import "FilterCell.h"

@interface CameraFilterViewController ()

@property (nonatomic, assign) BOOL didCancel;
@property (nonatomic, strong) NSDictionary *filters;
@property (nonatomic, strong) NSMutableDictionary *filteredImages;
@property (nonatomic, strong) NSArray *sortedFilterNames;
@property (nonatomic,strong) NSString *imageSource;
@property (nonatomic,strong) UIImage *croppedImage;
@property (nonatomic,strong) UIColor *selectedStateColor;
@property (nonatomic,strong) UIColor *defaultStateColor;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIImage *editableImage;

- (IBAction)cancelEdit:(UIBarButtonItem *)sender;
- (IBAction)saveEdit:(id)sender;

@end

@implementation CameraFilterViewController



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
    [self.filterList registerClass:[FilterCell class] forCellWithReuseIdentifier:@"FilterCell"];
    self.filterList.delegate = self;
    
    
    
    //custom colors
    self.selectedStateColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    self.defaultStateColor = [UIColor colorWithRed:(154/255.0) green:(154/255.0) blue:(154/255.0) alpha:1];
        
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
    
    // filter system names and their custom names
    self.filters = [[NSDictionary alloc] initWithObjectsAndKeys: @"", @"Normal",
                    @"CIPhotoEffectChrome", @"Silicon Valley", @"CIPhotoEffectFade",
                    @"New York",@"CIPhotoEffectInstant", @"London", @"CIPhotoEffectMono",
                    @"Paris",@"CIPhotoEffectProcess", @"Los Angeles", @"CIPhotoEffectTransfer",
                    @"Vancouver", @"CIPhotoEffectNoir", @"Toronto", @"CIPhotoEffectTonal", @"Waterloo", nil];
    
    
    // define order of appearance for filter names
    self.sortedFilterNames = [[NSArray alloc] initWithObjects: @"Normal", @"London", @"Paris", @"New York", @"Los Angeles", @"Vancouver", @"Toronto", @"Waterloo", @"Silicon Valley", nil];
    
  [self.croppedImageView setImage:self.croppedImage];
}

- (IBAction)selectFilter:(NSString *)selectedFilter{
    
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
    return [self.sortedFilterNames count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FilterCell *selectedCell =(FilterCell *)[collectionView cellForItemAtIndexPath:indexPath];
    selectedCell.filter.textColor = self.selectedStateColor;
    [self selectFilter:selectedCell.filter.text];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FilterCell *selectedCell =(FilterCell *) [collectionView cellForItemAtIndexPath:indexPath];
    selectedCell.filter.textColor = self.defaultStateColor;
    [self selectFilter:selectedCell.filter.text];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *filterName = [self.sortedFilterNames objectAtIndex:indexPath.row];
    
    // create custom filter cell
    FilterCell *cell = (FilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCell" forIndexPath:indexPath];
    
    // set name and color based on state
    cell.filter.text = filterName;
    cell.filter.textColor = cell.selected ? self.selectedStateColor : self.defaultStateColor;

    return cell;
}


@end
