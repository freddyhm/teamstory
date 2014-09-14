//
//  PAPMessagingSeachUsersViewController.h
//  Teamstory
//
//  Created by Tobok Lee on 9/11/14.
//
//

#import <UIKit/UIKit.h>
#import "PAPFindFriendsCell.h"
#import "PAPMessagingViewController.h"

@interface PAPMessagingSeachUsersViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, PAPFindFriendsCellDelegate>
- (void) setNavigationController:(UINavigationController *)navController;
@end
