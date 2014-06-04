//
//  PAPNotificationViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-06-03.
//
//

#import "PAPNotificationViewController.h"

@interface PAPNotificationViewController ()

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UITextField *notificationTextField;

@end

@implementation PAPNotificationViewController
@synthesize saveButton;
@synthesize notificationTextField;

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
    
    notificationTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 100.0f, 300.0f, 30.0f)];
    [notificationTextField setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:notificationTextField];
    
    saveButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 150.0f, 300.0f, 30.0f)];
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
    PFObject *notificiation = [PFObject objectWithClassName:@"Notification"];
    [notificiation setObject:notificationTextField.text forKey:@"Content"];
    
    [notificiation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error");
        } else {
            UILabel *successLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 200.0f, 320.f, 30.0f)];
            successLabel.text = @"Saved Successfully";
            [self.view addSubview:successLabel];
        }
    }];
}

@end
