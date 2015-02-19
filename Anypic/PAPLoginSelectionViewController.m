//
//  PAPLoginSelectionViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/19/15.
//
//

#import "PAPLoginSelectionViewController.h"
#import "PAPLoginPopupViewController.h"

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
    
}
- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
