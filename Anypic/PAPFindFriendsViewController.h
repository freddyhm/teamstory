//
//  PAPFindFriendsViewController.h
//  Teamstory
//
//

#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "PAPFindFriendsCell.h"

@interface PAPFindFriendsViewController : PFQueryTableViewController <PAPFindFriendsCellDelegate, ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>

@end
