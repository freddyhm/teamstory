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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // set logo and nav bar buttons
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
   // self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.cropScrollView setBackgroundColor:[UIColor blackColor]];
    [self.cropScrollView setDelegate:self];
    [self.cropScrollView setShowsHorizontalScrollIndicator:NO];
    [self.cropScrollView setShowsVerticalScrollIndicator:NO];
    [self.cropScrollView setMaximumZoomScale:2.0];
    
    [self.cropImgView setImage:self.originalImg];
        
    [self.cropScrollView setContentSize:[self.cropImgView frame].size];
    [self.cropScrollView setMinimumZoomScale:[self.cropScrollView frame].size.width / [self.cropImgView frame].size.width];
    [self.cropScrollView setZoomScale:[self.cropScrollView minimumZoomScale]];
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
