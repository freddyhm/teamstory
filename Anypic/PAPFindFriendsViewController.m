//
//  PAPFindFriendsViewController.m
//  Teamstory
//
//

#import "PAPFindFriendsViewController.h"
#import "PAPProfileImageView.h"
#import "PAPLoadMoreCell.h"
#import "PAPAccountViewController.h"

typedef enum {
    PAPFindFriendsFollowingNone = 0,    // User isn't following anybody in Friends list
    PAPFindFriendsFollowingAll,         // User is following all Friends
    PAPFindFriendsFollowingSome         // User is following some of their Friends
} PAPFindFriendsFollowStatus;

@interface PAPFindFriendsViewController ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) NSString *type;
@property (nonatomic, assign) PAPFindFriendsFollowStatus followStatus;
@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;
@end

//static NSUInteger const kPAPCellFollowTag = 2;
//static NSUInteger const kPAPCellNameLabelTag = 3;
//static NSUInteger const kPAPCellAvatarTag = 4;
//static NSUInteger const kPAPCellPhotoNumLabelTag = 5;

@implementation PAPFindFriendsViewController
@synthesize headerView;
@synthesize followStatus;
@synthesize outstandingFollowQueries;
@synthesize outstandingCountQueries;
#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style type:(NSString *)type{
    self = [super initWithStyle:style];
    if (self) {
        
        self.type = type;
        
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
            
        // The number of objects to show per page
        self.objectsPerPage = 15;
        
        // Used to determine Follow/Unfollow All button status
        self.followStatus = PAPFindFriendsFollowingSome;
        
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
    
    PFQuery *query;
    
    if([self.type isEqualToString:@"following"]){
        
        /*
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
        
        PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
        
        [queryFollowingCount includeKey:kPAPActivityToUserKey];
        
        query = queryFollowingCount;
        
    }else if([self.type isEqualToString:@"followers"]){
        
        PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
        [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
        
        [queryFollowerCount includeKey:kPAPActivityFromUserKey];
        
        query = queryFollowerCount;
    }
    
    
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:kPAPUserDisplayNameKey];
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
        // get user objects based on type of screen
        NSMutableArray *results = [[NSMutableArray alloc]init];
    
        if([self.type isEqualToString:@"following"]){
            for (PFObject *obj in self.objects) {
                [results addObject:[obj objectForKey:kPAPActivityToUserKey]];
            }
            
            
        }else if([self.type isEqualToString:@"followers"]){
            for (PFObject *obj in self.objects) {
                [results addObject:[obj objectForKey:kPAPActivityFromUserKey]];
            }
        }
    
        PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [isFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [isFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [isFollowingQuery whereKey:kPAPActivityToUserKey containedIn:results];
        [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
        
        [isFollowingQuery includeKey:kPAPActivityToUserKey];
        
        [isFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *obj in objects) {
                    PFUser *followUser = [obj objectForKey:kPAPActivityToUserKey];
                    [[PAPCache sharedCache] setFollowStatus:YES user:followUser];
                }
            }
        }];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    PAPFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[PAPFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
    PFUser *followUser = [self.type isEqualToString:@"followers"] ? [object objectForKey:@"fromUser"]:[object objectForKey:@"toUser"];
    
    [cell setUser:followUser];
    
    NSDictionary *attributes = [[PAPCache sharedCache] attributesForUser:followUser];

    cell.followButton.selected = NO;
    cell.tag = indexPath.row;
    
    if (attributes) {
        [cell.followButton setSelected:[[PAPCache sharedCache] followStatusForUser:followUser]];
    }
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
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
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

- (void)followUsersTimerFired:(NSTimer *)timer {
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
}

@end
