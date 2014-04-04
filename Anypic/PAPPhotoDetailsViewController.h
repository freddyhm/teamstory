//
//  PAPPhotoDetailViewController.h
//  Teamstory
//
//

#import "PAPPhotoDetailsHeaderView.h"
#import "PAPBaseTextCell.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface PAPPhotoDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, PAPPhotoDetailsHeaderViewDelegate, PAPBaseTextCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) PFObject *photo;

- (id)initWithPhoto:(PFObject *)aPhoto source:(NSString *)source;

@end
