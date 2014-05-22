//
//  PAPAccountViewController.h
//  Teamstory
//
//

# import "PAPProfileSettingViewController.h"
# import <UIKit/UIKit.h>
# import <Parse/Parse.h>
# import "SVProgressHUD.h"
# include <stdlib.h>
#import "PAPEditPhotoViewController.h"


@interface PAPProfileSettingViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate> {
    
    NSArray *dropDownMenu;
    BOOL flag;
}

@property (nonatomic, strong) UITextField *companyName;
@property (nonatomic, strong) UITextField *location;
@property (nonatomic, strong) UITextField *description;
@property (nonatomic, strong) UITextField *website;
@property (nonatomic, strong) UITextField *email_address;


- (void)refreshView;
- (BOOL)shouldPresentPhotoCaptureController;
- (void)uploadImage_small:(NSData *)imageData;
- (void)uploadImage_medium:(NSData *)imageData;


@end

