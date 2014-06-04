//
//  PAPNotificationViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-06-03.
//
//

#import "PAPNotificationViewController.h"
#import "SVProgressHUD.h"

@interface PAPNotificationViewController ()

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UITextField *notificationTextField;
@property (nonatomic, strong) UITextField *photoIdTextField;

@end

@implementation PAPNotificationViewController
@synthesize saveButton;
@synthesize notificationTextField;
@synthesize photoIdTextField;

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
    notificationTextField.placeholder = @"Content";
    [self.view addSubview:notificationTextField];
    
    photoIdTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 150.0f, 300.0f, 30.0f)];
    [photoIdTextField setBackgroundColor:[UIColor orangeColor]];
    photoIdTextField.placeholder = @"PhotoId";
    [self.view addSubview:photoIdTextField];
    
    saveButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 200.0f, 300.0f, 30.0f)];
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
    [SVProgressHUD show];
    
    PFObject *notificiation = [PFObject objectWithClassName:@"Notification"];
    [notificiation setObject:notificationTextField.text forKey:@"Content"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"objectId" equalTo:photoIdTextField.text];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [notificiation setObject:object forKey:@"Photo"];
            [notificiation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [SVProgressHUD dismiss];
                if (error) {
                    NSLog(@"error");
                } else {
                    UILabel *successLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 250.0f, 320.0f, 30.0f)];
                    successLabel.text = @"Saved Successfully";
                    [self.view addSubview:successLabel];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            NSString *errorMessage = [error localizedDescription];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorMessage delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    
    
    
}

@end
