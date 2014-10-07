//
//  PAPMessagingViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-09-08.
//
//

#import "PAPMessagingViewController.h"


#define messageTextViewHeight 45.0f
#define navBarHeight 64.0f
#define textSize 15.0f
#define sendButtonWidth 50.0f
#define sendButtonHeight 45.0f
#define messageTextSize 16.0f
#define messageHorizontalSpacing 80.0f
#define notificationBarHeight 30.0f

@interface PAPMessagingViewController () {
    CGRect tabBarSize;
    double keyboardDuration;
    float keyboardHeight;
    int _currentPage;
    BOOL isNewMessage;
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.tabBar.frame = tabBarSize;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUserCurrentScreen:nil setTargetRoom:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.messageQuery = [[NSMutableArray alloc] init];
    [self registerForNotifications];
    
    self.tabBarController.tabBar.hidden = YES;
    tabBarSize = self.tabBarController.tabBar.frame;
    self.tabBarController.tabBar.frame = CGRectZero;
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUserCurrentScreen:@"messagingScreen" setTargetRoom:self.targetChatRoom];

    [self loadMessageQuery];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    self.view = self.scrollView;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.view.userInteractionEnabled = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIImage *moreActionButtonImage = [UIImage imageNamed:@"button-more.png"];
    UIButton *moreActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreActionButton setFrame:CGRectMake(0.0f, 0.0f, moreActionButtonImage.size.width, moreActionButtonImage.size.height)];
    [moreActionButton setBackgroundImage:moreActionButtonImage forState:UIControlStateNormal];
    [moreActionButton addTarget:self action:@selector(moreActionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreActionButton];
    
    
    self.navigationItem.title = [self.recipient objectForKey:@"displayName"];
    
    // --------------------- Keyboard animation
    
    self.messageTextViewBG = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (navBarHeight + messageTextViewHeight), [UIScreen mainScreen].bounds.size.width, messageTextViewHeight)];
    [self.messageTextViewBG setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [self.view addSubview:self.messageTextViewBG];
    
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, self.messageTextViewBG.bounds.size.width - 10.0f, self.messageTextViewBG.bounds.size.height - 10.0f)];
    self.messageTextView.keyboardType = UIKeyboardTypeTwitter;
    [self.messageTextView setBackgroundColor:[UIColor whiteColor]];
    self.messageTextView.delegate = self;
    self.messageTextView.font = [UIFont systemFontOfSize:textSize];
    [self.messageTextViewBG addSubview:self.messageTextView];
    
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.messageTextViewBG.bounds.size.width - sendButtonWidth, 0.0f, sendButtonWidth, sendButtonHeight)];
    [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    self.sendButton.hidden = YES;
    [self.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.enabled = NO;
    [self.sendButton setTitleColor:teamStoryColor forState:UIControlStateNormal];
    [self.messageTextViewBG addSubview:self.sendButton];
    
    
    // --------------------- Message body UITableView
    self.messageList = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.messageTextViewBG.bounds.size.height - navBarHeight)];
    self.messageList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageList.delegate = self;
    self.messageList.dataSource = self;
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
    
    [self.view bringSubviewToFront:self.messageTextViewBG];
    [self.view bringSubviewToFront:self.notificationView];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
}

# pragma UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.2f animations:^{
        self.messageTextView.frame = CGRectMake(5.0f, 5.0f, self.messageTextViewBG.bounds.size.width - (10.0f + sendButtonWidth), self.messageTextViewBG.bounds.size.height - 10.0f);
        self.sendButton.hidden = NO;
    }];
}

-(void)textViewDidChange:(UITextView *)textView {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:textSize]};
    CGRect textViewSize = [textView.text boundingRectWithSize:CGSizeMake(self.messageTextView.bounds.size.width - 10.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    if (textViewSize.size.height > 20.0f) {
        self.messageTextViewBG.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (navBarHeight + textViewSize.size.height + keyboardHeight + 30.0f), [UIScreen mainScreen].bounds.size.width, textViewSize.size.height + 30.0f);
    } else {
        self.messageTextViewBG.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (navBarHeight + messageTextViewHeight + keyboardHeight), [UIScreen mainScreen].bounds.size.width, messageTextViewHeight);
    }
    
    self.messageTextView.frame = CGRectMake(5.0f, 5.0f, self.messageTextViewBG.bounds.size.width - 10.0f - sendButtonWidth, self.messageTextViewBG.bounds.size.height - 10.0f);
    
    if ([textView.text length] > 0) {
        [self changeSendButtonState:YES];
    } else {
        [self changeSendButtonState:NO];
    }
}

# pragma - ()

- (void) moreActionButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:@"Report User"]];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void) backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)scrollToBottom:(BOOL)animated {
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.messageQuery count] - 1 inSection: 0];
    [self.messageList scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated:animated];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)notificationButtonAction:(id)sender {
    self.notificationView.hidden = YES;
}

