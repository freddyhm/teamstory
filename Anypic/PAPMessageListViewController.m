//
//  PAPMessageListViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 9/10/14.
//
//

#import "PAPMessageListViewController.h"
#import "PAPMessagingViewController.h"
#import "PAPMessagingSeachUsersViewController.h"

#define navBarHeight 64.0f
#define tabBarHeight 50.0f

@interface PAPMessageListViewController () {
    BOOL userOne;
}

@property (nonatomic, strong) UITableView *messageListTV;
@property (nonatomic, strong) NSArray *messageList;

@end

@implementation PAPMessageListViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    PFQuery *userOneQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userOneQuery whereKey:@"userOne" equalTo:[PFUser currentUser]];
    [userOneQuery whereKeyExists:@"lastMessage"];
    
    PFQuery *userTwoQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userTwoQuery whereKey:@"userTwo" equalTo:[PFUser currentUser]];
    [userTwoQuery whereKeyExists:@"lastMessage"];
    
    PFQuery *messageListQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userOneQuery, userTwoQuery, nil]];
    [messageListQuery orderByDescending:@"createdAt"];
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
    
    self.navigationItem.title = @"Messaging";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIImage *newMessageButtonImage = [UIImage imageNamed:@"button-feedback.png"];
    UIButton *newMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newMessageButton setFrame:CGRectMake(0.0f, 0.0f, newMessageButtonImage.size.width, newMessageButtonImage.size.height)];
    [newMessageButton setImage:newMessageButtonImage forState:UIControlStateNormal];
    [newMessageButton addTarget:self action:@selector(newMessageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:newMessageButton];
    
    self.messageListTV = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - navBarHeight - tabBarHeight)];
    [self.messageListTV setBackgroundColor:[UIColor whiteColor]];
    self.messageListTV.dataSource = self;
    self.messageListTV.delegate = self;
    self.messageListTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.messageListTV];
    
}

#pragma - () 

- (void) backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)newMessageButtonAction:(id)sender {
    PAPMessagingSeachUsersViewController *searchBarViewController = [[PAPMessagingSeachUsersViewController alloc] init];
    [searchBarViewController setNavigationController:self.navigationController];
    [self presentViewController:searchBarViewController animated:YES completion:nil];
    
    /*
    PAPMessagingViewController *messagingViewController = [[PAPMessagingViewController alloc] init];
    
    [self.navigationController presentViewController:messagingViewController animated:YES completion:nil];
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [self.navigationController pushViewController:messagingViewController animated:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
     */
}

-(void)cellButtonAction:(UIButton *)sender {
    PAPMessagingViewController *messageViewController = [[PAPMessagingViewController alloc] init];
    if (userOne) {
        [messageViewController setTargetUser:[[self.messageList objectAtIndex:sender.tag] objectForKey:@"userOne"]];
    } else {
        [messageViewController setTargetUser:[[self.messageList objectAtIndex:sender.tag] objectForKey:@"userTwo"]];
    }
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
        userOne = NO;
    } else {
        [cell setUser:[[self.messageList objectAtIndex:indexPath.row] objectForKey:@"userOne"]];
        userOne = YES;
    }
    cell.lastMessageLabel.text = [[self.messageList objectAtIndex:indexPath.row] objectForKey:@"lastMessage"];
    [cell.cellButton addTarget:self action:@selector(cellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}



@end
