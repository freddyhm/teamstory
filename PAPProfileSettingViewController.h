//
//  PAPAccountViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

# import "PAPProfileSettingViewController.h"
# import <UIKit/UIKit.h>
# import <Parse/Parse.h>
# import "MBProgressHUD.h"
# include <stdlib.h>
#import "PAPEditPhotoViewController.h"


@interface PAPProfileSettingViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, UITextFieldDelegate, UINavigationControllerDelegate> {
    
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
    NSArray *dropDownMenu;
    BOOL flag;
}

@property (nonatomic, strong) UITextField *companyName;
@property (nonatomic, strong) UITextField *location;
@property (nonatomic, strong) UITextField *description;
@property (nonatomic, strong) UITextField *website;
@property (nonatomic, strong) UITextField *collaborator;


- (void)refreshView;
- (BOOL)shouldPresentPhotoCaptureController;
- (void)uploadImage:(NSData *)imageData;


@end

