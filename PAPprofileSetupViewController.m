//
//  PAPprofileSetupViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 7/31/14.
//
//

#import "PAPprofileSetupViewController.h"

@interface PAPprofileSetupViewController ()

@end

@implementation PAPprofileSetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIScrollView *mainSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, [UIScreen mainScreen].bounds.size.height)];
    mainSV.contentSize = CGSizeMake(960.0f, 0.0f);
    [self.view addSubview:mainSV];
    
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 960.0f, 60.0f)];
    navBar.backgroundColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];;
    [mainSV addSubview:navBar];
}

@end
