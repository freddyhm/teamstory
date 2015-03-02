//
//  PAPLoginSelectionViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/19/15.
//
//

#import "PAPLoginSelectionViewController.h"
#import "PAPLoginPopupViewController.h"
#import "PAPSignUpViewController.h"
#import "AppDelegate.h"

@interface PAPLoginSelectionViewController ()

@end

@implementation PAPLoginSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)joinButtonAction:(id)sender {
    PAPLoginPopupViewController *popupViewController = [[PAPLoginPopupViewController alloc] initWithNibName:@"PAPLoginPopupViewController" bundle:nil];
    [self presentViewController:popupViewController animated:YES completion:nil];
}

- (IBAction)memberButtonAction:(id)sender {
    PAPSignUpViewController *signUpViewController = [[PAPSignUpViewController alloc] initWithNibName:@"PAPSignUpViewController" bundle:nil];
    [self presentViewController:signUpViewController animated:YES completion:nil];
}

- (IBAction)cancelButtonAction:(id)sender {
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
}
@end
