//
//  PAPTabBarController.h
//  Teamstory
//
//

#import "PAPEditPhotoViewController.h"

@protocol PAPTabBarControllerDelegate;

@interface PAPTabBarController : UITabBarController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

- (BOOL)shouldPresentPhotoCaptureController;
- (void)shouldPresentController:(NSString *)typeController;

@end

@protocol PAPTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;


@end