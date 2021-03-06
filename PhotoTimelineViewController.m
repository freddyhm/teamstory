//
//  PhotoTimelineViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-07-29.
//
//


#import "PhotoTimelineViewController.h"
#import "PAPTabBarController.h"
#import "PAPPhotoCell.h"
#import "PAPAccountViewController.h"
#import "PAPHomeViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "PAPLoadMoreCell.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "PAPwebviewViewController.h"
#import "PAPLoginSelectionViewController.h"

#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define APP ((AppDelegate *)[[UIApplication sharedApplication] delegate])


@interface PhotoTimelineViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews2;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries2;
@property (nonatomic, strong) NSString *reported_user;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) PFObject *current_photo;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSIndexPath *lastViewedExploreIndexPath;
@property (nonatomic, strong) NSIndexPath *lastViewedFollowingIndexPath;
@property (nonatomic, strong) NSString *feedSourceType;
@property (nonatomic, strong) NSString *twitterName;


@property int loadPostCount;
@property int refreshCount;

@end

enum ActionSheetTags {
    MainActionSheetTag = 0,
    reportTypeTag = 1,
    deletePhoto = 2
};

@implementation PhotoTimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        self.outstandingSectionHeaderQueries2 = [NSMutableDictionary dictionary];
        
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        
        self.reusableSectionHeaderViews2 = [NSMutableSet setWithCapacity:3];
        
        self.shouldReloadOnAppear = NO;
        
        // To make sure we only show hud/load objects once per pull
        self.refreshCount = 0;
        
        // set default source type
        self.feedSourceType = @"explore";
        
        // set default location for both feeds
        self.lastViewedExploreIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.lastViewedFollowingIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(IS_OS_6_OR_LATER){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeStarted:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:@"UIMoviePlayerControllerWillExitFullscreenNotification" object:nil];
        
    }
    
    if (IS_OS_8_OR_LATER) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeStarted:) name:UIWindowDidBecomeVisibleNotification object:self.view.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:UIWindowDidBecomeHiddenNotification object:self.view.window];
        
    }
    
    // Remove cell separator
    [self.feed setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.feed.backgroundView = self.texturedBackgroundView;
    
    // pull-to-refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:0.5f];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    [self.feed addSubview:self.refreshControl];
    
    // creating view for extending white background
    CGRect frame = self.feed.bounds;
    frame.origin.y = -frame.size.height;
    self.extendBgView = [[UIView alloc] initWithFrame:frame];
    self.extendBgView.backgroundColor = [UIColor whiteColor];
    
    // adding the view below the refresh control
    [self.feed insertSubview:self.extendBgView atIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidChangeProfile:) name:PAPProfileSettingViewControllerUserChangedProfile object:nil];
    
    [self loadObjects:nil isRefresh:NO fromSource:self.feedSourceType];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    
    // Refresh timeline if user has recently updated their profile
    BOOL isHome = [[self.navigationController.viewControllers lastObject] isKindOfClass:PAPHomeViewController.class];
    
    if(self.shouldReloadOnAppear && isHome){
        [self loadObjects:nil isRefresh:YES fromSource:self.feedSourceType];
        self.shouldReloadOnAppear = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    
    return nil;
}

- (void)userDidChangeProfile:(NSNotification *)note {
    self.shouldReloadOnAppear = YES;
}

- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {
    
    [self.feed beginUpdates];
    [self.feed endUpdates];
    [self.feed reloadData];
}

- (void)userDidCommentOnPhoto:(NSNotification *)note {
    
    // increment user comment count by one
    [[Mixpanel sharedInstance].people increment:@"Comment Count" by:[NSNumber numberWithInt:1]];
    
    [self.feed beginUpdates];
    [self.feed endUpdates];
    [self.feed reloadData];
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects:nil isRefresh:YES fromSource:self.feedSourceType];
    });
}

