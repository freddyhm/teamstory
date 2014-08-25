//
//  discoverPageViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 1/10/14.
//
//

#import "discoverPageViewController.h"
#import "PAPFindFriendsCell.h"
#import "PAPAccountViewController.h"
#import "PAPdiscoverTileView.h"

#define screenWidth 320.0f

NSInteger selection = 1;

@interface discoverPageViewController() {
    BOOL isSearchString;
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *searchOptionBgView;
@property (nonatomic, strong) UIView *searchMovementBar;
@property (nonatomic, strong) UIButton *usersLabel;
@property (nonatomic, strong) UIButton *industryLabel;
@property (nonatomic, strong) UIView *searchOptionView;
@property (nonatomic, strong) UITableView *searchTV;
@property (nonatomic, strong) NSArray *industry_datasource;
@property (nonatomic, strong) NSString *searchSelection;
@property (nonatomic, strong) NSArray *userList;
@property (nonatomic, strong) NSMutableArray *userFilterList;
@property (nonatomic, strong) NSArray *follwerList;
@property (nonatomic, strong) NSArray *postPicQueryResults;
@property (nonatomic, strong) NSArray *postThoughtQueryResults;
@property (nonatomic, strong) NSArray *postActivityQueryResults;
@property (nonatomic, strong) PAPdiscoverTileView *discoverTileView;

@end

@implementation discoverPageViewController

- (void)viewDidLoad
{
    self.userFilterList = [[NSMutableArray alloc] init];
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    self.navigationController.navigationBar.hidden = YES;
    
    UIView *navBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth, 20.0f)];
    [navBackground setBackgroundColor:teamStoryColor];
    [self.view addSubview:navBackground];
    
    
    // --------------- Search option menu
    
    self.searchOptionBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 20.0f, screenWidth, 44.0f)];
    [self.searchOptionBgView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    [self.view addSubview:self.searchOptionBgView];
    
    self.searchOptionView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, screenWidth - 10.0f, 34.0f)];
    [self.searchOptionView setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    self.searchOptionView.layer.cornerRadius = 5.0f;
    [self.searchOptionBgView addSubview:self.searchOptionView];
    
    self.searchMovementBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height)];
    [self.searchMovementBar setBackgroundColor:[UIColor whiteColor]];
    self.searchMovementBar.layer.cornerRadius = 5.0f;
    self.searchMovementBar.layer.borderWidth = 1.0f;
    self.searchMovementBar.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [self.searchOptionView addSubview:self.searchMovementBar];
    
    self.searchSelection = @"users";
    
    self.usersLabel = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height)];
    [self.usersLabel setTitle:@"Users" forState:UIControlStateNormal];
    self.usersLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.usersLabel setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.usersLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.usersLabel addTarget:self action:@selector(usersLabelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchOptionView addSubview:self.usersLabel];
    
    self.industryLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.searchOptionView.bounds.size.width / 2, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height)];
    [self.industryLabel setTitle:@"Industries" forState:UIControlStateNormal];
    self.industryLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.industryLabel setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.industryLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.industryLabel addTarget:self action:@selector(industryLabelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchOptionView addSubview:self.industryLabel];
    
    // --------------- Searchbar
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 20.0f, screenWidth, 44.0f)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search users and industry";
    self.searchBar.barTintColor = teamStoryColor;
    self.searchBar.backgroundColor = teamStoryColor;
    self.searchBar.layer.borderColor = teamStoryColor.CGColor;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.searchBar setImage:[UIImage imageNamed:@"icon_search.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.view addSubview:self.searchBar];
    
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    
    // --------------- UITableView
    self.industry_datasource = [NSArray arrayWithObjects:@"Information Technology", @"Consumers", @"Enterprises", @"Media", @"Education", @"Health Care", @"Finance", @"Sales and Marketing", @"Fashion", @"Health and Wellness", @"Retail", @"Sports", @"UI/UX Design", @"Travel", @"Web Development", @"Real Estate", @"Recruiting", @"Entertainment", @"Clean Technology", @"Events", @"B2B", @"Restaurants", @"Lifestyle", @"Big Data Analytics", @"Music Services", @"Event Management", @"Non Profits", @"Discovery", @"Incubators", @"Other", nil];
    
    
    float tableViewSP = self.searchBar.bounds.size.height + self.searchOptionBgView.bounds.size.height + 20;
    float tabBarHeight = 30.0f;
    float tableViewHeight = [UIScreen mainScreen].bounds.size.height - (tabBarHeight + tableViewSP);
    
    self.searchTV = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, tableViewSP, screenWidth, tableViewHeight) style:UITableViewStylePlain];
    self.searchTV.delegate = self;
    self.searchTV.dataSource = self;
    self.searchTV.hidden = YES;
    self.searchTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchTV.userInteractionEnabled = YES;
    [self.view addSubview:self.searchTV];
    
    
    // -------------- UIMainView
    self.discoverTileView = [[PAPdiscoverTileView alloc] initWithFrame:CGRectMake(0.0f, 20 + self.searchBar.bounds.size.height, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.height - (20 + self.searchBar.bounds.size.height + tabBarHeight))];
    [self.discoverTileView setNavigationController:self.navigationController];
    [self.view addSubview:self.discoverTileView];
    
	   
}

