//
//  PAPprofileApprovalViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 3/19/14.
//
//

#import "PAPprofileApprovalViewController.h"

@interface PAPprofileApprovalViewController ()

@end

@implementation PAPprofileApprovalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro.png"]]];
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 200.0f, 320.0f, 200.0f)];
    [mainView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    [self.view addSubview:mainView];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(65.0f, 30.0f, 190.0f, 65.0f)];
    [logoView setImage:[UIImage imageNamed:@"tutlogo.png"]];
    [self.view addSubview:logoView];
    
    UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 460.0f, 320.0f, 260.0f)];
    [picture setImage:[UIImage imageNamed:@"tut1.png"]];
    [self.view addSubview:picture];
    
    UILabel *receivedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 180.0f, 320.0f, 200)];
    [receivedLabel setText:@"Your application has been received!"];
    [receivedLabel setTextAlignment:NSTextAlignmentCenter];
    [receivedLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [receivedLabel setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
    [self.view addSubview:receivedLabel];
    
    
}

@end
