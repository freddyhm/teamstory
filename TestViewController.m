//
//  TestViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-11-07.
//
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBarController.tabBar.frame = CGRectZero;
    
    self.customKeyboard = [[CustomKeyboardViewController alloc] initWithNibName:@"CustomKeyboardViewController" bundle:nil];
    self.customKeyboard.delegate = self;
    [self.view addSubview:self.customKeyboard.view];
    [self.view bringSubviewToFront:self.customKeyboard.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendButtonAction:(id)sender{
    
}

- (void)setTableViewHeight{
    
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
