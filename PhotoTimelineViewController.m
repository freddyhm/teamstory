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
#import "PAPUtility.h"
#import "PAPLoadMoreCell.h"
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>


#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


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
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Remove cell separator
    [self.feed setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.feed.backgroundView = texturedBackgroundView;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:0.5f];
    [refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.feed addSubview:refreshControl];
     

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidChangeProfile:) name:PAPProfileSettingViewControllerUserChangedProfile object:nil];
    
    [self loadObjects:nil isRefresh:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    // Refresh timeline if user has recently updated their profile
    BOOL isHome = [[self.navigationController.viewControllers lastObject] isKindOfClass:PAPHomeViewController.class];
    
    if(self.shouldReloadOnAppear && isHome){
        [self loadObjects:nil isRefresh:YES];
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
    
    // analytics
    [PAPUtility captureEventGA:@"Engagement" action:@"Comment" label:@"Photo"];
    
    [self.feed beginUpdates];
    [self.feed endUpdates];
    [self.feed reloadData];
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects:nil isRefresh:YES];
    });
}

- (void)userDidPublishPhoto:(NSNotification *)note {
    
    [SVProgressHUD show];
    
    // analytics
    [PAPUtility captureEventGA:@"Engagement" action:@"Upload" label:@"Photo"];
    
    if (self.objects.count > 0) {
        [self.feed scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self loadObjects:nil isRefresh:YES];
}


- (void)didTapOnPhotoAction:(UIButton *)sender {
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    
    PFObject *photo = [self.objects objectAtIndex:sender.tag];
    if (photo) {
        PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo source:@"tapPhoto"];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

- (void) moreActionButton_inflator:(PFUser *) user photo:(PFObject *)photo {
    self.photoID = [photo objectId];
    self.reported_user = [user objectForKey:@"displayName"];
    self.current_photo = photo;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = MainActionSheetTag;
    
    if ([self currentUserOwnsPhoto]) {
        [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:@"Delete Photo"]];
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
        
        // Delete photo
        [self.current_photo deleteEventually];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:[self.current_photo objectId]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Refresh


- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl{
    
    [refreshControl endRefreshing];
    
    [self loadObjects:nil isRefresh:YES];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    // See if scrolling near end, refresh when decelerating
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >= (scrollView.contentSize.height * 0.78)) {
        [self loadObjects:nil isRefresh:NO];
    }
    
}

#pragma mark - UITableViewDataSource

- (void)loadObjects:(void (^)(BOOL succeeded))completionBlock isRefresh:(BOOL)isRefresh{
    
    /* Added completion block, pass nil to use without. We need to know if we're refreshing the table or loading another 10 posts because it'll affect the query's limit. When refreshing, we use the current self.loadPostCount, if it's instead a load, we use the number of current posts + 10. When loadPostCount is 0, load 10 to start. 
     */

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
    
    // A pull-to-refresh should always trigger a network request.
    [self.loadQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // Set limit of posts for query
    [self.loadQuery setLimit:self.loadPostCount];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    
    // Removes warning as part of ios6 & 7 default
    #pragma GCC diagnostic ignored "-Warc-performSelector-leaks"
    SEL isParseReachableSelector = sel_registerName("isParseReachable");
    
    // Check if parse is reachable, pull from cache
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:isParseReachableSelector]) {
        [self.loadQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }

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


/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }
    
    PostFooterView *headerView = [self dequeueReusableSectionHeaderView2];
    
    if (!headerView) {
        headerView = [[PostFooterView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 44.0f) buttons:PAPPhotoHeaderButtonsDefault2];
        headerView.delegate = self;
        [self.reusableSectionHeaderViews2 addObject:headerView];
    }
    
    
    PFObject *photo = [self.objects objectAtIndex:section];
    headerView.tag = section;
    [headerView.likeButton setTag:section];
    
    NSDictionary *attributesForPhoto = [[PAPCache sharedCache] attributesForPhoto:photo];
    
    if (attributesForPhoto) {
        [headerView setLikeStatus:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:photo]];
        
        NSString *likeCount =[[[PAPCache sharedCache] likeCountForPhoto:photo] description];
        BOOL likeStatus = [[PAPCache sharedCache] isPhotoLikedByCurrentUser:photo];
        [headerView setLikeStatus:likeStatus];
        
        
        if (likeStatus == YES) {
            [headerView.likeButton setTitle:likeCount forState:UIControlStateSelected];
        } else {
            [headerView.likeButton setTitle:likeCount forState:UIControlStateNormal];
        }
        
        
        [headerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForPhoto:photo] description] forState:UIControlStateNormal];
        
        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
            [UIView animateWithDuration:0.200f animations:^{
                headerView.likeButton.alpha = 1.0f;
                headerView.commentButton.alpha = 1.0f;
            }];
        }
    } else {
        
        headerView.likeButton.alpha = 0.0f;
        headerView.commentButton.alpha = 0.0f;
        
        @synchronized(self) {
            // check if we can update the cache
            NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries2 objectForKey:[NSNumber numberWithInt:(int)section]];
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
                        NSString *likeCount = [[[PAPCache sharedCache] likeCountForPhoto:photo] description];
                        
                        [headerView setLikeStatus:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:photo]];
                        
                        if (isLikedByCurrentUser == YES) {
                            [headerView.likeButton setTitle:likeCount forState:UIControlStateSelected];
                        } else {
                            [headerView.likeButton setTitle:likeCount forState:UIControlStateNormal];
                        }
                        
                        [headerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForPhoto:photo] description] forState:UIControlStateNormal];
                        
                        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
                            [UIView animateWithDuration:0.200f animations:^{
                                headerView.likeButton.alpha = 1.0f;
                                headerView.commentButton.alpha = 1.0f;
                            }];
                        }
                    }
                }];
            }
        }
    }

    
    return headerView;
}
 */


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
            return 100.0f + expectedSize.height + 64.0f;
        } else {
            return 325.0f + expectedSize.height + 64.0f;
        }
    } else {
        if ([[[self.objects objectAtIndex:indexPath.section] objectForKey:@"type"] isEqualToString:@"link"]) {
            return 100.0f + 54.0f;
        } else {
            return 325.0f + 54.0f;
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
    
    PFObject *object = [self.objects objectAtIndex:indexPath.section];
    
    if (indexPath.section == self.objects.count) {
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    } else {
        NSString *CellIdentifier = @"Cell";
        
        if ([[object objectForKey:@"type"] isEqualToString:@"link"]) {
            CellIdentifier = @"LinkCell";
        } else {
            CellIdentifier = @"Cell";
        }
        
        PAPPhotoCell *cell = (PAPPhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) {
            cell = [[PAPPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        
        [cell setObject:object];
        cell.photoButton.tag = indexPath.section;
        cell.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
        
        [self loadPhotoAttributes:cell object:object indexPath:indexPath];
        
        if(object){
            
            cell.caption = [object objectForKey:@"caption"];
            cell.imageView.file = [object objectForKey:kPAPPhotoPictureKey];
            
            // Fetch image from cache
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[object objectId]];
            
            // set image from cache if available
            if(image){
                cell.imageView.image = image;
            }else{
                // load in background and set image in cache
                [cell.imageView loadInBackground:^(UIImage *image, NSError *error) {
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[object objectId]];
                }];
            }
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
        //[cell.footerView.likeButton setTitle:[[[PAPCache sharedCache] likeCountForPhoto:object] description] forState:UIControlStateNormal];
        [cell.footerView setLikeCount:[[PAPCache sharedCache] likeCountForPhoto:object]];
        //[cell.footerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForPhoto:object] description] forState:UIControlStateNormal];
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
                        //[cell.footerView.likeButton setTitle:[[[PAPCache sharedCache] likeCountForPhoto:object] description] forState:UIControlStateNormal];
                        //[cell.footerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForPhoto:object] description] forState:UIControlStateNormal];
                        
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
    //[[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

#pragma mark - PostFooterView Delegate

- (void)postFooterView:(PostFooterView *)postFooterView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo {
    [postFooterView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [postFooterView setLikeStatus:liked];
    
    NSString *originalButtonTitle = button.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSNumber *likeCount = [numberFormatter numberFromString:button.titleLabel.text];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:button.tag];
    PAPPhotoCell *cell = (PAPPhotoCell *)[self.feed cellForRowAtIndexPath:indexPath];
    PostFooterView *actualFooterView = cell.footerView;
    
    if (liked) {
        // analytics
        [PAPUtility captureEventGA:@"Engagement" action:@"Like" label:@"Photo"];
        
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[PAPCache sharedCache] incrementLikerCountForPhoto:photo];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[PAPCache sharedCache] decrementLikerCountForPhoto:photo];
    }
    
    [actualFooterView setLikeCount:likeCount];
    
    [[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:photo liked:liked];
    
    if (liked == YES) {
        //[button setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateSelected];
    } else if (liked == NO) {
        //[button setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
    }

    
    if (liked) {
        [PAPUtility likePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            [actualFooterView shouldEnableLikeButton:YES];
            [actualFooterView setLikeStatus:succeeded];
            if (!succeeded) {
                //[actualFooterView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
                [actualFooterView setLikeCount:[numberFormatter numberFromString:originalButtonTitle]];
            }
        }];
    } else {
        [PAPUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            [actualFooterView shouldEnableLikeButton:YES];
            [actualFooterView setLikeStatus:!succeeded];
            if (!succeeded) {
                //[actualFooterView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
                [actualFooterView setLikeCount:[numberFormatter numberFromString:originalButtonTitle]];
            }
        }];
    }
}



- (void)postFooterView:(PostFooterView *)postFooterView didTapCommentOnPhotoButton:(UIButton *)button  photo:(PFObject *)photo {
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo source:@"commentButton"];
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
}







#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == MainActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
            actionSheet.delegate = self;
            
            if ([self currentUserOwnsPhoto]){
                [actionSheet setTitle:NSLocalizedString(@"Are you sure you want to delete this photo?", nil)];
                [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Yes, delete photo", nil)]];
                [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
                actionSheet.tag = deletePhoto;
            } else {
                [actionSheet addButtonWithTitle:@"I don't like this photo"];
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
        
    } else {
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
            
            NSLog(@"%@", kPAPPhotoClassKey);
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipients];
            
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:nil];
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



@end
