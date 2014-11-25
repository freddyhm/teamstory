//
//  PAPTabBarController.h
//  Teamstory
//
//

#import "PAPEditPhotoViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import "ImageCropper.h"

@protocol PAPTabBarControllerDelegate;

@interface PAPTabBarController : UITabBarController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, ELCImagePickerControllerDelegate, ImageCropperDelegate>

@property (nonatomic, strong) UIView *postMenu;
@property (nonatomic, strong) UIButton *postButton;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (UIImagePickerController *)shouldStartCameraController;

@end

@protocol PAPTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;




@end