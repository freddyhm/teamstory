//
//  PAPAccountViewController.h
//  Teamstory
//
//

#import "PhotoTimelineViewController.h"
#import "FirstAccountHeaderViewController.h"
#import "SecondAccountHeaderViewController.h"

@interface PAPAccountViewController : PhotoTimelineViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UINavigationController *navController;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) FirstAccountHeaderViewController *firstHeaderViewController;
@property (strong, nonatomic) SecondAccountHeaderViewController *secondHeaderViewController;




@end