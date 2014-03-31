//
//  PAPActivityFeedViewController.m
//  Teamstory
//
//

#import "PAPActivityFeedViewController.h"
#import "PAPActivityCell.h"
#import "PAPAccountViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "PAPBaseTextCell.h"
#import "PAPLoadMoreCell.h"
#import "PAPSettingsButtonItem.h"
#import "PAPFindFriendsViewController.h"
#import "MBProgressHUD.h"

@interface PAPActivityFeedViewController ()

@property (nonatomic, strong) UIView *blankTimelineView;


@property int cellIndex;
@end

@implementation PAPActivityFeedViewController

@synthesize blankTimelineView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];    
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }

        // The number of objects to show per page
        self.objectsPerPage = 15;
        
        self.loadedWithViewNotification = YES;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [super viewDidLoad];
    
    self.navigationItem.title = @"Activity";
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"ActivityFeedBlank.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0f, 113.0f, 320.0f, 160.0f)];
    //[button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
    
    self.readList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readList"] mutableCopy];
    
    if(self.readList == nil){
        self.readList = [[NSMutableArray alloc]init];
        [[NSUserDefaults standardUserDefaults] setObject:self.readList forKey:@"readList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
    }
    
    self.tableView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    // analytics
    [PAPUtility captureScreenGA:@"Activity"];
    
    // reset badge number on server and activity bar when user checks activity feed and badge value is present
    if(self.navigationController.tabBarItem.badgeValue != nil){
        [self setActivityBadge:nil];
    }
    
    [self.tableView reloadData];
}
 
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [PAPActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kPAPActivityTypeKey]];

        PFUser *user = (PFUser*)[object objectForKey:kPAPActivityFromUserKey];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:kPAPUserDisplayNameKey] && [[user objectForKey:kPAPUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kPAPUserDisplayNameKey];
        }
        
        return [PAPActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.readList replaceObjectAtIndex:indexPath.row withObject:@"read"];
    [[NSUserDefaults standardUserDefaults] setObject:self.readList forKey:@"readList"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        if ([activity objectForKey:kPAPActivityPhotoKey]) {
            PAPPhotoDetailsViewController *detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else if ([activity objectForKey:kPAPActivityFromUserKey]) {
            PAPAccountViewController *detailViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [detailViewController setUser:[activity objectForKey:kPAPActivityFromUserKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    // select all activities from activity where type is comment and photo id IN [user channel array]
    NSArray *subscribedChannels = [PFInstallation currentInstallation].channels;
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    for (NSString *channel in subscribedChannels) {
        NSString *photoId = [channel substringFromIndex:2];
        PFObject *pic = [PFObject objectWithoutDataWithClassName:@"Photo" objectId:photoId];
        [photos addObject:pic];
    }
    
    
    // pull all activities to user
    PFQuery *personalQuery = [PFQuery queryWithClassName:self.parseClassName];
    [personalQuery whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
    
    // pull all activties from user's subscriptions
    PFQuery *subscriptionQuery = [PFQuery queryWithClassName:self.parseClassName];
    [subscriptionQuery whereKey:kPAPActivityToUserKey notEqualTo:[PFUser currentUser]];
    [subscriptionQuery whereKey:kPAPActivityPhotoKey containedIn:photos];
    [subscriptionQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:@[personalQuery,subscriptionQuery]];
    [finalQuery whereKey:kPAPActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [finalQuery whereKeyExists:kPAPActivityFromUserKey];
    
    [finalQuery includeKey:kPAPActivityFromUserKey];
    [finalQuery includeKey:kPAPActivityPhotoKey];
    [finalQuery orderByDescending:@"createdAt"];
    
    [finalQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    /*
    SEL isParseReachableSelector = NSSelectorFromString(@"isParseReachable");
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:isParseReachableSelector]) {
        NSLog(@"??");
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    */
    
    return finalQuery;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if([self.readList count] == 0){
        for (int i = 0; i < self.objects.count ; i++) {
            [self.readList addObject:@"read"];
        }
    }
    
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;

        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    
        if (self.view.window) {
            [self setActivityBadge:nil];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"ActivityCell";

    PAPActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PAPActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }

    if(![[[object objectForKey:@"toUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]){
        [cell setActivity:object isSubscription:YES];
    }else{
        [cell setActivity:object isSubscription:NO];
    }
    
    NSString *activityStatus = [self.readList objectAtIndex:indexPath.row];
    
    if ([activityStatus isEqualToString:@"unread"]) {
        [cell setIsNew:YES];
    } else if([activityStatus isEqualToString:@"read"]) {
        [cell setIsNew:NO];
    }

    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
   }
    return cell;
}


#pragma mark - PAPActivityCellDelegate Methods

- (void)cell:(PAPActivityCell *)cellView didTapActivityButton:(PFObject *)activity {    
    // Get image associated with the activity
    PFObject *photo = [activity objectForKey:kPAPActivityPhotoKey];
    
    // Push single photo view controller
    PAPPhotoDetailsViewController *photoViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo];
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)user {    
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}


#pragma mark - PAPActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kPAPActivityTypeLike]) {
        return NSLocalizedString(@"liked your photo", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeFollow]) {
        return NSLocalizedString(@"started following you", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeComment]) {
        return NSLocalizedString(@"commented on your photo", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeJoined]) {
        return NSLocalizedString(@"joined Teamstory", nil);
    } else {
        return nil;
    }
}


#pragma mark - ()

- (void)setActivityBadge:(NSString *)badge{

    self.navigationController.tabBarItem.badgeValue = badge;
    
    // Reset badge number on server side
    if(badge == nil){
        [[PFInstallation currentInstallation] setBadge:0];
        [[PFInstallation currentInstallation] saveEventually];
    }
}

- (void)inviteFriendsButtonAction:(id)sender {
    PAPFindFriendsViewController *detailViewController = [[PAPFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    
    NSString *pushSrc = [[note userInfo] objectForKey:@"source"];
    
    if(![pushSrc isEqualToString:@"konotor"]){
        [self notificationSetup];
    }
}

- (void)notificationSetup{
    [self.readList insertObject:@"unread" atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:self.readList forKey:@"readList"];
    [self loadObjects];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

@end
