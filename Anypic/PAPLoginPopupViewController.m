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

@property (strong, nonatomic) IBOutlet UITextField *emailTextView;
@property (strong, nonatomic) IBOutlet UITextField *confirmPWTextView;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextView;

@end

@implementation PAPLoginPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
            
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

@end
