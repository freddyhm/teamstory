//
//  PostPicViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-11-24.
//
//

#import "PostPicViewController.h"

@interface PostPicViewController ()

@end

@implementation PostPicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil originalImg:(UIImage *)originalImg bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.originalImg = originalImg;
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
   // self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    self.cropScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 400.0)];
    [self.cropScrollView setBackgroundColor:[UIColor blackColor]];
    [self.cropScrollView setDelegate:self];
    [self.cropScrollView setShowsHorizontalScrollIndicator:NO];
    [self.cropScrollView setShowsVerticalScrollIndicator:NO];
    [self.cropScrollView setMaximumZoomScale:2.0];
    
    self.cropImgView = [[UIImageView alloc] initWithImage:self.originalImg];
    [self.cropImgView setBackgroundColor:[UIColor redColor]];
    [self.cropImgView setFrame:CGRectMake(0.0, 0.0, self.originalImg.size.width, self.originalImg.size.height)];
    [self.cropScrollView setContentSize:self.originalImg.size];
    
    CGRect scrollViewFrame = self.cropScrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.cropScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.cropScrollView.contentSize.height;
    CGFloat minScale = MAX(scaleWidth,scaleHeight);
    
    [self.cropScrollView setMinimumZoomScale:minScale];
    [self.cropScrollView setMaximumZoomScale:2.0f];
    [self.cropScrollView setZoomScale:minScale];
    [self.cropScrollView addSubview:self.cropImgView];
    
    CGFloat newContentOffsetX = (self.cropScrollView.contentSize.width/2) - (self.cropScrollView.bounds.size.width/2);
    [self.cropScrollView setContentOffset:CGPointMake(newContentOffsetX, 0)];

    [self.view addSubview:self.cropScrollView];
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