- (void)userDidPublishPhoto:(NSNotification *)note {
    
    [SVProgressHUD show];
    
    if (self.objects.count > 0) {
        [self.feed scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self loadObjects:nil isRefresh:YES fromSource:self.feedSourceType];
}


- (void)didTapOnPhotoAction:(UIButton *)sender {
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    
    PFObject *photo = [self.objects objectAtIndex:sender.tag];
    
    if (photo) {
        
        // mixpanel analytics
        NSString *type = [photo objectForKey:@"type"] != nil ? [photo objectForKey:@"type"] : @"";
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Viewed Post" properties:@{@"Type":type}];
        
        // intercom analytics
        [Intercom logEventWithName:@"viewed-post" metaData:@{@"":@""}];
        
        
        // flightrecorder event analytics
        [[FlightRecorder sharedInstance] trackEventWithCategory:@"home_screen" action:@"tapped_post" label:@"" value:type];
        
        UIViewController *tappedController;
        
        if ([type isEqualToString:@"link"]){
            
            // mixpanel analytics
            [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Viewed Link", @"Source": @"Timeline"}];
            
            // intercome analytics
            [Intercom logEventWithName:@"viewed-link" metaData:@{@"":@""}];
            
            tappedController = [[PAPwebviewViewController alloc] initWithWebsite:[photo objectForKey:@"link"]];
        }else{
            tappedController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo source:@"tapPhoto"];
        }
        
        // hides tab bar so we can add custom keyboard
        tappedController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:tappedController animated:YES];
    }
}

- (void) moreActionButton_inflator:(PFUser *) user photo:(PFObject *)photo {
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        PAPLoginSelectionViewController *loginSelectionViewController = [[PAPLoginSelectionViewController alloc] initWithNibName:@"PAPLoginSelectionViewController" bundle:nil];
        [self.navigationController presentViewController:loginSelectionViewController animated:YES completion:nil];
        return;
    }
    
    self.photoID = [photo objectId];
    self.reported_user = [user objectForKey:@"displayName"];
    self.current_photo = photo;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = MainActionSheetTag;
    
    if ([self currentUserOwnsPhoto]) {
        [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:@"Delete Post"]];
    } else {
        [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Report Inappropriate", nil)]];
    }
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (BOOL)currentUserOwnsPhoto {
    return [[[self.current_photo objectForKey:kPAPPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]];
}

- (void)shouldDeletePhoto {
    // Delete all activites related to this photo
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityPhotoKey equalTo:self.current_photo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteEventually];
            }
        }
        
        // Delete project title associated with photo in user table if present
        [self deleteProjectIfPresent:self.current_photo];
        
        // Delete post
        [self.current_photo deleteEventually];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:[self.current_photo objectId]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteProjectIfPresent:(PFObject *)post{
    
    NSUInteger postLength = [[post objectForKey:@"projectTitle"] length];
    
    if(postLength > 0){
        [post removeObjectForKey:@"projectTitle"];
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                [[PFUser currentUser] removeObjectForKey:@"projectTitle"];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}

- (void) shareButton:(PFUser *)shareUser setPhoto:(PFObject *)photo {
    [SVProgressHUD show];
    self.twitterName = nil;
    
    self.inviteButtonCheckForShare = NO;
    // getting image so that we can share
    [[photo objectForKey:@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSArray *activityItems = @[self, data];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
            
            // only for email.
            [activityVC setValue:@"Check this post out from Teamstory" forKey:@"subject"];
            
            if ([[shareUser objectForKey:@"twitter_url"] length] > 0) {
                self.twitterName = [self getTwitterNameFromURL:[shareUser objectForKey:@"twitter_url"]];
            }

            [self presentViewController:activityVC animated:YES completion:nil];
            
            // this gets handled after an activity is completed.
            [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
                if (completed) {
                    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
                        
                        [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Shared Post", @"Source": @"Timeline", @"Platform": @"Facebook"}];
                        
                        NSLog(@"facebook");
                    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
                        
                        [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Shared Post", @"Source": @"Timeline", @"Platform": @"Twitter"}];
                        
                        NSLog(@"twitter");
                    } else if ([activityType isEqualToString:UIActivityTypeMail]) {
                        
                        [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Shared Post", @"Source": @"Timeline", @"Platform": @"Email"}];
                        
                        NSLog(@"email");
                    } else {
                        // all other activities.
                    }
                }
            }];
            
            if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
                // iOS 8+
                UIPopoverPresentationController *presentationController = [activityVC popoverPresentationController];
                presentationController.sourceView = self.view; // if button or change to self.view.
                
            }
        }
    }];
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    if (!self.inviteButtonCheckForShare) {
        if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
            NSString *theText = @"#startup #moment shared on #teamstoryapp - Join the global #entrepreneurship #community for #founders: goo.gl/F2QSoJ @teamstory";
            return theText;
        }
        
        if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
            NSString *theText;
            if (self.twitterName.length > 0) {
                theText = [NSString stringWithFormat:@"#startup moment on @teamstoryapp via @%@. Join the global startup community: http://goo.gl/F2QSoJ", self.twitterName];
            } else {
                theText = @"#startup moment on @teamstoryapp. Join the global startup community: http://goo.gl/F2QSoJ";
            }
            return theText;
        }
        
        if ([activityType isEqualToString:UIActivityTypeMail]) {
            NSString *theText = @"Hey there!\nThis is a startup moment shared on Teamstory (http://teamstoryapp.com) - A community for startups & founders! Would love for you to join the community with me: http://goo.gl/F2QSoJ";
            return theText;
        }
        
        return @"Startup moment shared on Teamstory - A community for startups & founders! Join the community with me: goo.gl/F2QSoJ";
        
    } else {
        if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
            NSString *theText = @"Join me and hundreds of #entrepreneurs and #founders on @teamstory!:goo.gl/F2QSoJ" ;
            return theText;
        }
        
        if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
            NSString *theText;
            theText = @"Join me and hundreds of #entrepreneurs and #founders on @teamstoryapp!:goo.gl/F2QSoJ";
            return theText;
        }
        
        return @"Join me and hundreds of entrepreneurs and founders on teamstoryapp!:http://goo.gl/F2QSoJ";
    }
}