- (void)updateTableViewNotification:(NSNotification *)notification {
    isNewMessage = YES;
    self.notificationView.hidden = NO;
    [self loadMessageQuery];
}

-(void)loadMessageQuery{
    PFQuery *messageQuery = [PFQuery queryWithClassName:@"Message"];
    [messageQuery whereKey:@"chatRoom" equalTo:self.targetChatRoom];
    [messageQuery orderByAscending:@"createdAt"];
    [messageQuery setLimit:100];
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.messageQuery removeAllObjects];
        [self.messageQuery addObjectsFromArray:objects];
        [self.messageList reloadData];
        [self scrollToBottom:NO];
    }];
}

- (void)changeSendButtonState:(BOOL)state {
    if (state) {
        self.sendButton.alpha = 1.0f;
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.alpha = 0.7f;
        self.sendButton.enabled = NO;
    }
}

- (void)sendButtonAction:(id)sender {
    PFObject *messagePFObject = [PFObject objectWithClassName:@"Message"];
    [messagePFObject setObject:[PFUser currentUser] forKey:@"fromUser"];
    [messagePFObject setObject:self.recipient forKey:@"toUser"];
    [messagePFObject setObject:self.messageTextView.text forKey:@"messageBody"];
    [messagePFObject setObject:self.targetChatRoom forKey:@"chatRoom"];
    
    // adding new object.
    [self.messageQuery addObject:messagePFObject];
    [self.messageList reloadData];
    [self scrollToBottom:YES];
    [messagePFObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error) {
            NSLog(@"Message Sent");
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    
    [self.targetChatRoom setObject:self.messageTextView.text forKey:@"lastMessage"];
    if ([self.userTypeNumber isEqualToString:@"userOne"]) {
        if ([self.targetChatRoom objectForKey:@"userOneBadge"] > 0) {
            [self.targetChatRoom incrementKey:@"userOneBadge"];
        } else {
            [self.targetChatRoom setObject:[NSNumber numberWithInt:1] forKey:@"userOneBadge"];
        }
    } else {
        if ([self.targetChatRoom objectForKey:@"userTwoBadge"] > 0) {
            [self.targetChatRoom incrementKey:@"userTwoBadge"];
        } else {
            [self.targetChatRoom setObject:[NSNumber numberWithInt:1] forKey:@"userTwoBadge"];
        }
    }
    [self.targetChatRoom saveInBackground];
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
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyboardFrameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    UIViewAnimationCurve animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    keyboardDuration = [number doubleValue];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    keyboardHeight = keyboardFrame.size.height;
    
    
    // ---------- Adjust TextView location
    [UIView animateWithDuration:keyboardDuration delay:0 options:animationOptionsWithCurve(animationCurve) animations:^{
        self.messageTextViewBG.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (navBarHeight + messageTextViewHeight) - keyboardHeight, [UIScreen mainScreen].bounds.size.width, messageTextViewHeight);
        self.messageList.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.messageTextViewBG.bounds.size.height - navBarHeight - keyboardHeight);
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
    
    // ---------- Adjust TextView location
    [UIView animateWithDuration:keyboardDuration delay:0 options:animationOptionsWithCurve(animationCurve) animations:^{
        self.messageTextViewBG.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (navBarHeight + messageTextViewHeight), [UIScreen mainScreen].bounds.size.width, messageTextViewHeight);
        self.messageList.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.messageTextViewBG.bounds.size.height - navBarHeight);
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
        CGRect textViewSize = [[[self.messageQuery objectAtIndex:indexPath.row] objectForKey:@"messageBody"] boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - messageHorizontalSpacing, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        
        if (textViewSize.size.height > 30.0f) {
            return textViewSize.size.height + 20.0f;
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
    
    PFObject *currentOBJ = [self.messageQuery objectAtIndex:indexPath.row];
    
    self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    
    NSDate *updatedDate = [currentOBJ createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM dd h:mm a"];
    
    // Get time interval
    NSTimeInterval timeInterval = [updatedDate timeIntervalSinceNow];
    [self.timeIntervalFormatter setUsesAbbreviatedCalendarUnits:YES];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    
    if (fabsf(timeInterval) > (12 * 60 * 60)) {
        cell.timeStampLabel.text = timestamp;
    } else {
        cell.timeStampLabel.text = [dateFormat stringFromDate:updatedDate];
    }
    
    if ([[[currentOBJ objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        cell.RECEIVEDMessageView.hidden = YES;
        cell.SENTMessageView.hidden = NO;
        cell.timeStampLabel.frame = CGRectMake(5.0f, 0.0f, 50.0f, 15.0f);
        cell.timeStampLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        cell.SENTMessageView.hidden = YES;
        cell.RECEIVEDMessageView.hidden = NO;
        cell.timeStampLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 55.0f, 0.0f, 50.0f, 15.0f);
        cell.timeStampLabel.textAlignment = NSTextAlignmentRight;
    }
    
    [cell setText:[currentOBJ objectForKey:@"messageBody"]];
    
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
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipients];
        
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:nil];
    }
}

@end
