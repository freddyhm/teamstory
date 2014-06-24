//
//  PAPFindFriendsViewController.h
//  Teamstory
//
//

#import "PAPFindFriendsCell.h"

@interface FollowersFollowingViewController : PFQueryTableViewController <PAPFindFriendsCellDelegate>

- (id)initWithStyle:(UITableViewStyle)style type:(NSString *)type forUser:(PFUser *)user;

@end
