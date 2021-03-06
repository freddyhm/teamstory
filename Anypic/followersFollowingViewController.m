//
//  PAPFindFriendsViewController.m
//  Teamstory
//
//

#import "FollowersFollowingViewController.h"
#import "PAPProfileImageView.h"
#import "PAPLoadMoreCell.h"
#import "PAPAccountViewController.h"
#import "SVProgressHUD.h"


@interface FollowersFollowingViewController ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) NSString *type;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) PFUser *selectedUser;
@property (nonatomic, strong) UILabel *emptyPlaceholder;
@property BOOL isSelectedUser;

@end

@implementation FollowersFollowingViewController
@synthesize headerView;
#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style type:(NSString *)type forUser:(PFUser *)user{
    self = [super initWithStyle:style];
    if (self) {
        
        self.type = type;
        self.selectedUser = user;
        self.isSelectedUser = [[self.selectedUser objectId] isEqualToString:[[PFUser currentUser] objectId]];

        // The number of objects to show per page
        self.objectsPerPage = 1000;
        
        // Remove default loading indicator
        self.loadingViewEnabled = NO;
        self.pullToRefreshEnabled = NO;
    }
    return self;
}



#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];
    
    self.navigationItem.title = [self.type isEqualToString:@"following"] ? @"Following" : @"Followers";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // Empty case placeholder, hidden by default
    self.emptyPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/3, self.view.frame.size.width, 40.0f)];
    self.emptyPlaceholder.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    [self.emptyPlaceholder setText:@"Uh Oh! Get to know more startups :)"];
    self.emptyPlaceholder.textAlignment = NSTextAlignmentCenter;
    [self.emptyPlaceholder setTextColor:[UIColor colorWithRed:178.0f/255.0f green:184.0f/255.0f blue:189.0f/255.0f alpha:1.0f]];
    self.emptyPlaceholder.hidden = YES;
    [self.view addSubview:self.emptyPlaceholder];
    
    [SVProgressHUD show];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        return [PAPFindFriendsCell heightForCell];
    } else {
        return 44.0f;
    }
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    /*
     
     // prepopulate list with facebook friends on teamstory
     
     // Use cached facebook friend ids
     NSArray *facebookFriends = [[PAPCache sharedCache] facebookFriends];
     
     // Query for all friends you have on facebook and who are using the app
     PFQuery *friendsQuery = [PFUser query];
     [friendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookFriends];
     
     // Query for all auto-follow accounts
     NSMutableArray *autoFollowAccountFacebookIds = [[NSMutableArray alloc] initWithArray:kPAPAutoFollowAccountFacebookIds];
     [autoFollowAccountFacebookIds removeObject:[[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]];
     PFQuery *teamstoryStaffQuery = [PFUser query];
     [teamstoryStaffQuery whereKey:kPAPUserFacebookIDKey containedIn:autoFollowAccountFacebookIds];
     */
    // Query for all current following
    
    //query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:friendsQuery, teamstoryStaffQuery, nil]];
    

    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    
    if([self.type isEqualToString:@"following"]){
        
        // get following for current user
        [query whereKey:kPAPActivityFromUserKey equalTo:self.selectedUser];
        [query includeKey:kPAPActivityToUserKey];
        
    }else if([self.type isEqualToString:@"followers"]){
        
        // get followers for current user
        [query whereKey:kPAPActivityToUserKey equalTo:self.selectedUser];
        [query includeKey:kPAPActivityFromUserKey];
    }
    
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query orderByDescending:@"createdAt"];
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // get user objects based on type of screen
    self.results = [[NSMutableArray alloc]init];
    
    // get proper users based on type
    NSString *targetUser = [self.type isEqualToString:@"following"] ? kPAPActivityToUserKey : kPAPActivityFromUserKey;

    for (PFObject *obj in self.objects) {
        // make sure the from/to key's value (user in list) is not nil
        if([obj objectForKey:targetUser] != nil){
            [self.results addObject:[obj objectForKey:targetUser]];
        }
    }
    
    // check if empty, show placeholder if so 
    if([self.results count] == 0){
        self.emptyPlaceholder.hidden = NO;
        [SVProgressHUD dismiss];
    }else{
        
        // check if current user is following the selected user's lists
        PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [isFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [isFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [isFollowingQuery whereKey:kPAPActivityToUserKey containedIn:self.results];
        [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
        
        [isFollowingQuery includeKey:kPAPActivityToUserKey];
        
        [isFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *obj in objects) {
                    PFUser *followUser = [obj objectForKey:kPAPActivityToUserKey];
                    [[PAPCache sharedCache] setFollowStatus:YES user:followUser];
                }
                
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            }
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    PAPFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[PAPFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
    PFUser *followUser = [self.type isEqualToString:@"followers"] ? [object objectForKey:@"fromUser"]:[object objectForKey:@"toUser"];
    
    [cell setUser:followUser];
    
    NSDictionary *attributes = [[PAPCache sharedCache] attributesForUser:followUser];
    
    cell.tag = indexPath.row;
    
    // toggle follow button based on cache, current user, and selected user
    if(![[followUser objectId] isEqualToString:[[PFUser currentUser] objectId]]){
        
        // make sure follow button is visible
        cell.followButton.hidden = NO;
        
        if (attributes) {
            [cell.followButton setSelected:[[PAPCache sharedCache] followStatusForUser:followUser]];
        }else if(self.isSelectedUser && [self.type isEqualToString:@"following"]){
            cell.followButton.selected = YES;
        }else{
            cell.followButton.selected = NO;
        }
        
    }else{
        // hide follow button for current user
        cell.followButton.hidden = YES;
    }
    
    /* // remove follow button for current user
     if(![[followUser objectId] isEqualToString:[[PFUser currentUser] objectId]]){
     if([self.type isEqualToString:@"following"]){
     cell.followButton.selected = YES;
     }else if (attributes) {
     [cell.followButton setSelected:[[PAPCache sharedCache] followStatusForUser:followUser]];
     }else{
     cell.followButton.selected = NO;
     }
     }else{
     cell.followButton.hidden = YES;
     }
*/

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *NextPageCellIdentifier = @"NextPageCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:NextPageCellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NextPageCellIdentifier];
        [cell.mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundFindFriendsCell.png"]]];
        cell.hideSeparatorBottom = YES;
        cell.hideSeparatorTop = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}


#pragma mark - PAPFindFriendsCellDelegate

- (void)cell:(PAPFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
;
    [accountViewController setUser:aUser];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(PAPFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser {
    [self shouldToggleFollowFriendForCell:cellView];
}


#pragma mark - ()

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shouldToggleFollowFriendForCell:(PAPFindFriendsCell*)cell {
    
    // temp disable follow button to avoid duplicates
    cell.followButton.enabled = NO;
    
    PFUser *cellUser = cell.user;
    if ([cell.followButton isSelected]) {
        // Unfollow
        cell.followButton.selected = NO;
        [PAPUtility unfollowUserEventually:cellUser block:^(BOOL succeeded) {
            
            // enable button again
            cell.followButton.enabled = YES;

        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        cell.followButton.selected = YES;
        [PAPUtility followUserEventually:cellUser setNavigationController:self.navigationController block:^(BOOL succeeded, NSError *error) {
            
            // enable button again
            cell.followButton.enabled = YES;
            
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            } else {
                cell.followButton.selected = NO;
            }
        }];
    }
}

- (void)followUsersTimerFired:(NSTimer *)timer {
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
}

@end
