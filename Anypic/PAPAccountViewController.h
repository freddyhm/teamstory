//
//  PAPAccountViewController.h
//  Teamstory
//
//

#import "PhotoTimelineViewController.h"

@interface PAPAccountViewController : PhotoTimelineViewController <UIAlertViewDelegate>

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UINavigationController *navController;




@end