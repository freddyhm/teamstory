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
#import "Mixpanel.h"
#import <FlightRecorder/FlightRecorder.h>
#import "SVProgressHUD.h"

@interface PAPActivityFeedViewController ()

@property (nonatomic, strong) UIView *blankTimelineView;
@property (nonatomic, strong) UIRefreshControl *refreshFeedControl;
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
        
        // disable PFQueryTable's default refresh implementation
        self.pullToRefreshEnabled = NO;
       
        // the number of objects to show per page
        self.objectsPerPage = 30;
        
        // remove default loading indicator
        self.loadingViewEnabled = NO;
        
        // set the readlist
        [self setActivityReadList];
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
    [self.navigationItem.titleView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapNavTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTop)];
    [self.navigationItem.titleView addGestureRecognizer:tapNavTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    
    // pull-to-refresh
    self.refreshFeedControl = [[UIRefreshControl alloc] init];
    self.refreshFeedControl.tintColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:0.5f];
    [self.refreshFeedControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    self.refreshFeedControl.backgroundColor = [UIColor whiteColor];
    [self.tableView addSubview:self.refreshFeedControl];
    
    // creating view for extending white background
    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    UIView* bgView = [[UIView alloc] initWithFrame:frame];
    bgView.backgroundColor = [UIColor whiteColor];
    
    // adding the view below the refresh control
    [self.tableView insertSubview:bgView atIndex:0];

    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"ActivityFeedBlank.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0f, 113.0f, 320.0f, 160.0f)];
    //[button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
    

    self.tableView.bounces = YES;
}

