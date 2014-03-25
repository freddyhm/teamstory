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
    
    UIView *mainView = [[UIView alloc] init];
    [mainView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    [self.view addSubview:mainView];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(65.0f, 30.0f, 190.0f, 65.0f)];
    [logoView setImage:[UIImage imageNamed:@"tutlogo.png"]];
    [self.view addSubview:logoView];
    
    UIImageView *picture = [[UIImageView alloc] init];
    [picture setImage:[UIImage imageNamed:@"tut1.png"]];
    [self.view addSubview:picture];
    
    UILabel *receivedLabel = [[UILabel alloc] init];
    [receivedLabel setText:@"Your application has been received!"];
    [receivedLabel setTextAlignment:NSTextAlignmentCenter];
    [receivedLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [receivedLabel setTextColor:[UIColor colorWithRed:79.0f/255.0f green:91.0f/255.0f blue:100.0f/255.0f alpha:1.0]];
    [self.view addSubview:receivedLabel];
    
    UILabel *additionalLabel = [[UILabel alloc] init];
    [additionalLabel setText:@"We will send you a notification soon!\nEvery application is manually reviewed."];
    additionalLabel.numberOfLines = 0;
    [additionalLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [additionalLabel setTextAlignment:NSTextAlignmentCenter];
    [additionalLabel setTextColor:[UIColor colorWithRed:169/255 green:173/255 blue:177/255 alpha:0.5f]];
    [self.view addSubview:additionalLabel];
    
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        mainView.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 150.0f, 320.0f, 200.0f);
        picture.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 410.0f, 320.0f, 260.0f);
        receivedLabel.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 130.0f, 320.0f, 50.0f);
        additionalLabel.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 90, 320.0f, 30.0f);
    } else {
        mainView.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 200.0f, 320.0f, 200.0f);
        picture.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 460.0f, 320.0f, 260.0f);
        receivedLabel.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 150.0f, 320.0f, 50.0f);
        additionalLabel.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 110, 320.0f, 30.0f);
    }

}

@end
