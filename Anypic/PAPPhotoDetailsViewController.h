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

@interface PAPPhotoDetailsViewController : UIViewController <UITextFieldDelegate, PAPPhotoDetailsHeaderViewDelegate, PAPBaseTextCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, CustomKeyboardViewControllerDelegate>

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) UITableView *postDetails;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) CustomKeyboardViewController *customKeyboard;
@property int objectsPerPage;

- (id)initWithPhoto:(PFObject *)aPhoto source:(NSString *)source;
- (void)dismissKeyboard;

@end
