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
#import "FollowersFollowingViewController.h"
#import "SVProgressHUD.h"

@interface PAPActivityFeedViewController ()

@property (nonatomic, strong) UIView *blankTimelineView;
@property int notificationCount;


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
        self.pullToRefreshEnabled = NO;
       
        // The number of objects to show per page
        self.objectsPerPage = 30;
        
        // Remove default loading indicator
        self.loadingViewEnabled = NO;
        
        //resets read list
        // [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"readList"];
        // [[NSUserDefaults standardUserDefaults] synchronize];
        
        // get read list from local storage
        self.readList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readList"] mutableCopy];
        
        // new read list if still in old mutable array format or nil
        if(self.readList == nil || [self.readList isKindOfClass:[NSMutableArray class]]){
            self.readList = [[NSMutableDictionary alloc]init];
            [[NSUserDefaults standardUserDefaults] setObject:self.readList forKey:@"readList"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }   
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [super viewDidLoad];
        
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
    

    self.tableView.bounces = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    // analytics
    [PAPUtility captureScreenGA:@"Activity"];
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    
    // reset badge number on server and activity bar when user checks activity feed and badge value is present
    if(self.navigationController.tabBarItem.badgeValue != nil){
        [self loadObjects];
        [self setActivityBadge:nil];
    }
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    
}
 
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        NSString *activityString = [[[object objectForKey:@"toUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]] ? [PAPActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kPAPActivityTypeKey] object:object] : NSLocalizedString(@"commented on your followed photo", nil);
        
        if ([[object objectForKey:@"atmention"] count] > 0) {
            for (int i = 0; i < [[object objectForKey:@"atmention"] count]; i++) {
                if ([[[[object objectForKey:@"atmention"] objectAtIndex:i] objectId] isEqualToString:[PFUser currentUser].objectId]) {
                    activityString = NSLocalizedString(@"mentioned you in a post", nil);
                    break;
                }
            }
        }
        
        if ([object objectForKey:@"forComment"] != nil){
            activityString = NSLocalizedString(@"liked your comment", nil);
        }
    
        PFUser *user = (PFUser*)[object objectForKey:kPAPActivityFromUserKey];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:kPAPUserDisplayNameKey] && [[user objectForKey:kPAPUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kPAPUserDisplayNameKey];
        }
        
        return [PAPActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 0.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
    
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        
        // get status from read list and update if necessary
        NSString *status = [[self.readList objectForKey:[activity objectId]] objectForKey:@"status"];
        if([status isEqualToString:@"unread"]){
            
            // check if photo is set first, if not use activity to mark as read (case for follows)
            if([activity objectForKey:@"photo"] != nil){
                [self updateReadList:[[activity objectForKey:@"photo"] objectId]];
            }else{
                [self updateReadList:[activity objectId]];
            }
            
        }

        if ([activity objectForKey:kPAPActivityPhotoKey]) {
            
            PAPPhotoDetailsViewController *detailViewController;
            
            if([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]){
                detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey] source:@"activityComment"];
            }else if([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLikeComment]){
                detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey] source:@"activityLikeComment"];
            }else{
                detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey] source:@"activity"];
            }
            
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
        if(![channel isEqualToString:@""]){
            NSString *photoId = [channel substringFromIndex:2];
            PFObject *pic = [PFObject objectWithoutDataWithClassName:@"Photo" objectId:photoId];
            [photos addObject:pic];
        }
    }
    
    // pull all activities to user
    PFQuery *personalQuery = [PFQuery queryWithClassName:self.parseClassName];
    [personalQuery whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
    
    // pull all activties from user's subscriptions
    PFQuery *subscriptionQuery = [PFQuery queryWithClassName:self.parseClassName];
    [subscriptionQuery whereKey:kPAPActivityToUserKey notEqualTo:[PFUser currentUser]];
    [subscriptionQuery whereKey:kPAPActivityPhotoKey containedIn:photos];
    [subscriptionQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[PFUser currentUser]];
    //NSPredicate *prediate = [NSPredicate predicateWithFormat:@"atmention.objectId contains %@", [PFUser currentUser].objectId];
    PFQuery *atmentionQuery = [PFQuery queryWithClassName:self.parseClassName];
    [atmentionQuery whereKey:@"atmention" containsAllObjectsInArray:array];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:@[personalQuery, subscriptionQuery, atmentionQuery]];
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

