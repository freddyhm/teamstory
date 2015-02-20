//
//  PAPLoginInfoSheetViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/20/15.
//
//

#import "PAPLoginInfoSheetViewController.h"

@interface PAPLoginInfoSheetViewController ()
@property (strong, nonatomic) IBOutlet UIButton *profilePickerButton;

@end

@implementation PAPLoginInfoSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profilePickerButton.layer.cornerRadius = self.profilePickerButton.bounds.size.width / 2;
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        
    }
}

- (IBAction)profilePickerButtonAction:(id)sender {
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

@end
