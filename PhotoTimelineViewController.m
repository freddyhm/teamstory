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

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


@interface PhotoTimelineViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (nonatomic, strong) NSString *reported_user;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) PFObject *current_photo;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSCache *imgCache;
@property int loadPostCount;
@property int count;
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
        // Custom initialization
        [self.feed setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.feed.backgroundView = texturedBackgroundView;
    self.feed.showsVerticalScrollIndicator = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:PAPUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    
    
    [self loadObjects];
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
        [self loadObjects];
    });
}

- (void)userDidPublishPhoto:(NSNotification *)note {
    
    [SVProgressHUD show];
    
    // analytics
    [PAPUtility captureEventGA:@"Engagement" action:@"Upload" label:@"Photo"];
    
    if (self.objects.count > 0) {
        [self.feed scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    NSLog(@"User following changed.");
    self.shouldReloadOnAppear = YES;
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

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //   BOOL isHome = [[self.navigationController.viewControllers lastObject] isKindOfClass:PAPHomeViewController.class];
    
    // make sure pull-to-refresh set only for home
    // if(isHome){
    if(scrollView.contentOffset.y <= -100){
        
        if(![SVProgressHUD isVisible]){
            CGFloat hudOffset = IS_WIDESCREEN ? -160.0f : -120.0f;
            [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0.0f, hudOffset)];
            [SVProgressHUD show];
        }
    }else{
        if([SVProgressHUD isVisible]){
            [SVProgressHUD dismiss];
            [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0.0f, 0.0f)];
        }
    }
    //}
}

// see if scrolling near end, refresh when decelerating if so
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >= (scrollView.contentSize.height * 0.78)) {
        [self loadObjects];
    }
}




#pragma mark - UITableViewDataSource

- (void)loadObjects{

    // Show hud and set default post load at first load
    if(self.loadPostCount == 0){
        [SVProgressHUD show];
        self.loadPostCount = 10;
    }else{
        // Keep adding 10 posts to current table section count - each post is one section
        self.loadPostCount = (int)[self.feed numberOfSections] + 10;
    }
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
        [query setLimit:0];
    }
  
    // Standard query to load everything
    PFQuery *query = [PFQuery queryWithClassName:kPAPPhotoClassKey];
    [query includeKey:kPAPPhotoUserKey];
    [query orderByDescending:@"createdAt"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // Set limit of posts for query
    [query setLimit:self.loadPostCount];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    
    // Removes warning as part of ios6 & 7 default
    #pragma GCC diagnostic ignored "-Warc-performSelector-leaks"
    SEL isParseReachableSelector = sel_registerName("isParseReachable");
    
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:isParseReachableSelector]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    // Set datasource from parse
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.objects = [NSMutableArray arrayWithArray:objects];
        [self objectsDidLoad:error];
    }];
    

}

- (void)objectsDidLoad:(NSError *)error {
    
    /* set delegate & source here so we can manually refresh the table
       after the data has been loaded */
    
    self.feed.delegate = self;
    self.feed.dataSource = self;
    
    // reload table
    [self.feed reloadData];
    
    // add images to cache if not already present
    for (PFObject *object in self.objects) {
        if(![self.imgCache objectForKey:[object objectId]]){
            PFImageView *photoImgView = [[PFImageView alloc] init];
            photoImgView.file = [object objectForKey:kPAPPhotoPictureKey];
            // load images from remote server
            [photoImgView loadInBackground:^(UIImage *image, NSError *error) {
                
                // check there's no error and image is present before setting
                if(!error && image){
                    [self.imgCache setObject:image forKey:[object objectId]];
                }
            }];
        }
    }
    
    // Remove hud if shown
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.feed.bounds.size.width, 16.0f)];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    
    return 16.0f;
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
            return 100.0f + expectedSize.height + 25.0f;
        } else {
            return 305.0f + expectedSize.height + 25.0f;
        }
    } else {
        if ([[[self.objects objectAtIndex:indexPath.section] objectForKey:@"type"] isEqualToString:@"link"]) {
            return 100.0f;
        } else {
            return 305.0f;
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
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
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
        
        if(object){
            
            cell.caption = [object objectForKey:@"caption"];
            cell.imageView.file = [object objectForKey:kPAPPhotoPictureKey];
            
            // try getting img from cache
            UIImage *cachedImg = [self.imgCache objectForKey:[object objectId]];
            
            // set img from cache or grab from remote server & add to cache
            if(cachedImg){
                cell.imageView.image = cachedImg;
            }else{
                if ([cell.imageView.file isDataAvailable]) {
                    [cell.imageView loadInBackground:^(UIImage *image, NSError *error) {
                        cell.imageView.image = image;
                        if(!error && image){
                            [self.imgCache setObject:cell.imageView.image forKey:[object objectId]];
                        }
                    }];
                }
            }
        }
        
        return cell;
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
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo {
    [photoHeaderView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [photoHeaderView setLikeStatus:liked];
    
    NSString *originalButtonTitle = button.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *likeCount = [numberFormatter numberFromString:button.titleLabel.text];
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
    
    [[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:photo liked:liked];
    
    if (liked == YES) {
        [button setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateSelected];
    } else if (liked == NO) {
        [button setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
    }
    
    if (liked) {
        [PAPUtility likePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            PAPPhotoHeaderView *actualHeaderView = (PAPPhotoHeaderView *)[self tableView:self.feed viewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableLikeButton:YES];
            [actualHeaderView setLikeStatus:succeeded];
            
            if (!succeeded) {
                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    } else {
        [PAPUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            PAPPhotoHeaderView *actualHeaderView = (PAPPhotoHeaderView *)[self tableView:self.feed viewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableLikeButton:YES];
            [actualHeaderView setLikeStatus:!succeeded];
            
            if (!succeeded) {
                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    }
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapCommentOnPhotoButton:(UIButton *)button  photo:(PFObject *)photo {
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
