//
//  PAPMessageListViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 9/10/14.
//
//

#import "PAPMessageListViewController.h"
#import "TTTTimeIntervalFormatter.h"
#import "KonotorUI.h"
#import "PAPAccountViewController.h"
#import "AppDelegate.h"
#import "Mixpanel.h"
#import <FlightRecorder/FlightRecorder.h>


#define APP ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define navBarHeight 64.0f
#define tabBarHeight 50.0f
#define notificationBarHeight 50.0f

@interface PAPMessageListViewController () {
    float currentIndexPathRow;
    int totalBadgeNumber;
}

@property (nonatomic, strong) UITableView *messageListTV;
@property (nonatomic, strong) NSMutableArray *messageList;
@property (nonatomic, strong) NSMutableArray *userNumberList;
@property (nonatomic, strong) UIButton *notificationView;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) NSNumber *messageNotificationCount;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UIView *placeHolder;

@end

@implementation PAPMessageListViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Message List"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"message_list_screen" action:@"viewing_message_list" label:@"" value:@""];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"Message List"];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    totalBadgeNumber = 0;
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUserCurrentScreen:@"messagingListViewScreen" setTargetRoom:nil setTargetUser:nil setNavigationController:self.navigationController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateListViewQuery) name:@"updateListViewQuery" object:nil];
    
    // fetch unread messages, show feedback screen
    self.messageNotificationCount = [NSNumber numberWithInt:[Konotor getUnreadMessagesCount]];
    
    if([self.messageNotificationCount intValue] > 0){
        self.badgeLabel.hidden = NO;
        self.badgeLabel.text = [self.messageNotificationCount stringValue];
        self.notificationView.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -70.0f, 0.0f, 0.0f);
    }else{
        self.badgeLabel.hidden = YES;
        self.notificationView.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -130.0f, 0.0f, 0.0f);
    }
    
    [self updateListViewQuery];
    
}

