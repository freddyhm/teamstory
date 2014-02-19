//
//  discoverPageViewController.m
//  Anypic
//
//  Created by Tobok Lee on 1/10/14.
//
//

#import "discoverPageViewController.h"
#import "PAPperksView.h"
#import "PAPstartUpsView.h"
#import "PAPpeopleView.h"
#import "PAPdiscoveryHeaderView.h"


NSInteger selection = 1;

@interface discoverPageViewController()

@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) UIImageView *tabBarBackground;
@property (nonatomic, strong) UIButton *productButton;
@property (nonatomic, strong) UIButton *startUpsButton;
@property (nonatomic, strong) UIButton *peopleButton;
@property (nonatomic, strong) PAPperksView *perksView;
@property (nonatomic, strong) PAPpeopleView *peopleView;
@property (nonatomic, strong) PAPstartUpsView *startUpsView;
@property (nonatomic, strong) PAPdiscoveryHeaderView *discoveryHeaderView;



@end

@implementation discoverPageViewController

@synthesize tabBarController;
@synthesize tabBarBackground;
@synthesize productButton;
@synthesize startUpsButton;
@synthesize peopleButton;
@synthesize perksView;
@synthesize peopleView;
@synthesize startUpsView;
@synthesize discoveryHeaderView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DiscoverNavigationBar.png"]];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    discoveryHeaderView = [[PAPdiscoveryHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 100.0f)];
    [self.view addSubview:discoveryHeaderView];
    
    //tabBarBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 102.0f, self.view.bounds.size.width, 50.0f)];
    //[tabBarBackground setImage:[UIImage imageNamed:@"BackgroundTabBar.png"]];
    //[self.view addSubview:tabBarBackground];
    
    [self create_productButton];
    [self create_peopleButton];
    [self create_startUpsButton];
    
    [self displayPerksView];
    
}

- (void) displayPerksView {
    perksView = [[PAPperksView alloc] initWithFrame:CGRectMake(0.0f, 146.0f, self.view.bounds.size.width, self.view.bounds.size.height - 146.0f)];
    [self.view addSubview:perksView];
}

- (void) displaystartUpsView {
    startUpsView = [[PAPstartUpsView alloc] initWithFrame:CGRectMake(65.0f, 210.0f, self.view.bounds.size.width, self.view.bounds.size.height - 102.0f)];
    [self.view addSubview:startUpsView];
}

- (void) displaypeopleView {
    peopleView = [[PAPpeopleView alloc] initWithFrame:CGRectMake(65.0f, 210.0f, self.view.bounds.size.width, self.view.bounds.size.height - 102.0f)];
    [self.view addSubview:peopleView];
}

- (void) productButtonAction:(id) sender {
    NSLog(@"Tab Bar Button 1 Pressed");
    [productButton removeFromSuperview];
    [startUpsButton removeFromSuperview];
    [peopleButton removeFromSuperview];
    
    [startUpsView removeFromSuperview];
    [peopleView removeFromSuperview];
    
    selection = 1;

    [self create_productButton];
    [self create_startUpsButton];
    [self create_peopleButton];
    
    [self displayPerksView];
    
}

- (void) startUpsButtonAction:(id) sender {
    NSLog(@"Tab Bar Button 2 Pressed");
    [productButton removeFromSuperview];
    [startUpsButton removeFromSuperview];
    [peopleButton removeFromSuperview];
    
    [perksView removeFromSuperview];
    [peopleView removeFromSuperview];
    
    selection = 2;
    
    [self create_productButton];
    [self create_startUpsButton];
    [self create_peopleButton];
    
    [self displaystartUpsView];
}

- (void) peopleButtonAction:(id) sender {
    NSLog(@"Tab Bar Button 3 Pressed");
    [productButton removeFromSuperview];
    [startUpsButton removeFromSuperview];
    [peopleButton removeFromSuperview];
    
    [perksView removeFromSuperview];
    [startUpsView removeFromSuperview];
    
    selection = 3;
    
    [self create_productButton];
    [self create_startUpsButton];
    [self create_peopleButton];
    
    [self displaypeopleView];
}

- (void) create_productButton {
    productButton = [[UIButton alloc] initWithFrame:CGRectMake( 0.0f, 102.0f ,[UIScreen mainScreen].bounds.size.width / 3, 44.0f)];
    NSLog(@"%ld", (long)selection);
    
    if (selection == 1) {
        [productButton setImage:[UIImage imageNamed:@"tab-product-selected.png"] forState:UIControlStateDisabled];
        productButton.enabled = NO;
        startUpsButton.enabled = YES;
        peopleButton.enabled = YES;
    } else {
        [productButton setImage:[UIImage imageNamed:@"tab-product-unselected.png"] forState:UIControlStateNormal];
    }
    
    [productButton addTarget:self action:@selector(productButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:productButton];
        
}

- (void) create_startUpsButton {
    NSInteger imagewidth = [UIScreen mainScreen].bounds.size.width / 3;
    
    startUpsButton = [[UIButton alloc] initWithFrame:CGRectMake( imagewidth, 102.0f ,imagewidth, 44.0f)];
    
    if (selection == 2) {
        [startUpsButton setImage:[UIImage imageNamed:@"tab-startup-selected.png"] forState:UIControlStateDisabled];
        startUpsButton.enabled = NO;
        productButton.enabled = YES;
        peopleButton.enabled = YES;
    } else {
        [startUpsButton setImage:[UIImage imageNamed:@"tab-startup-unselected.png"] forState:UIControlStateNormal];
    }
    
    [startUpsButton addTarget:self action:@selector(startUpsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startUpsButton];
}

- (void) create_peopleButton {
    NSInteger imagewidth = [UIScreen mainScreen].bounds.size.width / 3;
    
    peopleButton = [[UIButton alloc] initWithFrame:CGRectMake( imagewidth * 2, 102.0f, [UIScreen mainScreen].bounds.size.width / 3, 44.0f)];

    if (selection == 3) {
        [peopleButton setImage:[UIImage imageNamed:@"tab-people-selected.png"] forState:UIControlStateDisabled];
        peopleButton.enabled = NO;
        startUpsButton.enabled = YES;
        productButton.enabled = YES;
    } else {
        [peopleButton setImage:[UIImage imageNamed:@"tab-people-unselected.png"] forState:UIControlStateNormal];
    }
    
    [peopleButton addTarget:self action:@selector(peopleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peopleButton];
}


@end
