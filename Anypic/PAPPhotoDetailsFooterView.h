//
//  PAPPhotoDetailsFooterView.h
//  Teamstory
//
//

@interface PAPPhotoDetailsFooterView : UIView

@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic, strong) UITextView *commentView;
@property (nonatomic) BOOL hideDropShadow;

+ (CGRect)rectForView;
+ (CGRect)rectForEditView;

@end