- (void) updateListViewQuery {
    PFQuery *userOneQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userOneQuery whereKey:@"userOne" equalTo:[PFUser currentUser]];
    [userOneQuery whereKey:@"userOneShowChatRoom" notEqualTo:[NSNumber numberWithBool:NO]];
    [userOneQuery whereKeyExists:@"lastMessage"];
    
    PFQuery *userTwoQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userTwoQuery whereKey:@"userTwo" equalTo:[PFUser currentUser]];
    [userTwoQuery whereKey:@"userTwoShowChatRoom" notEqualTo:[NSNumber numberWithBool:NO]];
    [userTwoQuery whereKeyExists:@"lastMessage"];
    
    PFQuery *messageListQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userOneQuery, userTwoQuery, nil]];
    [messageListQuery orderByDescending:@"updatedAt"];
    [messageListQuery includeKey:@"userOne.User"];
    [messageListQuery includeKey:@"userTwo.User"];
    [messageListQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && [objects count] > 0) {
            self.placeHolder.hidden = YES;
            self.messageListTV.hidden = NO;
            [self.userNumberList removeAllObjects];
            [self.messageList removeAllObjects];
            [self.messageList addObjectsFromArray:objects];
            [self.messageListTV reloadData];
        } else {
            self.placeHolder.hidden = NO;
            self.messageListTV.hidden = YES;
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUserCurrentScreen:nil setTargetRoom:nil setTargetUser:nil setNavigationController:nil];
    
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:totalBadgeNumber] forKey:@"messagingBadge"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageButton" object:nil];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"Messages";
    
    self.userNumberList = [[NSMutableArray alloc] init];
    self.messageList = [[NSMutableArray alloc] init];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, 22)];
    statusBarView.backgroundColor = teamStoryColor;
    [self.navigationController.navigationBar addSubview:statusBarView];
    
    UIImage *newMessageButtonImage = [UIImage imageNamed:@"btn_new_message.png"];
    UIButton *newMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newMessageButton setFrame:CGRectMake(0.0f, 0.0f, newMessageButtonImage.size.width, newMessageButtonImage.size.height)];
    [newMessageButton setImage:newMessageButtonImage forState:UIControlStateNormal];
    newMessageButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, -10.0f);
    [newMessageButton addTarget:self action:@selector(newMessageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:newMessageButton];
    
    self.notificationView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, notificationBarHeight)];
    self.notificationView.backgroundColor = [UIColor colorWithRed:229.0f/255.0f green:235.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    [self.notificationView setTitle:@"Chat with Teamstory!" forState:UIControlStateNormal];
    [self.notificationView setTitleColor:[UIColor colorWithRed:74.0f/255.0f green:144.0f/255.0f blue:226.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.notificationView.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [self.notificationView addTarget:self action:@selector(notificationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.notificationView];
    
    self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 12.5f, 35.0f, 25.0f)];
    self.badgeLabel.backgroundColor = [UIColor redColor];
    self.badgeLabel.alpha = 0.8f;
    self.badgeLabel.layer.cornerRadius = 13.0f;
    self.badgeLabel.clipsToBounds = YES;
    [self.badgeLabel setTextColor:[UIColor whiteColor]];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.notificationView addSubview:self.badgeLabel];
    
    UIImage *notificationArrowImage = [UIImage imageNamed:@"button_feedback_arrow.png"];
    UIImageView *notificationArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.notificationView.bounds.size.width - notificationArrowImage.size.width - 15.0f, (self.notificationView.bounds.size.height - notificationArrowImage.size.height) / 2, notificationArrowImage.size.width, notificationArrowImage.size.height)];
    [notificationArrow setImage:notificationArrowImage];
    [self.notificationView addSubview:notificationArrow];
    
    self.messageListTV = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, notificationBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - navBarHeight - notificationBarHeight)];
    [self.messageListTV setBackgroundColor:[UIColor whiteColor]];
    self.messageListTV.dataSource = self;
    self.messageListTV.delegate = self;
    self.messageListTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageListTV.hidden = YES;
    [self.view addSubview:self.messageListTV];
    
    UIImage *placeHolderImage = [UIImage imageNamed:@"ic_empty_list.png"];
    self.placeHolder = [[UIView alloc] initWithFrame:self.messageListTV.frame];
    self.placeHolder.hidden = YES;
    [self.view addSubview:self.placeHolder];
    
    UIImageView *placeHolderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - placeHolderImage.size.width) / 2, 100.0f, placeHolderImage.size.width, placeHolderImage.size.height)];
    [placeHolderImageView setImage:placeHolderImage];
    [self.placeHolder addSubview:placeHolderImageView];
    
}

#pragma - ()

- (void) notificationButtonAction:(id)sender {
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    [KonotorFeedbackScreen showFeedbackScreen];
}

- (void) backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)newMessageButtonAction:(id)sender {
    PAPMessagingSeachUsersViewController *searchBarViewController = [[PAPMessagingSeachUsersViewController alloc] init];
    [searchBarViewController setNavigationController:self.navigationController];
    [self presentViewController:searchBarViewController animated:YES completion:nil];
    
}

-(void)userButtonAction:(UIButton *)sender {
    NSString *userNumber = [self.userNumberList objectAtIndex:sender.tag];
    
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
    accountViewController.user = (PFUser *)[[self.messageList objectAtIndex:sender.tag] objectForKey:userNumber];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

-(void)cellButtonAction:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    NSString *userNumber = [self.userNumberList objectAtIndex:view.tag];
    
    // load message view.
    PAPMessagingViewController *messageViewController = [[PAPMessagingViewController alloc] init];
    [messageViewController setTargetUser:[[self.messageList objectAtIndex:view.tag] objectForKey:userNumber] setUserNumber:userNumber];
    [messageViewController setRoomInfo:[self.messageList objectAtIndex:view.tag]];
    [self.navigationController pushViewController:messageViewController animated:YES];
}