- (void)viewWillAppear:(BOOL)animated{
    // analytics
    [PAPUtility captureScreenGA:@"Discover"];
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    self.navigationController.navigationBar.hidden = YES;
    
    NSDate *currentDate = [NSDate date];
    NSDate *sevenDaysAgo = [currentDate dateByAddingTimeInterval:-7*24*60*60];
    
    PFQuery *postQuery_pic = [PFQuery queryWithClassName:@"Photo"];
    [postQuery_pic setLimit:21];
    [postQuery_pic whereKey:@"type" equalTo:@"picture"];
    [postQuery_pic whereKey:@"createdAt" greaterThanOrEqualTo:sevenDaysAgo];
    [postQuery_pic findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.postPicQueryResults = objects;
            
            PFQuery *postQuery_thoughts = [PFQuery queryWithClassName:@"Photo"];
            [postQuery_thoughts setLimit:21];
            [postQuery_thoughts whereKey:@"type" equalTo:@"thought"];
            [postQuery_thoughts whereKey:@"createdAt" greaterThanOrEqualTo:sevenDaysAgo];
            [postQuery_thoughts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    self.postThoughtQueryResults = objects;
                    
                    PFQuery *postActivity = [PFQuery queryWithClassName:@"Activity"];
                    [postActivity setLimit:MAXFLOAT];
                    [postActivity whereKey:@"createdAt" greaterThan:sevenDaysAgo];
                    [postActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            self.postActivityQueryResults = objects;
                            
                            
                            // Do calculations and send the query list from here
                            [self.discoverTileView setPictureQuery:self.postPicQueryResults setThoughtQuery:self.postThoughtQueryResults setActivityQuery:self.postActivityQueryResults];
                        } else {
                            NSLog(@"Post Activity Query Error: %@", error);
                        }
                    }];
                } else {
                    NSLog(@"PostQuery Picture Error: %@", error);
                }
            }];
        } else {
            NSLog(@"PostQuery Picture Error: %@", error);
        }
    }];
    
    if ([self.follwerList count] == 0) {
        PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
        [activityQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [activityQuery whereKey:@"type" equalTo:@"follow"];
        activityQuery.limit = MAXFLOAT;
        [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.follwerList = objects;
                
                PFQuery *userQuery = [PFUser query];
                userQuery.limit = MAXFLOAT;
                [userQuery whereKeyExists:@"displayName"];
                [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        NSLog(@"User data Successfully Loaded");
                        self.userList = objects;
                        [self.searchTV reloadData];
                    } else {
                        NSLog(@"User query error: %@", error);
                    }
                }];
            } else {
                NSLog(@"Activity Query Error: %@", error);
            }
        }];
    }
    
    
}

#pragma - ()

-(void)usersLabelAction:(id)sender {
    [self labelSetting:@"users"];
    [self.searchTV reloadData];
    [UIView animateWithDuration:0.2f animations:^{
        self.searchMovementBar.frame = CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height);
    }];
}

-(void)industryLabelAction:(id)sender {
    [self labelSetting:@"industry"];
    [self.searchTV reloadData];
    [UIView animateWithDuration:0.2f animations:^{
        self.searchMovementBar.frame = CGRectMake(self.searchOptionView.bounds.size.width / 2, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height);
    }];
}

