//
//  PAPAccountViewController.h
//  Teamstory
//
//

#import "PAPPhotoTimelineViewController.h"

@interface PAPAccountViewController : PAPPhotoTimelineViewController

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UINavigationController *navController;




@end