#pragma UITableViewDelegate 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.messageList count] > 0) {
        return [self.messageList count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    PAPMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPMessageListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    cell.tag = indexPath.row;
    cell.userButton.tag = indexPath.row;
    
    if ([[[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userOne"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        [cell setUser:[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userTwo"]];
        [self.userNumberList addObject:@"userTwo"];
        cell.badgeLabel.text = [[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userOneBadge"] stringValue];
    } else {
        [cell setUser:[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userOne"]];
        [self.userNumberList addObject:@"userOne"];
        cell.badgeLabel.text = [[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userTwoBadge"] stringValue];
    }
    
    if ([cell.badgeLabel.text intValue] > 0) {
        cell.badgeLabel.hidden = NO;
        totalBadgeNumber += [cell.badgeLabel.text intValue];
    } else {
        cell.badgeLabel.hidden = YES;
    }
    
    cell.lastMessageLabel.text = [[self.messageList objectAtIndex:indexPath.row] objectForKey:@"lastMessage"];
    
    self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    
    NSDate *updatedDate = [[self.messageList objectAtIndex:indexPath.row] updatedAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a"];
    
    // Get time interval
    NSTimeInterval timeInterval = [[[self.messageList objectAtIndex:indexPath.row] updatedAt] timeIntervalSinceNow];
    [self.timeIntervalFormatter setUsesAbbreviatedCalendarUnits:YES];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    
    if (fabsf(timeInterval) > (12 * 60 * 60)) {
        cell.timeStampLabel.text = timestamp;
    } else {
        cell.timeStampLabel.text = [dateFormat stringFromDate:updatedDate];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellButtonAction:)];
    [cell addGestureRecognizer:tapGesture];
    
    [cell.userButton addTarget:self action:@selector(userButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"More" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:@"Report User"]];
        [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        
        [self.messageListTV setEditing:NO];
    }];
    moreAction.backgroundColor = [UIColor lightGrayColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        if ([[[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userOne"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
          [[self.messageList objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:NO] forKey:@"userOneShowChatRoom"];
        } else {
          [[self.messageList objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:NO] forKey:@"userTwoShowChatRoom"];
        }
        [[self.messageList objectAtIndex:indexPath.row] saveInBackground];
        
        [self.messageList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([self.messageList count] == 0) {
            self.placeHolder.hidden = NO;
            self.messageListTV.hidden = YES;
        }
    }];
    
    return @[deleteAction, moreAction];
}

// ios 7. For iOS 8, all the process get handled in tableView:editActionForRowAtIndexPath:.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userOne"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [[self.messageList objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:NO] forKey:@"userOneShowChatRoom"];
        } else {
            [[self.messageList objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:NO] forKey:@"userTwoShowChatRoom"];
        }
        [[self.messageList objectAtIndex:indexPath.row] saveInBackground];
        
        [self.messageList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([self.messageList count] == 0) {
            self.placeHolder.hidden = NO;
            self.messageListTV.hidden = YES;
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet destructiveButtonIndex] == buttonIndex) {
        NSString *emailTitle = @"[USER REPORT] Reporting User (Messages)";
        NSArray *toRecipients = [NSArray arrayWithObject:@"info@teamstoryapp.com"];
        NSString *userNumber = [self.userNumberList objectAtIndex:currentIndexPathRow];
        
        NSString *reportingUserName = [[[self.messageList objectAtIndex:currentIndexPathRow] objectForKey:userNumber] objectForKey:@"displayName"];
        NSString *currentUserName = [[PFUser currentUser] objectForKey:@"displayName"];
        NSString *messageBody = [NSString stringWithFormat:@"Current Username: %@\nTarget Username: %@\nI am reporting because:\n", currentUserName, reportingUserName];
        
        if ([MFMailComposeViewController canSendMail]) {
            APP.mc.mailComposeDelegate = self;
            [APP.mc setSubject:emailTitle];
            [APP.mc setMessageBody:messageBody isHTML:NO];
            [APP.mc setToRecipients:toRecipients];
            
            // Present mail view controller on screen
            [self presentViewController:APP.mc animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissViewControllerAnimated:YES completion:^{
        [APP cycleTheGlobalMailComposer];
    }];
}


@end
