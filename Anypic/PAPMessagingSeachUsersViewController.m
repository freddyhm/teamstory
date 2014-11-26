//
//  PAPMessagingSeachUsersViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 9/11/14.
//
//

#import "PAPMessagingSeachUsersViewController.h"
#import "SVProgressHUD.h"

#define headerViewHeight 64.0f
#define querySelectionViewheight 37.5f

@interface PAPMessagingSeachUsersViewController () {
    BOOL isSearchString;
    int limit;
    int skip;
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *followUserList;
@property (nonatomic, strong) UITableView *followerTV;
@property (nonatomic, strong) NSMutableArray *filterFollowUserList;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) UIView *querySelectionView;
@property (nonatomic, strong) UILabel *querySelectionViewOptionFollower;
@property (nonatomic, strong) UIButton *followerButton;
@property (nonatomic, strong) UIButton *allUserButton;
@property (nonatomic, strong) UIView *querySelectionOptionViewBG;
@property (nonatomic, strong) UILabel *queryselectionViewoptionEveryone;
@property (nonatomic, strong) NSString *querySelectionString;
@property (nonatomic, strong) UIView *querySelectionMovementView;
@property (nonatomic, strong) NSMutableArray *userList;
@property (nonatomic, strong) NSMutableArray *filterUserList;

@end

@implementation PAPMessagingSeachUsersViewController

- (void) setNavigationController:(UINavigationController *)navController {
    self.navController = navController;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [SVProgressHUD show];
    
    self.filterFollowUserList = [[NSMutableArray alloc] init];
    self.userList = [[NSMutableArray alloc] init];
    self.followUserList = [[NSMutableArray alloc] init];
    self.filterUserList = [[NSMutableArray alloc] init];
    
    PFQuery *followerQuery = [PFQuery queryWithClassName:@"Activity"];
    [followerQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [followerQuery whereKeyExists:@"toUser"];
    [followerQuery whereKey:@"type" equalTo:@"follow"];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [followingQuery whereKeyExists:@"fromUser"];
    [followingQuery whereKey:@"type" equalTo:@"follow"];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:followerQuery, followingQuery, nil]];
    [finalQuery includeKey:@"fromUser.User"];
    [finalQuery includeKey:@"toUser.User"];
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [SVProgressHUD dismiss];
            for (int i = 0; i < objects.count; i++) {
                if ([[[objects[i] objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                    if ([self.filterUserList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", [[objects[i] objectForKey:@"toUser"] objectForKey:@"displayName"]]].count <= 0) {
                        [self.filterUserList addObject:[objects[i] objectForKey:@"toUser"]];
                        [self.followUserList addObject:objects[i]];
                    }
                } else {
                    if ([self.filterUserList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", [[objects[i] objectForKey:@"fromUser"] objectForKey:@"displayName"]]].count <= 0) {
                        [self.filterUserList addObject:[objects[i] objectForKey:@"fromUser"]];
                        [self.followUserList addObject:objects[i]];
                    }
                }
            }
            [self.followerTV reloadData];
        } else {
            NSLog(@"Query Calling Error %@", error);
        }
    }];
    
    limit = 1000;
    skip = 0;
    [self userQueryPagination];
    
}

-(void) userQueryPagination {
    [self.userList removeAllObjects];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKeyExists:@"displayName"];
    [userQuery whereKey:@"displayName" notEqualTo:[[PFUser currentUser] objectForKey:@"displayName"]];
    [userQuery orderByDescending:@"updatedAt"];
    [userQuery setLimit:limit];
    [userQuery setSkip:skip];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.userList addObjectsFromArray:objects];
            if (objects.count == limit) {
                skip += limit;
                [userQuery setSkip:skip];
                [userQuery findObjectsInBackgroundWithTarget:self selector:@selector(userQueryPagination)];
            } else if ([self.querySelectionString isEqualToString:@"Everyone"]) {
                [self.followerTV reloadData];
            }
        } else {
            NSLog(@"User query error: %@", error);
        }
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    isSearchString = NO;
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, headerViewHeight)];
    headerView.backgroundColor = teamStoryColor;
    [self.view addSubview:headerView];
    
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (headerView.bounds.size.height - 20) / 2, [UIScreen mainScreen].bounds.size.width, 30.0f)];
    [navLabel setText:@"Choose User"];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [headerView addSubview:navLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, (headerView.bounds.size.height - 11) / 2, 22.0f, 22.0f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backButton];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, headerViewHeight + querySelectionViewheight, [UIScreen mainScreen].bounds.size.width, 40.0f)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search";
    self.searchBar.barTintColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.searchBar.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
    [self.view addSubview:self.searchBar];
    
    CGRect rect = self.searchBar.frame;
    UIView *topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, 1)];
    topLineView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    [self.searchBar addSubview:topLineView];
    
    UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, rect.size.height - 1, rect.size.width, 1)];
    bottomLineView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    [self.searchBar addSubview:bottomLineView];
    
    self.followerTV = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, headerViewHeight + querySelectionViewheight + self.searchBar.bounds.size.height, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.height - headerViewHeight - querySelectionViewheight - self.searchBar.bounds.size.height)];
    self.followerTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.followerTV.backgroundColor = [UIColor whiteColor];
    self.followerTV.delegate = self;
    self.followerTV.dataSource = self;
    [self.view addSubview:self.followerTV];
    
    self.querySelectionString = @"Follower";
    
    self.querySelectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, headerViewHeight, [UIScreen mainScreen].bounds.size.width, querySelectionViewheight)];
    self.querySelectionView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    [self.view addSubview:self.querySelectionView];
    
    self.querySelectionOptionViewBG = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, self.querySelectionView.bounds.size.width - 10.0f, self.querySelectionView.bounds.size.height - 10.0f)];
    self.querySelectionOptionViewBG.layer.cornerRadius = 3.0f;
    self.querySelectionOptionViewBG.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    [self.querySelectionView addSubview:self.querySelectionOptionViewBG];
    
    self.followerButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.querySelectionOptionViewBG.bounds.size.width / 2, self.querySelectionOptionViewBG.bounds.size.height)];
    [self.followerButton addTarget:self action:@selector(followerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.followerButton setTitle:@"List" forState:UIControlStateNormal];
    self.followerButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.followerButton setTitleColor:[UIColor colorWithWhite:0.4f alpha:1.0f] forState:UIControlStateNormal];

    
    self.allUserButton = [[UIButton alloc] initWithFrame:CGRectMake(self.querySelectionOptionViewBG.bounds.size.width / 2, 0.0f, self.querySelectionOptionViewBG.bounds.size.width / 2, self.querySelectionOptionViewBG.bounds.size.height)];
    [self.allUserButton addTarget:self action:@selector(allUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.allUserButton setTitle:@"Everyone" forState:UIControlStateNormal];
    self.allUserButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.allUserButton setTitleColor:[UIColor colorWithWhite:0.4f alpha:1.0f] forState:UIControlStateNormal];

    
    self.querySelectionMovementView = [[UIView alloc] initWithFrame:self.followerButton.frame];
    self.querySelectionMovementView.backgroundColor = [UIColor whiteColor];
    self.querySelectionMovementView.layer.borderWidth = 2.0f;
    self.querySelectionMovementView.layer.cornerRadius = 5.0f;
    self.querySelectionMovementView.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    self.querySelectionMovementView.clipsToBounds = YES;
    
    [self.querySelectionOptionViewBG addSubview:self.querySelectionMovementView];
    [self.querySelectionOptionViewBG addSubview:self.allUserButton];
    [self.querySelectionOptionViewBG addSubview:self.followerButton];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
}