#pragma mark - Refresh

- (NSString *)getFeedSourceType{
    return self.feedSourceType;
}

- (NSIndexPath *)getIndexPathForFeed:(NSString *)feed{
    
    if([feed isEqualToString:@"explore"]){
        return self.lastViewedExploreIndexPath;
    }else if([feed isEqualToString:@"following"]){
        return self.lastViewedFollowingIndexPath;
    }else{
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl{
    
    [refreshControl endRefreshing];
    
    [self loadObjects:nil isRefresh:YES fromSource:self.feedSourceType];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    // See if scrolling near end, refresh when decelerating
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >= (scrollView.contentSize.height * 0.78)) {
        [self loadObjects:nil isRefresh:NO fromSource:self.feedSourceType];
    }
    
}

#pragma mark - UITableViewDataSource

- (void)loadObjects:(void (^)(BOOL succeeded))completionBlock isRefresh:(BOOL)isRefresh fromSource:(NSString *)fromSource{
    
    /* Added completion block, pass nil to use without. We need to know if we're refreshing the table or loading another 10 posts because it'll affect the query's limit. When refreshing, we use the current self.loadPostCount, if it's instead a load, we use the number of current posts + 10. When loadPostCount is 0, load 10 to start. 
     */
    
    // set feed source 
    self.feedSourceType = fromSource;
    
    // Show hud and set default post load at first load
    if(self.loadPostCount == 0){
        [SVProgressHUD show];
        self.loadPostCount = 10;
    }else if(!isRefresh){
        // Keep adding 10 posts to current table section count - each post is one section
        self.loadPostCount = (int)[self.feed numberOfSections] + 10;
    }
    
    // Standard query to load everything
    self.loadQuery = [PFQuery queryWithClassName:kPAPPhotoClassKey];
    [self.loadQuery includeKey:kPAPPhotoUserKey];
    [self.loadQuery orderByDescending:@"createdAt"];
    
    if([fromSource isEqualToString:@"following"]){
        
        PFQuery *getFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [getFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        
        // get following for current user
        [getFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [getFollowingQuery includeKey:kPAPActivityToUserKey];
        
        [self.loadQuery whereKey:@"user" matchesKey:@"toUser" inQuery:getFollowingQuery];
    }
    
    // Set limit of posts for query
    [self.loadQuery setLimit:self.loadPostCount];
    
    // Set datasource from parse
    [self.loadQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.objects = [NSMutableArray arrayWithArray:objects];
        
        // Return completion if block is present
        if(completionBlock){
            completionBlock([self objectsDidLoad:error]);
        }else{
            [self objectsDidLoad:error];
        }
    }];
}

- (BOOL)objectsDidLoad:(NSError *)error {
    
    // Remove hud if shown
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0.0f, 0.0f)];
    }
    
    // Check for errors, also used to indicate method completion
    BOOL didLoad = !error ? YES : NO;
    
    /* set delegate & source here so we can manually refresh the table
     after the data has been loaded */
    self.feed.delegate = self;
    self.feed.dataSource = self;
    
    PFImageView *photoImgView = [[PFImageView alloc] init];
    
    // Add images to cache if not already present
    for (PFObject *object in self.objects) {
        
        photoImgView.file = [object objectForKey:kPAPPhotoPictureKey];
        
        if (![photoImgView.file isDataAvailable]) {
            [photoImgView loadInBackground];
        }
    }
    
    // Reload table
    [self.feed reloadData];

    return didLoad;
}

