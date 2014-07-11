//
//  PAPTabBarController.h
//  Teamstory
//
//

#import "PAPEditPhotoViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"

@protocol PAPTabBarControllerDelegate;

@interface PAPTabBarController : UITabBarController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, ELCImagePickerControllerDelegate>

@property (nonatomic, strong) UIView *postMenu;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (UIImagePickerController *)shouldStartCameraController;

@end

@protocol PAPTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;




@end