-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)followerButtonAction:(id)sender {
    self.querySelectionString = @"Follower";
    [self.followerTV reloadData];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.querySelectionMovementView.frame = self.followerButton.frame;
    }];
}

-(void) allUserButtonAction:(id)sender {
    self.querySelectionString = @"Everyone";
    [self.followerTV reloadData];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.querySelectionMovementView.frame = self.allUserButton.frame;
    }];
}


# pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearchString) {
        return [self.filterFollowUserList count];
    } else if (!isSearchString && [self.querySelectionString isEqualToString:@"Follower"]){
        return [self.followUserList count];
    } else {
        return [self.userList count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PAPFindFriendsCell heightForCell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MessageUserListCell";
    
    PAPFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.followUserList.count > 0 && [self.querySelectionString isEqualToString:@"Follower"]){
        if (isSearchString) {
            if ([[[PFUser currentUser] objectId] isEqualToString:[[[self.filterFollowUserList objectAtIndex:indexPath.row] objectForKey:@"toUser"] objectId]]) {
                [cell setUser:[[self.filterFollowUserList objectAtIndex:indexPath.row] objectForKey:@"fromUser"]];
            } else {
                [cell setUser:[[self.filterFollowUserList objectAtIndex:indexPath.row] objectForKey:@"toUser"]];
            }
        } else {
            if ([[[PFUser currentUser] objectId] isEqualToString:[[[self.followUserList objectAtIndex:indexPath.row] objectForKey:@"toUser"] objectId]]) {
                [cell setUser:[[self.followUserList objectAtIndex:indexPath.row] objectForKey:@"fromUser"]];
            } else {
                [cell setUser:[[self.followUserList objectAtIndex:indexPath.row] objectForKey:@"toUser"]];
            }
            
        }
        [cell setDelegate:self];
        cell.followButton.hidden = YES;
        cell.tag = indexPath.row;
    } else if (self.userList.count > 0 && [self.querySelectionString isEqualToString:@"Everyone"]) {
        if (isSearchString) {
            [cell setUser:[self.filterFollowUserList objectAtIndex:indexPath.row]];
        } else {
            [cell setUser:[self.userList objectAtIndex:indexPath.row]];
        }
        [cell setDelegate:self];
        cell.followButton.hidden = YES;
        cell.tag = indexPath.row;
    }
    
    return cell;
}

