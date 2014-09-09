//
//  PAPMessagingViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-09-08.
//
//

#import "PAPMessagingViewController.h"

@interface PAPMessagingViewController ()

@property (nonatomic, strong) UITableView *messageList;

@end

@implementation PAPMessagingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tabBarController.tabBar.hidden = YES;
    
    //float tabBarHeight = 30.0f;
    float topSpace = 64.0f;
    
    self.messageList = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, topSpace, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - topSpace)];
    [self.view addSubview:self.messageList];
    
    
}

# pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