- (void)viewWillAppear:(BOOL)animated {
        
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Activity"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"activity_screen" action:@"viewing_activity" label:@"" value:@""];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"Activity"];

    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    
    // reset badge number on server and activity bar when user checks activity feed and badge value is present
    if(self.navigationController.tabBarItem.badgeValue != nil){
        [self setActivityBadge:nil];
        [self loadObjects];
    }
    
   
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    
}
 
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString;
        
        BOOL hasToUser = [[[object objectForKey:@"toUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]];
        BOOL isPostType = [[object objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypePosted];
        
        // check if subscription (no toUser) and if it's of type post or not (follower vs comment)
        if(!hasToUser && !isPostType){
            activityString = NSLocalizedString(@"commented on your followed photo", nil);
        }else{
            activityString = [PAPActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kPAPActivityTypeKey] object:object];
        }
        
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
        
        // update status for activity
        [self updateStatusForActivityInReadList:[activity objectId] newStatus:@"read"];
        
        if ([activity objectForKey:kPAPActivityPhotoKey]) {
            
            PAPPhotoDetailsViewController *detailViewController;
            
            if([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]){
                detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey] source:@"activityComment"];
            }else if([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLikeComment]){
                detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey] source:@"activityLikeComment"];
            }else{
                detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey] source:@"activity"];
            }
            
            // hides tab bar so we can add custom keyboard
            detailViewController.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else if ([activity objectForKey:kPAPActivityFromUserKey]) {
            PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
            [accountViewController setUser:[activity objectForKey:kPAPActivityFromUserKey]];
            [self.navigationController pushViewController:accountViewController animated:YES];
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
    
    /* Personal */
    
    // pull all activities to user
    PFQuery *personalQuery = [PFQuery queryWithClassName:self.parseClassName];
    [personalQuery whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
    
    
    /* Comment Subscriptions */
    
    // pull all subscriptions from current user, fetch most recent
    PFQuery *getSubsQuery = [PFQuery queryWithClassName:@"Subscription"];
    [getSubsQuery whereKey:@"subscriber" equalTo:[PFUser currentUser]];
    [getSubsQuery orderByDescending:@"createdAt"];
    
    // pull all activties from user's subscriptions
    PFQuery *activitiesFromSubs = [PFQuery queryWithClassName:self.parseClassName];
    [activitiesFromSubs whereKey:@"type" equalTo:kPAPActivityTypeComment];
    [activitiesFromSubs whereKey:@"subscribers" matchesQuery:getSubsQuery];
    
    
    /* Following Subscriptions */
    
    // pull newest updates from follower table
    PFQuery *getFollowingSubQuery = [PFQuery queryWithClassName:@"Follower"];
    [getFollowingSubQuery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [getFollowingSubQuery orderByDescending:@"createdAt"];
    
    // pull all activties from following
    PFQuery *activitiesFromFollowing = [PFQuery queryWithClassName:self.parseClassName];
    [activitiesFromFollowing whereKey:@"type" equalTo:kPAPActivityTypePosted];
    [activitiesFromFollowing whereKey:@"subscribers" matchesQuery:getFollowingSubQuery];
    
    /* Mentions */
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[PFUser currentUser]];
    //NSPredicate *prediate = [NSPredicate predicateWithFormat:@"atmention.objectId contains %@", [PFUser currentUser].objectId];
    PFQuery *atmentionQuery = [PFQuery queryWithClassName:self.parseClassName];
    [atmentionQuery whereKey:@"atmention" containsAllObjectsInArray:array];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:@[personalQuery, atmentionQuery, activitiesFromFollowing, activitiesFromSubs]];
    [finalQuery whereKey:kPAPActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [finalQuery whereKeyExists:kPAPActivityFromUserKey];
    
    [finalQuery includeKey:kPAPActivityFromUserKey];
    [finalQuery includeKey:kPAPActivityPhotoKey];
    [finalQuery orderByDescending:@"createdAt"];
    
    [finalQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    return finalQuery;
}

- (void)objectsWillLoad{
    [super objectsWillLoad];
    
    // do not show hud if currently refreshing feed 
    if(!self.refreshFeedControl.refreshing){
        [SVProgressHUD show];
    }
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    [SVProgressHUD dismiss];
    
    // init read list with current objects
    if([self.activityReadList count] == 0){
        for (int i = 0; i < self.objects.count; i++) {
            
            PFObject *pfObj = self.objects[i];
            
            NSString *activityId = [pfObj objectId];
            NSString *postId = [[pfObj objectForKey:@"photo"] objectId];
            
            // get activity id and photo id (if present) and add to read list
           [self addActivityToReadList:activityId postId:postId customAttributes:nil];
        }
        [self saveReadList:nil];
    }else{
        
        /* out-of-sync occurs when:
           case (1) new items are loaded but read list is not updated -> push notifications
           case (2) read list tracks old items -> beyond 15 items (loaded by table) */
        
        // make sure loaded objects are present in read list
        for (PFObject *object in self.objects) {
            
            NSString *activityId = [object objectId];
            NSString *postId = [[object objectForKey:@"photo"] objectId];
            
            if([self findActivityInReadList:activityId] == nil){
                 // get activity id and post id (if present) and add to read list
                [self addActivityToReadList:activityId postId:postId customAttributes:nil];
            }
        }
        
        // make sure read list is identical to loaded object list
        NSMutableArray *extraActivities = [[NSMutableArray alloc] init];
        
        for (NSString *activityId in self.activityReadList) {
            
            if([self.objects valueForKey:activityId]){
                
                // check if activity id in loaded objects
                NSInteger indexOfObject = [self.objects indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop){
                    PFObject *object = (PFObject *)obj;
                    return [[object objectId] isEqualToString:activityId];
                }];
                
                if(indexOfObject == NSNotFound){
                    [extraActivities addObject:activityId];
                }
            }
        }
        
        // cannot delete while loop so get rid of excess items here
        if(extraActivities.count != 0){
            [self removeActivitiesInReadList:extraActivities];
            [self saveReadList:nil];
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
    
    // end refresh control
    [self.refreshFeedControl endRefreshing];
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
    
    
    NSString *activityStatus = [self getStatusForActivityInReadList:[object objectId]];
    
    if(activityStatus){
        if ([activityStatus isEqualToString:@"unread"]) {
            [cell setIsNew:YES];
        }else if([activityStatus isEqualToString:@"read"]){
            [cell setIsNew:NO];
        }
    }else{
        [cell setIsNew:YES];
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

#pragma mark - Refresh Method

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl{
    
    

    [self loadObjects];
}



#pragma mark - PAPActivityCellDelegate Methods

- (void)cell:(PAPActivityCell *)cellView didTapActivityButton:(PFObject *)activity {    
    // Get image associated with the activity
    PFObject *photo = [activity objectForKey:kPAPActivityPhotoKey];
    
    // Push single photo view controller
    
    PAPPhotoDetailsViewController *photoViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo source:@"activity"];
    
    // hides tab bar so we can add custom keyboard
    photoViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)user {    
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
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
    
    }else if([activityType isEqualToString:kPAPActivityTypePosted]) {
        
        PFObject *post = [object objectForKey:@"photo"];
        
        // add post type to item in title
        NSString *begTitle = @"posted a ";
        
        // change wording "picture" to "moment" 
        NSString *postType = [[post objectForKey:@"type"] isEqualToString:@"picture"] ? @"moment": [post objectForKey:@"type"];
        
        NSString *fullTitle = [begTitle stringByAppendingString:postType];
    
        return NSLocalizedString(fullTitle, nil);
    } else {
        return nil;
    }
}


#pragma mark - ()

- (void)scrollToTop{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)setActivityBadge:(NSString *)badge{

    self.navigationController.tabBarItem.badgeValue = badge;
    
    // Reset badge number on server side in installation table (app badge)
    if(badge == nil){
        [[PFInstallation currentInstallation] setBadge:0];
        [[PFInstallation currentInstallation] saveEventually];
        
        // reset activity badge field in user table (tabbar badge)
        [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"activityBadge"];
        [[PFUser currentUser] saveEventually];
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
            [self addActivityToReadList:activityId postId:photoId customAttributes:nil];
        }
        
        // always load objects when notification is received excl. konotor
        [self loadObjects];
    }
}


#pragma mark - Activity Read List Methods

- (void)setActivityReadList{
    
    // set pointer to read list if user already has an activity read list, if not create new one
    if([[PFUser currentUser] objectForKey:@"activityReadList"]){
        self.activityReadList = [[PFUser currentUser] objectForKey:@"activityReadList"];
    }else{
        self.activityReadList = [[NSMutableDictionary alloc] init];
    }
    
    [self checkForOldReadList];
}

- (void)checkForOldReadList{
    
    // try to get old read list from local storage
    NSDictionary *oldReadList = [[NSUserDefaults standardUserDefaults] objectForKey:@"readList"];
    
    // copy contents of old read list to new
    if(oldReadList){
        [self copyLocalReadListToCloudActivityReadList:oldReadList];
    }
}

- (void)copyLocalReadListToCloudActivityReadList:(NSDictionary *)oldReadList{
    
    if([self.activityReadList count] == 0){
        
        // loop through activities, get attributes and add activity to new read list
        for(NSString *activityId in oldReadList){
            
            NSString *status = [[oldReadList objectForKey:activityId] objectForKey:@"status"];
            NSString *postId = [[oldReadList objectForKey:activityId] objectForKey:@"photoId"];
            
            // old read list had activity id set as post id if it was missing, new one has empty string
            if([activityId isEqualToString:postId]){
                postId = @"";
            }
            
            // add activity
            [self addActivityToReadList:activityId postId:postId customAttributes:[NSMutableDictionary dictionaryWithObjectsAndKeys:status, @"status", postId, @"postId", nil]];
        }
        
        //set old readlist to nil
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"readList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)fetchReadListFromServer:(void (^)(id readList, NSError*error))completionBlock {

    // fetch read list
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        completionBlock([object objectForKey:@"activityReadList"], error);
    }];
}


- (void)addActivityToReadList:(NSString *)activityId postId:(NSString *)postId customAttributes:(NSMutableDictionary *)customAttributes{
    
    // edge case: when old notifications without aid get pushed
    if(activityId){
        
        NSMutableDictionary *attributes;
        
        // set to empty string if post id is nil
        postId = postId ? postId : @"";
    
        // set default attributes or add post id to custom attributes
        if(!customAttributes){
            attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"unread", @"status", postId, @"postId", nil];
        }else{
            [customAttributes setObject:postId forKey:@"postId"];
            attributes = customAttributes;
        }
        
        // add item
        [self.activityReadList setObject:attributes forKey:activityId];
        
        // save list
        [self saveReadList:nil];
    }
}

