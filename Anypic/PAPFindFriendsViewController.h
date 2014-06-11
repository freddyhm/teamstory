//
//  PAPFindFriendsViewController.h
//  Teamstory
//
//

#import "PAPFindFriendsCell.h"

@interface PAPFindFriendsViewController : PFQueryTableViewController <PAPFindFriendsCellDelegate>

- (id)initWithStyle:(UITableViewStyle)style type:(NSString *)type;

@end
