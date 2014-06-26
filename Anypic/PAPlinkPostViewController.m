//
//  PAPlinkPostViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-06-25.
//
//

#import "PAPlinkPostViewController.h"

@interface PAPlinkPostViewController ()

@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIView *popUpBox;

@end

@implementation PAPlinkPostViewController

@synthesize dimView;
@synthesize popUpBox;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // init nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // set logo and nav bar buttons
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    self.dimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.dimView setBackgroundColor:[UIColor colorWithWhite:0.5f alpha:0.8f]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.dimView];
    
    self.popUpBox = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 75.0f, 280.0f, 200.0f)];
    [self.popUpBox setBackgroundColor:[UIColor whiteColor]];
    self.popUpBox.layer.cornerRadius = 8.0f;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.popUpBox];
    
    UIView *popUpBoxHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 50.0f)];
    [popUpBoxHeader setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0]];
    popUpBoxHeader.clipsToBounds = YES;

    // Creating layer to only initiate the top right and left round corners
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:popUpBoxHeader.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(8.0, 8.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = popUpBoxHeader.bounds;
    maskLayer.path = maskPath.CGPath;
    popUpBoxHeader.layer.mask = maskLayer;
    
    [self.popUpBox addSubview:popUpBoxHeader];
    
    
}


# pragma mark - ()
- (void)backButtonAction:(id)sender {
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
