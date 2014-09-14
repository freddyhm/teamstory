//
//  PAPMessagingSeachUsersViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 9/11/14.
//
//

#import "PAPMessagingSeachUsersViewController.h"

#define headerViewHeight 64.0f

@interface PAPMessagingSeachUsersViewController () {
    BOOL isSearchString;
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *followUserList;
@property (nonatomic, strong) UITableView *followerTV;
@property (nonatomic, strong) NSMutableArray *filterFollowUserList;
@property (nonatomic, strong) UINavigationController *navController;

@end

@implementation PAPMessagingSeachUsersViewController

- (void) setNavigationController:(UINavigationController *)navController {
    self.navController = navController;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.filterFollowUserList = [[NSMutableArray alloc] init];
    
    PFQuery *followerQuery = [PFQuery queryWithClassName:@"Activity"];
    [followerQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [followerQuery whereKeyExists:@"toUser"];
    [followerQuery whereKey:@"type" equalTo:@"follow"];
    [followerQuery includeKey:@"toUser.User"];
    [followerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"call successful");
            self.followUserList = objects;
            [self.followerTV reloadData];
        } else {
            NSLog(@"Query Calling Error %@", error);
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isSearchString = NO;
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, headerViewHeight)];
    headerView.backgroundColor = teamStoryColor;
    [self.view addSubview:headerView];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, (headerView.bounds.size.height - 20) / 2 - 15.0f, 60.0f, 30.0f)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:cancelButton];
    
    UIButton *okayButton = [[UIButton alloc] initWithFrame:CGRectMake(headerView.bounds.size.width - 60.0f, (headerView.bounds.size.height - 20) / 2 - 15.0f, 50.0f, 30.0f)];
    [okayButton setTitle:@"Okay" forState:UIControlStateNormal];
    [okayButton addTarget:self action:@selector(okayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:okayButton];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, headerViewHeight, [UIScreen mainScreen].bounds.size.width, 40.0f)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search by following users";
    [self.view addSubview:self.searchBar];
    
    self.followerTV = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, headerViewHeight + self.searchBar.bounds.size.height, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.height - headerViewHeight - self.searchBar.bounds.size.height)];
    self.followerTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.followerTV.backgroundColor = [UIColor whiteColor];
    self.followerTV.delegate = self;
    self.followerTV.dataSource = self;
    [self.view addSubview:self.followerTV];
     
    
}


# pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearchString) {
        return [self.filterFollowUserList count];
    } else {
        return [self.followUserList count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.followUserList.count) {
        return [PAPFindFriendsCell heightForCell];
    } else {
        return 44.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MessageUserListCell";
    
    PAPFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.followUserList.count > 0 ){
        if (isSearchString) {
            [cell setUser:[[self.filterFollowUserList objectAtIndex:indexPath.row] objectForKey:@"toUser"]];
        } else {
            [cell setUser:[[self.followUserList objectAtIndex:indexPath.row] objectForKey:@"toUser"]];
        }
        [cell setDelegate:self];
        cell.followButton.hidden = YES;
        cell.tag = indexPath.row;
    }
    
    return cell;
}

# pragma PAPFindFriendsCellDelegate 
- (void)cell:(PAPFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self dismissViewControllerAnimated:NO completion:^{
        PAPMessagingViewController *messageViewController = [[PAPMessagingViewController alloc] init];
        [messageViewController setTargetUser:aUser];
        [self.navController pushViewController:messageViewController animated:NO];
    }];
}

# pragma UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //Remove all objects first.
    [self.filterFollowUserList removeAllObjects];
    
    if([searchText length] != 0) {
        isSearchString = YES;
        [self searchTableList];
    } else {
        isSearchString = NO;
    }
    
    [self.followerTV reloadData];
}


# pragma - ()

- (void)searchTableList {
    NSString *searchString = self.searchBar.text;
    
    [self.filterFollowUserList addObjectsFromArray:[self.followUserList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"toUser.displayName contains[c] %@", searchString]]];
    
}

- (void) okayButtonAction:(id)sender {
    
}

- (void) cancelButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
