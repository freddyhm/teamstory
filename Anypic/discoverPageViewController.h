//
//  discoverPageViewController.h
//  Teamstory
//
//  Created by Tobok Lee on 1/10/14.
//
//

#import <UIKit/UIKit.h>
#import "PAPFindFriendsCell.h"
extern NSInteger selection;

@interface discoverPageViewController : UIViewController <UITabBarControllerDelegate, UINavigationBarDelegate, UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,PAPFindFriendsCellDelegate>


@end