-(void) labelSetting:(NSString *)selected {
    if ([selected isEqualToString:@"users"]) {
        self.usersLabel.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.industryLabel.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        self.searchSelection = @"users";
        self.searchBar.placeholder = @"Search users";
    } else {
        self.industryLabel.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.usersLabel.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        self.searchSelection = @"industry";
        self.searchBar.placeholder = @"Search industry";
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [self searchTableList];
}


- (void)searchTableList {
    NSString *searchString = self.searchBar.text;
    if ([searchString length] > 0) {
        [self.userFilterList addObjectsFromArray:[self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", searchString]]];
    }
}


# pragma UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.discoverTileView.hidden = YES;
    self.searchTV.hidden = NO;
    self.searchBar.showsCancelButton = YES;
    self.searchMovementBar.frame = CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height);
    [self labelSetting:@"users"];
    self.searchBar.placeholder = @"Search users";
    [UIView animateWithDuration:0.2f animations:^{
        self.searchOptionBgView.frame = CGRectMake(0.0f, 64.0f, screenWidth, 44.0f);
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.discoverTileView.hidden = NO;
    self.searchTV.hidden = YES;
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = nil;
    self.searchBar.placeholder = @"Search users and industry";
    [self.searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.searchOptionBgView.frame = CGRectMake(0.0f, 20.0f, screenWidth, 44.0f);
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //Remove all objects first.
    [self.userFilterList removeAllObjects];
    
    if([searchText length] != 0) {
        isSearchString = YES;
        [self searchTableList];
    }
    else {
        isSearchString = NO;
    }
    [self.searchTV reloadData];
}

#pragma UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.searchSelection isEqualToString:@"users"]) {
        return [PAPFindFriendsCell heightForCell];
    } else {
        return 44.0f;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([self.searchSelection isEqualToString:@"users"]) {
        if (isSearchString) {
            return [self.userFilterList count];
        } else {
            return [self.userList count];
        }
    } else {
        return [self.industry_datasource count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    if ([self.searchSelection isEqualToString:@"users"]) {
        static NSString *FriendCellIdentifier = @"FriendCell";
        
        PAPFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
        if (cell == nil) {
            cell = [[PAPFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
            cell.delegate = self;
        }
        
        
        if (isSearchString) {
            //Searching for followers
            for (int i = 0; i < [self.follwerList count]; i++) {
                if ([[[[self.follwerList objectAtIndex:i] objectForKey:@"toUser"] objectId] isEqualToString:[[self.userFilterList objectAtIndex:indexPath.row] objectId]]) {
                    cell.followButton.selected = YES;
                    break;
                } else {
                    cell.followButton.selected = NO;
                }
            }
            
            if ([[[self.userFilterList objectAtIndex:indexPath.row] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                cell.followButton.hidden = YES;
            }
            [cell setUser:[self.userFilterList objectAtIndex:indexPath.row]];
        } else {
            //Searching for followers
            for (int i = 0; i < [self.follwerList count]; i++) {
                if ([[[[self.follwerList objectAtIndex:i] objectForKey:@"toUser"] objectId] isEqualToString:[[self.userList objectAtIndex:indexPath.row] objectId]]) {
                    cell.followButton.selected = YES;
                    break;
                } else {
                    cell.followButton.selected = NO;
                }
            }
            if ([[[self.userList objectAtIndex:indexPath.row] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                cell.followButton.hidden = YES;
            }
            [cell setUser:[self.userList objectAtIndex:indexPath.row]];
        }
    
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [self.industry_datasource objectAtIndex:indexPath.row];
        return cell;
    }
    
}

#pragma mark - PAPFindFriendsCellDelegate

- (void)cell:(PAPFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
    ;
    [accountViewController setUser:aUser];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(PAPFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser {
    [self shouldToggleFollowFriendForCell:cellView];
}

- (void)shouldToggleFollowFriendForCell:(PAPFindFriendsCell*)cell {
    PFUser *cellUser = cell.user;
    if ([cell.followButton isSelected]) {
        // Unfollow
        cell.followButton.selected = NO;
        [PAPUtility unfollowUserEventually:cellUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        cell.followButton.selected = YES;
        [PAPUtility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            } else {
                cell.followButton.selected = NO;
            }
        }];
    }
}


@end
