//
//  CameraFilterViewController.h
//  Anypic
//
//  Created by Freddy Hidalgo-Monchez on 1/15/2014.
//
//

#import <UIKit/UIKit.h>

@interface CameraFilterViewController : UIViewController

@property (nonatomic,strong) UIImage *croppedImage;
@property (nonatomic,strong) IBOutlet UIImageView *croppedImageView;
@property (strong, nonatomic) IBOutlet UIButton *test;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelEditBtn;
- (IBAction)cancelEdit:(UIBarButtonItem *)sender;
- (IBAction)removeFilter:(id)sender;
- (IBAction)saveEdit:(id)sender;

@end
