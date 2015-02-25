//
//  PAPLoginPopupViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/19/15.
//
//

#import "PAPLoginPopupViewController.h"
#import "AppDelegate.h"
#import "PAPLoginInfoSheetViewController.h"


@interface PAPLoginPopupViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPWTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *emailTextView;
@property (strong, nonatomic) IBOutlet UIView *passwordTextView;
@property (strong, nonatomic) IBOutlet UIView *confirmPWTextView;

@end

@implementation PAPLoginPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextField.delegate = self;
    self.confirmPWTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.mainScrollView.delegate = self;
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tapOutside];
    
}
- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)twitterButtonAction:(id)sender {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            [self navigateToInfoSheet];
        } else {
            NSLog(@"User logged in with Twitter!");
            NSNumber *profilExist_num = [[PFUser currentUser] objectForKey: @"profileExist"];
            bool profileExist = [profilExist_num boolValue];
            
            if (user && profileExist != YES) {
                PAPLoginInfoSheetViewController *loginInfoSheetViewController = [[PAPLoginInfoSheetViewController alloc] initWithNibName:@"PAPLoginInfoSheetViewController" bundle:nil];
                self.navigationController.navigationBarHidden = YES;
                [self presentViewController:loginInfoSheetViewController animated:YES completion:nil];
            } else if (user && profileExist == YES) {
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
            }
        }     
    }];
}
- (IBAction)signUpButtonAction:(id)sender {
    [self navigateToInfoSheet];
}

- (void) navigateToInfoSheet {
    PAPLoginInfoSheetViewController *loginInfoSheetController = [[PAPLoginInfoSheetViewController alloc] initWithNibName:@"PAPLoginInfoSheetViewController" bundle:nil];
    [self presentViewController:loginInfoSheetController animated:YES completion:nil];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint scrollPoint;
    
    float offsetValue = 5.0f;
    
    if (self.emailTextField == textField) {
        scrollPoint = CGPointMake(0, self.emailTextView.frame.origin.y - offsetValue);
    } else if (self.passwordTextField == textField) {
        scrollPoint = CGPointMake(0, self.passwordTextView.frame.origin.y - offsetValue);
    } else if (self.confirmPWTextField == textField) {
        scrollPoint = CGPointMake(0, self.confirmPWTextView.frame.origin.y - offsetValue);
    }
    
    [self.mainScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.mainScrollView setContentOffset:CGPointZero animated:YES];
}

@end
