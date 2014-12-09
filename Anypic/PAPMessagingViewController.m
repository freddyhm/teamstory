//
//  PAPMessagingViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-09-08.
//
//

#import "PAPMessagingViewController.h"
#import "SVProgressHUD.h"


#define messageTextViewHeight 45.0f
#define navBarHeight 64.0f
#define textSize 15.0f
#define sendButtonWidth 50.0f
#define sendButtonHeight 45.0f
#define messageTextSize 16.0f
#define messageHorizontalSpacing 80.0f
#define notificationBarHeight 30.0f
#define MAXMessageLabelWidth 215.0f
#define APP ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface PAPMessagingViewController () {
    double keyboardDuration;
    float keyboardHeight;
    int _currentPage;
    float textViewHeight;
}

@end

@implementation PAPMessagingViewController

- (void)setTargetUser:(PFUser *)targetUser setUserNumber:(NSString *)userNumber{
    self.recipient = targetUser;
    self.userTypeNumber = userNumber;
}

- (void)setRoomInfo:(PFObject *)roomInfo {
    self.targetChatRoom = roomInfo;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    self.messageQuery = [[NSMutableArray alloc] init];
    [self registerForNotifications];
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUserCurrentScreen:@"messagingScreen" setTargetRoom:self.targetChatRoom setTargetUser:self.recipient setNavigationController:self.navigationController];
    
    [self.customKeyboard setLocation:@"messaging"];
    
    [self loadMessageQuery];
    [self updateRoomBadge];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
   
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUserCurrentScreen:nil setTargetRoom:nil setTargetUser:nil setNavigationController:nil];
    [self.customKeyboard setLocation:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    self.view = self.scrollView;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIImage *moreActionButtonImage = [UIImage imageNamed:@"btn_message_more.png"];
    UIButton *moreActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreActionButton setFrame:CGRectMake(0.0f, 0.0f, moreActionButtonImage.size.width, moreActionButtonImage.size.height)];
    [moreActionButton setBackgroundImage:moreActionButtonImage forState:UIControlStateNormal];
    [moreActionButton addTarget:self action:@selector(moreActionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreActionButton];
    
    
    self.navigationItem.title = [self.recipient objectForKey:@"displayName"];
    
    // --------------------- Keyboard animation
    self.customKeyboard = [[CustomKeyboardViewController alloc] initWithNibName:@"CustomKeyboardViewController" bundle:nil];
    self.customKeyboard.delegate = self;
    self.customKeyboard.messageTextView.userInteractionEnabled = YES;
    textViewHeight = self.customKeyboard.view.bounds.size.height;
    [self.view addSubview:self.customKeyboard.view];
    
    // --------------------- Message body UITableView
    self.messageList = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.customKeyboard.view.bounds.size.height - navBarHeight)];
    self.messageList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageList.delegate = self;
    self.messageList.dataSource = self;
    self.messageList.hidden = YES;
    [self.view addSubview:self.messageList];
    
    // ------------------- New Message Notification
    self.notificationView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (navBarHeight + messageTextViewHeight + notificationBarHeight), [UIScreen mainScreen].bounds.size.width, notificationBarHeight)];
    self.notificationView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0f];
    self.notificationView.hidden = YES;
    [self.notificationView addTarget:self action:@selector(notificationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.notificationView];
    
    UILabel *notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, [UIScreen mainScreen].bounds.size.height - 20.0f, 20.0f)];
    [notificationLabel setText:@"new Notification Has Arrived"];
    [self.notificationView addSubview:notificationLabel];
    
    //----------------------- Placeholder
    
    UIImage *placeHolderImage = [UIImage imageNamed:@"nomessage_placeholder.png"];
    self.placeHolder = [[UIView alloc] initWithFrame:self.messageList.frame];
    self.placeHolder.hidden = YES;
    [self.view addSubview:self.placeHolder];
    
    UIImageView *placeHolderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - placeHolderImage.size.width) / 2, 25.0f, placeHolderImage.size.width, placeHolderImage.size.height)];
    [placeHolderImageView setImage:placeHolderImage];
    [self.placeHolder addSubview:placeHolderImageView];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
    [self.view bringSubviewToFront:self.notificationView];
    [self.view bringSubviewToFront:self.customKeyboard.view];
    [self.customKeyboard.messageTextView becomeFirstResponder];
    
}

# pragma - ()

- (void) updateRoomBadge {
    NSNumber *offSetBadgeNumber;
    
    if ([[[self.targetChatRoom objectForKey:@"userOne"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        [self.targetChatRoom setObject:[NSNumber numberWithInt:0] forKey:@"userOneBadge"];
        offSetBadgeNumber = [self.targetChatRoom objectForKey:@"userOneBadge"];
    } else {
        [self.targetChatRoom setObject:[NSNumber numberWithInt:0] forKey:@"userTwoBadge"];
        offSetBadgeNumber = [self.targetChatRoom objectForKey:@"userTwoBadge"];
    }
    
    [self.targetChatRoom saveInBackground];
    
    if ([[[PFUser currentUser] objectForKey:@"messagingBadge"] intValue] - [offSetBadgeNumber intValue] < 0 ) {
        [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"messagingBadge"];
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithInt:[[[PFUser currentUser] objectForKey:@"messagingBadge"] intValue] - [offSetBadgeNumber intValue]] forKey:@"messagingBadge"];
    }
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageButton" object:nil];
    }];
    
    if ([PFInstallation currentInstallation].badge - [offSetBadgeNumber intValue] < 0) {
        [[PFInstallation currentInstallation] setBadge:0];
    } else {
        [[PFInstallation currentInstallation] setBadge:[PFInstallation currentInstallation].badge - [offSetBadgeNumber intValue]];
    }
    [[PFInstallation currentInstallation] saveInBackground];
}