- (void)objectsWillLoad{
    [super objectsWillLoad];
    
    [SVProgressHUD show];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    [SVProgressHUD dismiss];
    
    // init read list with current objects
    if([self.readList count] == 0){
        for (int i = 0; i < self.objects.count; i++) {
            
            PFObject *pfObj = self.objects[i];

            NSMutableDictionary *activity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               @"read", @"status", [[pfObj objectForKey:@"photo"] objectId], @"photoId", nil];
             
             [self.readList setObject:activity forKey:[pfObj objectId]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:self.readList forKey:@"readList"];
    }else{
        
        /* out-of-sync occurs when:
           case (1) new items are loaded but read list is not updated -> push notifications
           case (2) read list tracks old items -> beyond 15 items (loaded by table) */
        
        // make sure loaded objects are present in read list
        for (PFObject *object in self.objects) {
            NSString *activityId = [object objectId];
            if([self.readList valueForKey:activityId] == nil){
                NSString *photoId = [[object objectForKey:@"photo"] objectId];
                [self addToReadList:photoId itemActivityId:activityId];
            }
        }
        
        // make sure read list is identical to loaded object list
        NSMutableArray *extraKeys = [[NSMutableArray alloc] init];
        for (NSString *activityId in self.readList) {
            
            if([self.objects valueForKey:activityId]){
                
                // check if activity id in loaded objects
                NSInteger indexOfObject = [self.objects indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop){
                    PFObject *object = (PFObject *)obj;
                    return [[object objectId] isEqualToString:activityId];
                }];
                
                if(indexOfObject == NSNotFound){
                    [extraKeys addObject:activityId];
                }
            }
        }
        
        // cannot delete while loop so get rid of excess items here
        if(extraKeys.count != 0){
            [self.readList removeObjectsForKeys:extraKeys];
            [[NSUserDefaults standardUserDefaults] setObject:self.readList forKey:@"readList"];
        }
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
    
    NSDictionary *readListItem = [self.readList valueForKey:[object objectId]];
    
    // safety check make sure read list has enough items
    NSString *activityStatus = [self.readList count] > indexPath.row ? [readListItem objectForKey:@"status"] : @"";
    
    if ([activityStatus isEqualToString:@"unread"] || [activityStatus isEqualToString:@""]) {
        [cell setIsNew:YES];
    }else if([activityStatus isEqualToString:@"read"]){
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
    
    PAPPhotoDetailsViewController *photoViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo source:@"activity"];
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)user {    
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}


#pragma mark - PAPActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType object:(PFObject *)object{
    if ([activityType isEqualToString:kPAPActivityTypeLike]) {
        return NSLocalizedString(@"liked your post", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeFollow]) {
        return NSLocalizedString(@"started following you", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeComment]) {
        if ([[object objectForKey:@"atmention"] count] > 0) {
            for (int i = 0; i < [[object objectForKey:@"atmention"] count]; i++) {
                if ([[[[object objectForKey:@"atmention"] objectAtIndex:i] objectId] isEqualToString:[PFUser currentUser].objectId]) {
                    return NSLocalizedString(@"mentioned you in a post", nil);
                    break;
                }
            }
            return NSLocalizedString(@"commented on your post", nil);
        } else {
            return NSLocalizedString(@"commented on your post", nil);
        }
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
    FollowersFollowingViewController *detailViewController = [[FollowersFollowingViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    
    NSString *photoId = [[note userInfo] objectForKey:@"pid"];
    NSString *activityId = [[note userInfo] objectForKey:@"aid"];
    NSString *pushSrc = [[note userInfo] objectForKey:@"source"];
    
    if(![pushSrc isEqualToString:@"konotor"]){
        
        // only for active, background notification are handled in app delegate
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            // load & fill on readlist init or set new unread
            [self addToReadList:photoId itemActivityId:activityId];
        }
        
        // always load objects when notification is received excl. konotor
        [self loadObjects];
    }
}



- (void)updateReadList:(NSString *)itemPhotoId{
    
    // load objects if read list is empty, fail safe
    if([self.readList count] == 0){
        [self loadObjects];
    }
    
    if([self.readList count] != 0){
        
        // update input item from read lsit
        for (id listItemKey in self.readList) {
            NSMutableDictionary *listItem = [self.readList objectForKey:listItemKey];
            NSString *listItemPhotoId = [listItem objectForKey:@"photoId"];
            
            if([listItemPhotoId isEqualToString:itemPhotoId]){
                [listItem setValue:@"read" forKey:@"status"];
            }
        }
        
        // save list locally & reload table
        [[NSUserDefaults standardUserDefaults] setObject:self.readList forKey:@"readList"];
        [self.tableView reloadData];
    }
}

- (void)addToReadList:(NSString *)itemPhotoId itemActivityId:(NSString *)itemActivityId{
    
    // edge case: when old notifications without aid get pushed
    if(itemActivityId != nil){
        
        NSDictionary *activity;
        
        // when photo id is missing replace with activity id, case for follower
        if(itemPhotoId != nil){
          activity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"unread", @"status",  itemPhotoId, @"photoId", nil];
        }else{
            activity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"unread", @"status",  itemActivityId, @"photoId", nil];
        }
        
        [self.readList setObject:activity forKey:itemActivityId];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.readList forKey:@"readList"];
    }
}


@end
