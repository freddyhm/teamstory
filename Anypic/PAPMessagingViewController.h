//
//  PAPMessagingViewController.h
//  Teamstory
//
//  Created by Tobok Lee on 2014-09-08.
//
//

#import <UIKit/UIKit.h>
#import "PAPMessagingCell.h"
#import "AppDelegate.h"

@interface PAPMessagingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PAPMessagingCellDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *messageList;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIView *messageTextViewBG;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) PFUser *recipient;
@property (nonatomic, strong) NSMutableArray *messageQuery;
@property (nonatomic, strong) PFObject *targetChatRoom;
@property (nonatomic, strong) UIButton *notificationView;
@property (nonatomic, strong) NSString *userTypeNumber;

- (void)setTargetUser:(PFUser *)targetUser setUserNumber:(NSString *)userNumber;
- (void)setRoomInfo:(PFObject *)roomInfo;

@end