- (void) setTableViewHeight {
    if (self.customKeyboard.view.frame.origin.y < 300) { // keyboard showing
        self.messageList.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.customKeyboard.view.bounds.size.height - navBarHeight - keyboardHeight);
    } else { // keyboard hiding
        self.messageList.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.customKeyboard.view.bounds.size.height - navBarHeight);
    }
    [self scrollToBottom:NO];
}

- (void) moreActionButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:@"Report User"]];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void) backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)scrollToBottom:(BOOL)animated {
    if ([self.messageQuery count] > 0) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.messageQuery count] - 1 inSection: 0];
        [self.messageList scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated:animated];
    }
}

-(void)dismissKeyboard {
    [self.customKeyboard.messageTextView resignFirstResponder];
}

- (void)notificationButtonAction:(id)sender {
    self.notificationView.hidden = YES;
}

- (void)updateTableViewNotification:(NSNotification *)notification {
    self.notificationView.hidden = YES;
    
    PFQuery *newMessageQuery = [PFQuery queryWithClassName:@"Message"];
    [newMessageQuery whereKey:@"objectId" equalTo:notification.object];
    [newMessageQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [self.messageQuery addObject:object];
            [self.messageList reloadData];
            [self scrollToBottom:YES];
        } else {
            NSLog(@"newMessageQuery Error: %@", error);
        }
    }];
}

-(void) loadMessageQuery {
    
    [SVProgressHUD show];
    
    PFQuery *messageQuery = [PFQuery queryWithClassName:@"Message"];
    [messageQuery whereKey:@"chatRoom" equalTo:self.targetChatRoom];
    [messageQuery orderByDescending:@"createdAt"];
    [messageQuery setLimit:200];
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && [objects count] > 0) {
            
            [SVProgressHUD dismiss];
            
            self.messageList.hidden = NO;
            self.placeHolder.hidden = YES;
            [self.messageQuery removeAllObjects];
            
            for (long i = objects.count - 1; i >= 0; i--) {
                [self.messageQuery addObject:[objects objectAtIndex:i]];
            }
            [self.messageList reloadData];
            [self scrollToBottom:NO];
        } else {
            self.placeHolder.hidden = NO;
            self.messageList.hidden = YES;
        }
    }];
}

- (void)sendButtonAction:(id)sender {
    if ([self.customKeyboard.messageTextView.text length] > 0) {
        PFObject *messagePFObject = [PFObject objectWithClassName:@"Message"];
        [messagePFObject setObject:[PFUser currentUser] forKey:@"fromUser"];
        [messagePFObject setObject:self.recipient forKey:@"toUser"];
        [messagePFObject setObject:self.customKeyboard.messageTextView.text forKey:@"messageBody"];
        [messagePFObject setObject:self.targetChatRoom forKey:@"chatRoom"];
        
        // adding new object.
        [self.messageQuery addObject:messagePFObject];
        [self.messageList reloadData];
        self.messageList.hidden = NO;
        self.placeHolder.hidden = YES;
        [self scrollToBottom:YES];
        
        [messagePFObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error) {
                NSLog(@"Message Sent");
            } else {
                NSLog(@"%@", error);
            }
        }];
        
        
        [self.targetChatRoom setObject:self.customKeyboard.messageTextView.text forKey:@"lastMessage"];
        if ([self.userTypeNumber isEqualToString:@"userOne"]) {
            
            // Update Badge for userone.
            if ([self.targetChatRoom objectForKey:@"userOneBadge"] > 0) {
                [self.targetChatRoom incrementKey:@"userOneBadge"];
            } else {
                [self.targetChatRoom setObject:[NSNumber numberWithInt:1] forKey:@"userOneBadge"];
            }
            
        } else {
            
            // Update Badge for usertwo.
            if ([self.targetChatRoom objectForKey:@"userTwoBadge"] > 0) {
                [self.targetChatRoom incrementKey:@"userTwoBadge"];
            } else {
                [self.targetChatRoom setObject:[NSNumber numberWithInt:1] forKey:@"userTwoBadge"];
            }
        }
        
        // Update User ChatRoom showing.
        [self.targetChatRoom setValue:[NSNumber numberWithBool:YES] forKey:@"userTwoShowChatRoom"];
        [self.targetChatRoom setValue:[NSNumber numberWithBool:YES] forKey:@"userOneShowChatRoom"];
        
        [self.targetChatRoom saveInBackground];
        
        textViewHeight = messageTextViewHeight;
        self.customKeyboard.messageTextView.text = nil;
        [self.customKeyboard textViewDidChange:self.customKeyboard.messageTextView];
    }
}

