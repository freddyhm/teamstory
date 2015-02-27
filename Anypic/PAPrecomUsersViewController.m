//
//  PAPrecomUsersViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/26/15.
//
//

#import "PAPrecomUsersViewController.h"
#import "PAPdiscoverTileView.h"

@interface PAPrecomUsersViewController ()
@property (strong, nonatomic) IBOutlet UIView *navBar;

@end

@implementation PAPrecomUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PAPdiscoverTileView *discoverTileView = [[PAPdiscoverTileView alloc] initWithFrame:CGRectMake(0, self.navBar.frame.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:discoverTileView];
    
}

@end