- (void)saveReadList:(void (^)(BOOL success, NSError*error))completionBlock {
    
    // save current read list to user object
    [[PFUser currentUser] setObject:self.activityReadList forKey:@"activityReadList"];
    
    // return result if block is passed
    if(completionBlock){
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            completionBlock(succeeded, error);
        }];
    }else{
        [[PFUser currentUser] saveInBackground];
    }
}

- (void)updateStatusForActivityInReadList:(NSString *)activityId newStatus:(NSString *)newStatus{
    
    // get activity for id
    NSMutableDictionary *activity = [self findActivityInReadList:activityId];

    if(activity && newStatus){
        
        NSString *postId = [activity objectForKey:@"postId"];
        
        // update all related activites if post id exists
        if(![postId isEqualToString:@""]){
            [self updateStatusForAllRelatedActivitiesWithPostId:postId newStatus:newStatus];
        }else{
            // update if post id does not exist
            [activity setValue:newStatus forKey:@"status"];
        }
        
        // save list and reload table
        [self saveReadList:nil];
        [self.tableView reloadData];
    }
}

- (void)updateStatusForAllRelatedActivitiesWithPostId:(NSString *)postId newStatus:(NSString *)newStatus{
    
    if(postId && newStatus){
        // loop through activity list and update where post id is the same
        for (NSString *activityItemKey in self.activityReadList){
            
            NSMutableDictionary *currentActivity = [self.activityReadList objectForKey:activityItemKey];
            NSString *currentPostId = [currentActivity objectForKey:@"postId"];
            
            if([currentPostId isEqualToString:postId]){
                [currentActivity setValue:newStatus forKey:@"status"];
            }
        }
    }
}

- (NSString *)getStatusForActivityInReadList:(NSString *)activityId{
    
    // get activity for id
    NSMutableDictionary *activity = [self findActivityInReadList:activityId];
    
    return [activity objectForKey:@"status"];
}

- (NSMutableDictionary *)findActivityInReadList:(NSString *)activityId{
  
    return [self.activityReadList valueForKey:activityId];
}

- (void)removeActivitiesInReadList:(NSMutableArray *)activities{
    [self.activityReadList removeObjectsForKeys:activities];
}


@end