# pragma UIKeyboard
- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableViewNotification:) name:@"updateTableView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRoomBadge) name:@"updateMessageListView" object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyboardFrameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    UIViewAnimationCurve animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    keyboardDuration = [number doubleValue];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    keyboardHeight = keyboardFrame.size.height;
    
    [self.customKeyboard setKeyboardHeight:keyboardHeight];
    
    // ---------- Adjust TextView location
    [UIView animateWithDuration:keyboardDuration delay:0 options:animationOptionsWithCurve(animationCurve) animations:^{
        self.customKeyboard.view.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (navBarHeight + textViewHeight) - keyboardHeight, [UIScreen mainScreen].bounds.size.width, textViewHeight);
        self.messageList.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.customKeyboard.view.bounds.size.height - navBarHeight - keyboardHeight);
        [self scrollToBottom:NO];
    } completion:^(BOOL finished) {
    }];
    
}

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve) {
    return (UIViewAnimationOptions)curve << 16;
}


- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyboardFrameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    UIViewAnimationCurve animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    keyboardDuration = [number doubleValue];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    keyboardHeight = keyboardFrame.size.height;
    
    [self.customKeyboard setKeyboardHeight:keyboardHeight];
    
    // ---------- Adjust TextView location
    [UIView animateWithDuration:keyboardDuration delay:0 options:animationOptionsWithCurve(animationCurve) animations:^{
        textViewHeight = self.customKeyboard.view.frame.size.height;
        self.customKeyboard.view.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (navBarHeight + textViewHeight), [UIScreen mainScreen].bounds.size.width, textViewHeight);
        self.messageList.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - textViewHeight - navBarHeight);
    } completion:^(BOOL finished) {
        
    }];
}



# pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messageQuery count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:messageTextSize]};
    if (self.messageQuery.count > 0) {
        CGRect textViewSize = [[[self.messageQuery objectAtIndex:indexPath.row] objectForKey:@"messageBody"] boundingRectWithSize:CGSizeMake(MAXMessageLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        
        if (textViewSize.size.height > 30.0f) {
            return textViewSize.size.height + 30.0f;
        } else return [PAPMessagingCell heightForCell];
    } else {
        return [PAPMessagingCell heightForCell];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    PAPMessagingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[PAPMessagingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    
    if ([self.messageQuery count] > 0) {
        PFObject *currentOBJ = [self.messageQuery objectAtIndex:indexPath.row];
        
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        NSDate *updatedDate = [currentOBJ createdAt];
        if (!updatedDate) {
            updatedDate = [NSDate date];
        }
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"h:mm a"];
        
        // Get time interval
        NSTimeInterval timeInterval = [updatedDate timeIntervalSinceNow];
        [self.timeIntervalFormatter setUsesAbbreviatedCalendarUnits:YES];
        NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
        
        cell.userInteractionEnabled = NO;
        
        if (fabsf(timeInterval) > (12 * 60 * 60)) {
            cell.timeStampLabel.text = timestamp;
        } else {
            cell.timeStampLabel.text = [dateFormat stringFromDate:updatedDate];
        }
        
        if ([[[currentOBJ objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            cell.RECEIVEDMessageView.hidden = YES;
            cell.SENTTriangle.hidden = NO;
            cell.SENTMessageView.hidden = NO;
            cell.timeStampLabel.frame = CGRectMake(10.0f, 10.0f, 50.0f, 15.0f);
            cell.timeStampLabel.textAlignment = NSTextAlignmentLeft;
            cell.RECEIVEDTriangle.hidden = YES;
        } else {
            cell.SENTMessageView.hidden = YES;
            cell.RECEIVEDTriangle.hidden = NO;
            cell.SENTTriangle.hidden = YES;
            cell.RECEIVEDMessageView.hidden = NO;
            cell.timeStampLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60.0f, 10.0f, 50.0f, 15.0f);
            cell.timeStampLabel.textAlignment = NSTextAlignmentRight;
        }
        
        [cell setText:[currentOBJ objectForKey:@"messageBody"]];
    }
    
    return cell;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet destructiveButtonIndex] == buttonIndex) {
        NSString *emailTitle = @"[USER REPORT] Reporting User (Messages)";
        NSArray *toRecipients = [NSArray arrayWithObject:@"info@teamstoryapp.com"];
        
        NSString *reportingUserName = [self.recipient objectForKey:@"displayName"];
        NSString *currentUserName = [[PFUser currentUser] objectForKey:@"displayName"];
        NSString *messageBody = [NSString stringWithFormat:@"Current Username: %@\nTarget Username: %@\nI am reporting because:\n", currentUserName, reportingUserName];
        
        APP.mc.mailComposeDelegate = self;
        [APP.mc setSubject:emailTitle];
        [APP.mc setMessageBody:messageBody isHTML:NO];
        [APP.mc setToRecipients:toRecipients];
        
        
        // Present mail view controller on screen
        [self presentViewController:APP.mc animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

@end
