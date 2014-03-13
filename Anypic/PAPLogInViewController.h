//
//  PAPLogInViewController.h
//  Teamstory
//
//
#import "emailLoginViewController.h"
#import "PAPLogInViewController.h"

@interface PAPLogInViewController : PFLogInViewController <UINavigationControllerDelegate>
@property (nonatomic, strong) PAPLogInViewController *loginViewController;
@property (nonatomic, strong) emailLoginViewController *emailLoginView;
@property (nonatomic, strong) UINavigationController *emailLoginNavController;

- (id)initWithLoginType:(NSString *)loginType;
@end