# pragma PAPFindFriendsCellDelegate 
- (void)cell:(PAPFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    [SVProgressHUD show];
    
    PFQuery *userOneQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userOneQuery whereKey:@"userOne" equalTo:[PFUser currentUser]];
    [userOneQuery whereKey:@"userTwo" equalTo:aUser];
    
    // Received Message
    PFQuery *userTwoQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [userTwoQuery whereKey:@"userOne" equalTo:aUser];
    [userTwoQuery whereKey:@"userTwo" equalTo:[PFUser currentUser]];
    
    PFQuery *finalChatRoomQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userOneQuery, userTwoQuery,nil]];
    [finalChatRoomQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [SVProgressHUD dismiss];
        
        if (!error) {
            [self dismissViewControllerAnimated:NO completion:^{
                PAPMessagingViewController *messageViewController = [[PAPMessagingViewController alloc] init];
                NSString *userNumber;
                
                if ([[[object objectForKey:@"userOne"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                    [object setObject:[NSNumber numberWithBool:YES] forKey:@"userOneShowChatRoom"];
                    userNumber = @"userTwo";
                } else {
                    [object setObject:[NSNumber numberWithBool:YES] forKey:@"userTwoShowChatRoom"];
                    userNumber = @"userOne";
                }
                
                [object saveInBackground];
                
                [messageViewController setTargetUser:aUser setUserNumber:userNumber];
                [messageViewController setRoomInfo:object];
                [self.navController pushViewController:messageViewController animated:NO];
            }];
        } else {
            if ([error code] == 101) { // Error code 101 is "no query matched".
                PFObject *createChatRoom = [PFObject objectWithClassName:@"ChatRoom"];
                [createChatRoom setObject:[PFUser currentUser] forKey:@"userOne"];
                [createChatRoom setObject:aUser forKey:@"userTwo"];
                
                // setACL;
                PFACL *chatRoomACL = [PFACL ACLWithUser:[PFUser currentUser]];
                [chatRoomACL setPublicWriteAccess:YES];
                [chatRoomACL setPublicReadAccess:YES];
                createChatRoom.ACL = chatRoomACL;
                
                [createChatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [self dismissViewControllerAnimated:NO completion:^{
                            PAPMessagingViewController *messageViewController = [[PAPMessagingViewController alloc] init];
                            [messageViewController setTargetUser:aUser setUserNumber:@"userTwo"];
                            [messageViewController setRoomInfo:createChatRoom];
                            [self.navController pushViewController:messageViewController animated:NO];
                        }];
                    } else {
                        NSLog(@"%@", error);
                    }
                }];
            } else {
                NSLog(@"%@", error);
            }
        }
    }];
}

# pragma UISearchBarDelegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.followerTV.frame = CGRectMake(0.0f, headerViewHeight + querySelectionViewheight + self.searchBar.bounds.size.height, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.height - headerViewHeight - querySelectionViewheight - self.searchBar.bounds.size.height - 216.0f);
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.followerTV.frame = CGRectMake(0.0f, headerViewHeight + querySelectionViewheight + self.searchBar.bounds.size.height, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.height - headerViewHeight - querySelectionViewheight - self.searchBar.bounds.size.height);
}

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
    
    if ([self.querySelectionString isEqualToString:@"Follower"]){
        [self.filterFollowUserList addObjectsFromArray:[self.followUserList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"toUser.displayName contains[c] %@", searchString]]];
    } else {
        [self.filterFollowUserList addObjectsFromArray:[self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", searchString]]];
    }
    
}

- (void) cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
