//
//  PAPLoginPopupViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/19/15.
//
//

#import "PAPLoginPopupViewController.h"
#import "AppDelegate.h"

@interface PAPLoginPopupViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailTextView;
@property (strong, nonatomic) IBOutlet UITextField *confirmPWTextView;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextView;

@end

@implementation PAPLoginPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        } else {
            NSLog(@"User logged in with Twitter!");
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:^{
                }];
            }];
            
        }     
    }];
}

// UITextField placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

// UITextField text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}
@end
