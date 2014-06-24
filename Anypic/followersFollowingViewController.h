//
//  PAPFindFriendsViewController.h
//  Teamstory
//
//

#import "PAPFindFriendsCell.h"

@interface followersFollowingViewController : PFQueryTableViewController <PAPFindFriendsCellDelegate>

- (id)initWithStyle:(UITableViewStyle)style type:(NSString *)type forUser:(PFUser *)user;

@end
