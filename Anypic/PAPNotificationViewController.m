//
//  PAPNotificationViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-06-03.
//
//

#import "PAPNotificationViewController.h"

@interface PAPNotificationViewController ()

@end

@implementation PAPNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UITextField *notificationTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 100.0f, 300.0f, 30.0f)];
    [notificationTextField setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:notificationTextField];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 150.0f, 300.0f, 30.0f)];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton.titleLabel setTextColor:[UIColor blackColor]];
    [saveButton setBackgroundColor:[UIColor grayColor]];
    [saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - ()

-(void)saveButtonAction:(id)sender {
    
}

@end
