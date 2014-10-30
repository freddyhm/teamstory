//
//  PAPPhotoDetailViewController.h
//  Teamstory
//
//

#import "PAPPhotoDetailsHeaderView.h"
#import "PAPBaseTextCell.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CustomKeyboardViewController.h"

@class PAPPhotoDetailsViewController;

@interface PAPPhotoDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, PAPPhotoDetailsHeaderViewDelegate, PAPBaseTextCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITextViewDelegate, CustomKeyboardViewControllerDelegate>

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) CustomKeyboardViewController *customKeyboard;

- (id)initWithPhoto:(PFObject *)aPhoto source:(NSString *)source;
- (void)dismissKeyboard;

@end
