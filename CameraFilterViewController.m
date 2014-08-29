//
//  CameraFilterViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 1/15/2014.
//
//

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#import "CameraFilterViewController.h"
#import "PAPEditPhotoViewController.h"
#import "FilterCell.h"
#import "Mixpanel.h"

@interface CameraFilterViewController ()

@property (nonatomic, assign) BOOL didCancel;
@property (nonatomic, strong) NSDictionary *filters;
@property (nonatomic, strong) NSDictionary *filterPreviewPics;
@property (nonatomic, strong) NSMutableDictionary *filteredImages;
@property (nonatomic, strong) NSArray *sortedFilterNames;
@property (nonatomic,strong) NSString *imageSource;
@property (nonatomic,strong) UIImage *croppedImage;
@property (nonatomic,strong) UIColor *selectedStateColor;
@property (nonatomic,strong) UIColor *defaultStateColor;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIImage *editableImage;
@property (nonatomic, strong) CALayer *selectedFilterBorder;
@property (nonatomic,strong) NSString *currentFilterName;

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
    
    // use custom layout because nib won't resize cells auto, set cell height depending on screen size (iphone 4/5)
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    int itemHeight = IS_WIDESCREEN ? 189 : 103;
    flowLayout.itemSize = CGSizeMake(91, itemHeight);
    self.filterList.collectionViewLayout = flowLayout;
 
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
    self.filters = [[NSDictionary alloc] initWithObjectsAndKeys: @"", @"Normal",@"CIPhotoEffectFade", @"The Valley",
                    @"CIPhotoEffectChrome", @"New York",@"CIPhotoEffectInstant", @"London", @"CIPhotoEffectMono",
                    @"Paris",@"CIPhotoEffectProcess", @"L.A", @"CIPhotoEffectTransfer",
                    @"Vancouver", @"CIPhotoEffectNoir", @"Toronto", nil];
    
    // filter preview images linked to standard name
    self.filterPreviewPics = [[NSDictionary alloc] initWithObjectsAndKeys: @"normal.png", @"Normal", @"valley.png", @"The Valley", @"newyork.png", @"New York",@"paris.png", @"Paris",@"london.png", @"London", @"la.png", @"L.A",@"toronto.png", @"Toronto", @"vancity.png", @"Vancouver", nil];

    
    // define order of appearance for filter names
    self.sortedFilterNames = [[NSArray alloc] initWithObjects: @"Normal", @"The Valley", @"Paris", @"New York", @"Vancouver", @"L.A", @"Toronto", nil];
    
    // select first cell (normal)
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.filterList selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.filterList didSelectItemAtIndexPath:indexPath];
    
    [self.croppedImageView setImage:self.croppedImage];
    
    // default filter
    self.currentFilterName = @"Normal";
}

-(void)viewWillAppear:(BOOL)animated{
    // analytics
    [PAPUtility captureScreenGA:@"Filter Photo"];
    
    [[Mixpanel sharedInstance] track:@"Viewed Filter Screen" properties:@{}];
}

#pragma mark - Custom

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
    
    self.currentFilterName = selectedFilter;
}

- (IBAction)saveEdit:(id)sender{
    
    // analytics
    [PAPUtility captureEventGA:@"Filter" action:self.currentFilterName label:nil];
    

    // Mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Selected filter" properties:@{
                                                  @"Filter": self.currentFilterName
                                                  }];
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
    
    // select proper filter
    FilterCell *cell =(FilterCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self selectFilter:cell.filter.text];
    [cell setState:@"selected"];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // de-select proper filter
    FilterCell *cell =(FilterCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [cell setState:@"default"];
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // de-select proper filter
    FilterCell *filterCell =(FilterCell *) cell;
    [filterCell setState:@"default"];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *filterName = [self.sortedFilterNames objectAtIndex:indexPath.row];
    
    // create custom filter cell
    FilterCell *cell = (FilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCell" forIndexPath:indexPath];
    
    // set name, preview image, and color based on state
    cell.filter.text = filterName;
    cell.placeholder.image = [UIImage imageNamed:[self.filterPreviewPics objectForKey:filterName]];
    cell.selected ? [cell setState:@"selected"] : [cell setState:@"default"];
    
    return cell;
}


@end