#pragma mark - TableView Delegate & Related Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }
    
    PAPPhotoHeaderView *headerView = [self dequeueReusableSectionHeaderView];
    
    if (!headerView) {
        headerView = [[PAPPhotoHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 44.0f) buttons:PAPPhotoHeaderButtonsDefault];
        headerView.delegate = self;
        [self.reusableSectionHeaderViews addObject:headerView];
    }
    
    PFObject *photo = [self.objects objectAtIndex:section];
    [headerView setPhoto:photo];
    headerView.tag = section;
    
    
        @synchronized(self) {
            // check if we can update the cache
            NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries objectForKey:[NSNumber numberWithInt:(int)section]];
            if (!outstandingSectionHeaderQueryStatus) {
                PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        //[self.outstandingSectionHeaderQueries removeObjectForKey:[NSNumber numberWithInt:(int)section]];
                        
                        if (error) {
                            return;
                        }
                        
                        NSMutableArray *likers = [NSMutableArray array];
                        NSMutableArray *commenters = [NSMutableArray array];
                        
                        BOOL isLikedByCurrentUser = NO;
                        
                        for (PFObject *activity in objects) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                                [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                            }
                            
                            if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                    isLikedByCurrentUser = YES;
                                    
                                }
                            }
                        }
                        
                        [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                        
                        if (headerView.tag != section) {
                            return;
                        }
                    }
                }];
            }            
        
    }
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    
    return 44.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 0.0f;
    }
    
    NSString *caption = [[self.objects objectAtIndex:indexPath.section] objectForKey:@"caption"];
    
    if ([caption length] > 0) {
        CGSize maximumLabelSize = CGSizeMake(295.0f, 9999.0f);
        
        CGSize expectedSize = ([caption boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil]).size;
        
        if (expectedSize.height > 46.527f) {
            expectedSize.height = 46.527f;
        }
        
        if ([[[self.objects objectAtIndex:indexPath.section] objectForKey:@"type"] isEqualToString:@"link"]) {
            if ([[[self.objects objectAtIndex:indexPath.section] objectForKey:@"link"] rangeOfString:@"youtube.com"].location != NSNotFound || [[[self.objects objectAtIndex:indexPath.section] objectForKey:@"link"] rangeOfString:@"youtu.be"].location != NSNotFound) {
                return 295.0f + expectedSize.height;
            } else {
                return 325.0f + expectedSize.height + 94.0f;
            }
        } else {
            return 325.0f + expectedSize.height + 94.0f;
        }
    } else {
        if ([[[self.objects objectAtIndex:indexPath.section] objectForKey:@"type"] isEqualToString:@"link"]) {
            if ([[[self.objects objectAtIndex:indexPath.section] objectForKey:@"link"] rangeOfString:@"youtube.com"].location != NSNotFound || [[[self.objects objectAtIndex:indexPath.section] objectForKey:@"link"] rangeOfString:@"youtu.be"].location != NSNotFound) {
                return 275.0f;
            } else {
                return 325.0f + 64.0f;
            }
            
        } else {
            return 325.0f + 64.0f;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.feedSourceType isEqualToString:@"explore"]){
        self.lastViewedExploreIndexPath = indexPath;
    }else{
        self.lastViewedFollowingIndexPath = indexPath;
    }
    
    PFObject *object = [self.objects objectAtIndex:indexPath.section];
    
    if (indexPath.section == self.objects.count) {
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    } else {
        
        NSString *CellIdentifier = @"Cell";
        
        if ([[object objectForKey:@"type"] isEqualToString:@"link"]) {
            if ([[object objectForKey:@"link"] rangeOfString:@"youtube.com"].location != NSNotFound || [[object objectForKey:@"link"] rangeOfString:@"youtu.be"].location != NSNotFound) {
                CellIdentifier = @"YoutubueLinkCell";
            }
        } else {
            CellIdentifier = @"Cell";
        }
        
        PAPPhotoCell *cell = (PAPPhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[PAPPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.captionButton addTarget:self action:@selector(captionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell setObject:object];
        cell.photoButton.tag = indexPath.section;
        cell.captionButton.tag = indexPath.section;
        
        if(object){
            
            [self loadPhotoAttributes:cell object:object indexPath:indexPath];
            
            cell.caption = [object objectForKey:@"caption"];
            cell.imageView.file = [object objectForKey:kPAPPhotoPictureKey];
            
            [cell.imageView loadInBackground];
        }
        
        return cell;
    }
}

- (void)loadPhotoAttributes:(PAPPhotoCell *)cell object:(PFObject *)object indexPath:(NSIndexPath *)indexPath{
    
    [cell.footerView setPhoto:object];
    cell.footerView.tag = indexPath.section;
    [cell.footerView.likeButton setTag:indexPath.section];
    cell.footerView.delegate = self;

    NSDictionary *attributesForPhoto = [[PAPCache sharedCache] attributesForPhoto:object];
    
    if (attributesForPhoto) {
        [cell.footerView setLikeStatus:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:object]];
        [cell.footerView setLikeCount:[[PAPCache sharedCache] likeCountForPhoto:object]];
        [cell.footerView setCommentCount:[[PAPCache sharedCache] commentCountForPhoto:object]];
        
        if (cell.footerView.likeButton.alpha < 1.0f || cell.footerView.commentButton.alpha < 1.0f) {
            [UIView animateWithDuration:0.200f animations:^{
                cell.footerView.likeButton.alpha = 1.0f;
                cell.footerView.commentButton.alpha = 1.0f;
            }];
        }
    }else {
        cell.footerView.likeButton.alpha = 0.0f;
        cell.footerView.commentButton.alpha = 0.0f;
        
        @synchronized(self) {
            // check if we can update the cache
            NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries objectForKey:@(indexPath.section)];
            if (!outstandingSectionHeaderQueryStatus) {
                PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:object cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        [self.outstandingSectionHeaderQueries removeObjectForKey:@(indexPath.section)];
                        
                        if (error) {
                            return;
                        }
                        
                        NSMutableArray *likers = [NSMutableArray array];
                        NSMutableArray *commenters = [NSMutableArray array];
                        
                        BOOL isLikedByCurrentUser = NO;
                        
                        for (PFObject *activity in objects) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                                [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                            }
                            
                            if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                    isLikedByCurrentUser = YES;
                                }
                            }
                        }
                        
                        [[PAPCache sharedCache] setAttributesForPhoto:object likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                        
                        if (cell.footerView.tag != indexPath.section) {
                            return;
                        }
                        
                        [cell.footerView setLikeStatus:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:object]];
                        [cell.footerView setLikeCount:[[PAPCache sharedCache] likeCountForPhoto:object]];
                        [cell.footerView setCommentCount:[[PAPCache sharedCache] commentCountForPhoto:object]];
                        
                        if (cell.footerView.likeButton.alpha < 1.0f || cell.footerView.commentButton.alpha < 1.0f) {
                            [UIView animateWithDuration:0.200f animations:^{
                                cell.footerView.likeButton.alpha = 1.0f;
                                cell.footerView.commentButton.alpha = 1.0f;
                            }];
                        }
                    }
                }];
            }
        }
    }
    
}

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView {
    for (PAPPhotoHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    return nil;
}


#pragma mark - PhotoHeaderView Delegate

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
    [accountViewController setUser:user];
    accountViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapProjectLink:(PFObject *)post{
    [self openPhotoDetailView:post];
}

#pragma mark - PostFooterView Delegate

- (void)postFooterView:(PostFooterView *)postFooterView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo {
    
    // Disable button to avoid multiple likes
    [postFooterView shouldEnableLikeButton:NO];
    
    // Set like button status right away
    BOOL liked = !button.selected;
    [postFooterView setLikeStatus:liked];
    
    // Keep original count in case of a fail
    NSString *originalCount = postFooterView.likeCountLabel.text;
    
    // Change string count to a number
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSNumber *likeCount = [numberFormatter numberFromString:postFooterView.likeCountLabel.text];
    
    
    
    if (liked) {
        
        // get post type
        NSString *postType = [photo objectForKey:@"type"] != nil ? [photo objectForKey:@"type"] : @"";
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Liked Post", @"Source":@"Timeline", @"Post Type": postType}];
        
        // intercom analytics
        [Intercom logEventWithName:@"liked-post" metaData:@{@"source":@"timeline"}];

        
        // increment user like count by one
        [[Mixpanel sharedInstance].people increment:@"Like Count" by:[NSNumber numberWithInt:1]];
        
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[PAPCache sharedCache] incrementLikerCountForPhoto:photo];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[PAPCache sharedCache] decrementLikerCountForPhoto:photo];
    }
    
    // Set new count right away
    [postFooterView setLikeCount:likeCount];
    
    [[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:photo liked:liked];
    
    // Send new info to server
    if (liked) {
        [PAPUtility likePhotoInBackground:photo setNavigationController:self.navigationController block:^(BOOL succeeded, NSError *error) {
            [postFooterView shouldEnableLikeButton:YES];
            [postFooterView setLikeStatus:succeeded];
            if (!succeeded) {
                [postFooterView setLikeCount:[numberFormatter numberFromString:originalCount]];
            }
        }];
    } else {
        [PAPUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            [postFooterView shouldEnableLikeButton:YES];
            [postFooterView setLikeStatus:!succeeded];
            if (!succeeded) {
                [postFooterView setLikeCount:[numberFormatter numberFromString:originalCount]];
            }
        }];
    }
}

