//
//  PAPfirstPicViewController.h
//  Teamstory
//
//  Created by Tobok Lee on 2/26/15.
//
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import "ThoughtPostViewController.h"
#import "PostPicViewController.h"

@interface PAPfirstPicViewController : UIViewController <UIImagePickerControllerDelegate, ELCImagePickerControllerDelegate, ThoughtPostViewControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (UIImagePickerController *)shouldStartCameraController;

@end
