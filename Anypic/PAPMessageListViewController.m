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

#define navBarHeight 64.0f
#define tabBarHeight 50.0f
#define notificationBarHeight 50.0f

@interface PAPMessageListViewController ()

@property (nonatomic, strong) UITableView *messageListTV;
@property (nonatomic, strong) NSArray *messageList;
@property (nonatomic, strong) NSMutableArray *userNumberList;
@property (nonatomic, strong) UIButton *notificationView;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) NSNumber *messageNotificationCount;
@property (nonatomic, strong) UILabel *badgeLabel;

@end

@implementation PAPMessageListViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // fetch unread messages, show feedback screen
    self.messageNotificationCount = [NSNumber numberWithInt:[Konotor getUnreadMessagesCount]];
    
    self.userNumberList = [[NSMutableArray alloc] init];
    [self.userNumberList removeAllObjects];
    
    PFQuery *userOneQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userOneQuery whereKey:@"userOne" equalTo:[PFUser currentUser]];
    [userOneQuery whereKeyExists:@"lastMessage"];
    
    PFQuery *userTwoQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userTwoQuery whereKey:@"userTwo" equalTo:[PFUser currentUser]];
    [userTwoQuery whereKeyExists:@"lastMessage"];
    
    PFQuery *messageListQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userOneQuery, userTwoQuery, nil]];
    [messageListQuery orderByDescending:@"updatedAt"];
    [messageListQuery includeKey:@"userOne.User"];
    [messageListQuery includeKey:@"userTwo.User"];
    [messageListQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.messageList = objects;
        [self.messageListTV reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"Messages";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIImage *newMessageButtonImage = [UIImage imageNamed:@"btn_new_message.png"];
    UIButton *newMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newMessageButton setFrame:CGRectMake(0.0f, 0.0f, newMessageButtonImage.size.width, newMessageButtonImage.size.height)];
    [newMessageButton setImage:newMessageButtonImage forState:UIControlStateNormal];
    [newMessageButton addTarget:self action:@selector(newMessageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:newMessageButton];
    
    self.notificationView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, notificationBarHeight)];
    self.notificationView.backgroundColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:0.15f];
    [self.notificationView setTitle:@"Updates & Feedback" forState:UIControlStateNormal];
    [self.notificationView setTitleColor:[UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.notificationView.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -130.0f, 0.0f, 0.0f);
    self.notificationView.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [self.notificationView addTarget:self action:@selector(notificationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.notificationView];
    
    self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 50.0f, 12.5f, 35.0f, 25.0f)];
    self.badgeLabel.backgroundColor = [UIColor redColor];
    self.badgeLabel.alpha = 0.8f;
    self.badgeLabel.layer.cornerRadius = 13.0f;
    self.badgeLabel.clipsToBounds = YES;
    [self.badgeLabel setTextColor:[UIColor whiteColor]];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.notificationView addSubview:self.badgeLabel];
    
    if([self.messageNotificationCount intValue] > 0){
        self.badgeLabel.hidden = NO;
        self.badgeLabel.text = [self.messageNotificationCount stringValue];
    }else{
        self.badgeLabel.hidden = YES;
    }
    
    self.messageListTV = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, notificationBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - navBarHeight - tabBarHeight - notificationBarHeight)];
    [self.messageListTV setBackgroundColor:[UIColor whiteColor]];
    self.messageListTV.dataSource = self;
    self.messageListTV.delegate = self;
    self.messageListTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.messageListTV];
    
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

-(void)cellButtonAction:(UIButton *)sender {
    NSString *userNumber = [self.userNumberList objectAtIndex:sender.tag];
    PFObject *currentObject = [self.messageList objectAtIndex:sender.tag];
    NSNumber *offSetBadgeNumber;
    
    
    if ([userNumber isEqualToString:@"userOne"]) {
        offSetBadgeNumber = [currentObject objectForKey:@"userTwoBadge"];
        [currentObject setObject:[NSNumber numberWithInt:0] forKey:@"userTwoBadge"];
    } else {
        offSetBadgeNumber = [currentObject objectForKey:@"userOneBadge"];
        [currentObject setObject:[NSNumber numberWithInt:0] forKey:@"userOneBadge"];
    }
    
    [currentObject saveInBackground];
    
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
    
    // load message view.
    PAPMessagingViewController *messageViewController = [[PAPMessagingViewController alloc] init];
    [messageViewController setTargetUser:[[self.messageList objectAtIndex:sender.tag] objectForKey:userNumber] setUserNumber:userNumber];
    [messageViewController setRoomInfo:[self.messageList objectAtIndex:sender.tag]];
    [self.navigationController pushViewController:messageViewController animated:YES];
}

#pragma UITableViewDelegate 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messageList count];
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
    cell.cellButton.tag = indexPath.row;
    
    if ([[[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userOne"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        [cell setUser:[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userTwo"]];
        [self.userNumberList addObject:@"userTwo"];
        cell.badgeLabel.text = [[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userOneBadge"] stringValue];
    } else {
        [cell setUser:[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userOne"]];
        [self.userNumberList addObject:@"userOne"];
        cell.badgeLabel.text = [[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userTwoBadge"] stringValue];
    }
    
    if ([cell.badgeLabel.text isEqualToString:@"0"]) {
        cell.badgeLabel.hidden = YES;
    } else {
        cell.badgeLabel.hidden = NO;
    }
    
    cell.lastMessageLabel.text = [[self.messageList objectAtIndex:indexPath.row] objectForKey:@"lastMessage"];
    //[cell.lastMessageLabel sizeToFit];
    
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
    
    [cell.cellButton addTarget:self action:@selector(cellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}



@end
