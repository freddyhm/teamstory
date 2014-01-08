//
//  PAPLogInViewController.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
//
#import "emailLoginViewController.h"
#import "PAPLogInViewController.h"

@interface PAPLogInViewController : PFLogInViewController <UINavigationControllerDelegate>
@property (nonatomic, strong) PAPLogInViewController *loginViewController;
@property (nonatomic, strong) emailLoginViewController *emailLoginView;
@property (nonatomic, strong) UINavigationController *emailLoginNavController;
@end