- (void)postFooterView:(PostFooterView *)postFooterView didTapCommentForPost:photo {
    [self openPhotoDetailView:photo];
}

- (void)captionButtonAction:(UIButton *)sender {
    [self openPhotoDetailView:[self.objects objectAtIndex:sender.tag]];
}

- (void)openPhotoDetailView:(PFObject *)photo {
    
    PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo source:@"timelineHeaderLink"];
    
    // hides tab bar so we can add custom keyboard
    photoDetailsVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == MainActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
            actionSheet.delegate = self;
            
            if ([self currentUserOwnsPhoto]){
                [actionSheet setTitle:NSLocalizedString(@"Are you sure you want to delete this post?", nil)];
                [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Yes, delete post", nil)]];
                [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
                actionSheet.tag = deletePhoto;
            } else {
                [actionSheet addButtonWithTitle:@"I don't like this post"];
                [actionSheet addButtonWithTitle:@"Spam or scam"];
                [actionSheet addButtonWithTitle:@"Nudity or pornography"];
                [actionSheet addButtonWithTitle:@"Graphic violence"];
                [actionSheet addButtonWithTitle:@"Hate speech or symbol"];
                [actionSheet addButtonWithTitle:@"Intellectual property violation"];
                [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
                actionSheet.tag = reportTypeTag;
            }
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        }
    } else if (actionSheet.tag == deletePhoto) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            [self shouldDeletePhoto];
        }
        
    } else if (actionSheet.tag == reportTypeTag){
        if ([actionSheet cancelButtonIndex] == buttonIndex){
            //do nothing
        } else {
            NSString *emailTitle = @"[USER REPORT] Reporting Inappropriate Pictures";
            NSString *messageBody;
            NSArray *toRecipients = [NSArray arrayWithObject:@"info@teamstoryapp.com"];
            
            switch (buttonIndex) {
                case 0:
                {
                    messageBody = [NSString stringWithFormat:@"%@%@%@%@%@%@", @"Category: \"I don't like this photo\"\n", @"Target User: ",
                                   self.reported_user, @"\n", @"Photo ID: ", self.photoID];
                    break;
                }
                case 1:
                {
                    messageBody = [NSString stringWithFormat:@"%@%@%@%@%@%@", @"Category: \"Spam or scam\"\n", @"Target User: ",
                                   self.reported_user, @"\n", @"Photo ID: ", self.photoID];
                    break;
                }
                case 2:
                {
                    messageBody = [NSString stringWithFormat:@"%@%@%@%@%@%@", @"Category: \"Nudity or pornography\"\n", @"Target User: ",
                                   self.reported_user, @"\n", @"Photo ID: ", self.photoID];
                    break;
                }
                case 3:
                {
                    messageBody = [NSString stringWithFormat:@"%@%@%@%@%@%@", @"Category: \"Graphic violence\"\n", @"Target User: ",
                                   self.reported_user, @"\n", @"Photo ID: ", self.photoID];                break;
                }
                case 4:
                {
                    messageBody = [NSString stringWithFormat:@"%@%@%@%@%@%@", @"Category: \"Hate speech or symbol\"\n", @"Target User: ",
                                   self.reported_user, @"\n", @"Photo ID: ", self.photoID];                break;
                }
                case 5:
                {
                    messageBody = [NSString stringWithFormat:@"%@%@%@%@%@%@", @"Category: \"Intellectual property violation\"\n", @"Target User: ",
                                   self.reported_user, @"\n", @"Photo ID: ", self.photoID];
                    break;
                }
                default:
                    break;
            }
            
            APP.mc.mailComposeDelegate = self;
            [APP.mc setSubject:emailTitle];
            [APP.mc setMessageBody:messageBody isHTML:NO];
            [APP.mc setToRecipients:toRecipients];
            
            
            // Present mail view controller on screen
            [self presentViewController:APP.mc animated:YES completion:nil];
        }
    }
}



- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Successful" message:@"Message has been successfully sent" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alertView show];
            break;
        }
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your message was not sent! Please check your internet connection!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alertView show];
            break;
        }
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void) youTubeStarted:(NSNotification *)notification {
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Played Video"}];
}

- (void) youTubeFinished:(NSNotification *)notification {
}

- (NSString *) getTwitterNameFromURL:(NSString *)url{
    NSString *twitterAccount = [url substringFromIndex:20];
    return twitterAccount;
}


@end
