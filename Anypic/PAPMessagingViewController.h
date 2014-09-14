//
//  PAPMessagingViewController.h
//  Teamstory
//
//  Created by Tobok Lee on 2014-09-08.
//
//

#import <UIKit/UIKit.h>
#import "PAPMessagingCell.h"

@interface PAPMessagingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PAPMessagingCellDelegate, UITextViewDelegate, UIScrollViewDelegate>

- (void)setTargetUser:(PFUser *)targetUser;

@end
