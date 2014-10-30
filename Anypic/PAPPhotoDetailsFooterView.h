//
//  PAPPhotoDetailsFooterView.h
//  Teamstory
//
//

#import "CustomKeyboardViewController.h"

@interface PAPPhotoDetailsFooterView : UIView <CustomKeyboardViewControllerDelegate>

@property (nonatomic, strong) CustomKeyboardViewController *commentView;
@property (nonatomic, strong) UITextField *commentField;

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic) BOOL hideDropShadow;
@property (nonatomic, strong) UIButton *sendBtn;

+ (CGRect)rectForView;
+ (CGRect)rectForEditView;

@end
