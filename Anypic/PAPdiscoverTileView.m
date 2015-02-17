//
//  PAPdicoverTileView.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-08-24.
//
//

#import "PAPdiscoverTileView.h"
#import "PAPdiscoverCell.h"
#import "PAPPhotoDetailsViewController.h"
#import "Mixpanel.h"
#import <FlightRecorder/FlightRecorder.h>
#import "PAPdiscoverFollowerCell.h"
#import "PAPAccountViewController.h"

#define searchBarHeight 44.0f
#define menuHeight 44.0f
#define headerViewHeight 44.0f
#define tabBarHeight 30.0f
#define photoCellHeight 105.0f
#define followerQueryNum 20

@interface PAPdiscoverTileView() {
    NSUInteger *skipQueryCountPic;
    NSUInteger *skipQueryCountThought;
}
@property (nonatomic, strong) UIView *mainMenuView;
@property (nonatomic, strong) UIButton *momentsMenu;
@property (nonatomic, strong) UIButton *thoughtsMenu;
@property (nonatomic, strong) UIView *highlightBar;
@property (nonatomic, strong) UIColor *teamstoryColor;
@property (nonatomic, strong) UITableView *mainTileView;
@property (nonatomic, strong) NSMutableArray *pictureQuery;
@property (nonatomic, strong) NSMutableArray *thoughtQuery;
@property (nonatomic, strong) NSString *menuSelection;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, assign) BOOL tableReload;
@property (nonatomic, strong) UIButton *followerMenu;
@property (nonatomic, strong) NSArray *recomUserList;
@property (nonatomic, strong) UIImage *inviteImage;
@property (nonatomic, strong) NSMutableArray *followerListArray;

@end

@implementation PAPdiscoverTileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadFollowers];
        
        self.followerListArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < followerQueryNum; i++) {
            [self.followerListArray addObject:@"No"];
        }
        
        self.teamstoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        _tableReload = YES;
        
        // ------------- UITableView -----------------
        self.mainTileView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, menuHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (searchBarHeight + menuHeight + 39.0f + tabBarHeight)) style:UITableViewStyleGrouped];
        self.mainTileView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.mainTileView.delegate = self;
        self.mainTileView.dataSource = self;
        [self addSubview:self.mainTileView];
        
        // ----------------- initiate menues
        self.mainMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 44.0f)];
        self.mainMenuView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        [self addSubview:self.mainMenuView];
        
        self.followerMenu = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width / 3, 44.0f)];
        [self.followerMenu setTitle:@"People" forState:UIControlStateNormal];
        self.followerMenu.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.followerMenu addTarget:self action:@selector(followersMenuAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainMenuView addSubview:self.followerMenu];
        
        self.momentsMenu = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 3, 0.0f, [UIScreen mainScreen].bounds.size.width / 3, 44.0f)];
        [self.momentsMenu setTitle:@"Moments" forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.momentsMenu addTarget:self action:@selector(momentsMenuAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainMenuView addSubview:self.momentsMenu];
        
        self.thoughtsMenu = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 2 / 3, 0.0f, [UIScreen mainScreen].bounds.size.width / 3, 44.0f)];
        [self.thoughtsMenu setTitle:@"Thoughts" forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.thoughtsMenu addTarget:self action:@selector(thoughtsMenuAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainMenuView addSubview:self.thoughtsMenu];
        
        self.highlightBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.0f, [UIScreen mainScreen].bounds.size.width / 3, 3.0f)];
        [self.highlightBar setBackgroundColor:self.teamstoryColor];
        [self.mainMenuView addSubview:self.highlightBar];
        
        self.menuSelection = @"Followers";
        [self labelSetting:@"Followers"];
        
    }
    return self;
}

-(void)setPictureQuery:(NSArray *)pictureQueryResults setThoughtQuery:(NSArray *)thoughtQueryResults {
    self.pictureQuery = [[NSMutableArray alloc] initWithArray:pictureQueryResults];
    self.thoughtQuery = [[NSMutableArray alloc] initWithArray:thoughtQueryResults];
    [self.mainTileView reloadData];
}


- (void) momentsMenuAction:(id)sender {
    self.menuSelection = @"Moments";
    [self labelSetting:@"Moments"];
    [self.mainTileView reloadData];
}

- (void) thoughtsMenuAction:(id)sender {
    self.menuSelection = @"Thoughts";
    [self labelSetting:@"Thoughts"];
    [self.mainTileView reloadData];
}

- (void) followersMenuAction:(id)sender {
    self.menuSelection = @"Followers";
    [self labelSetting:@"Followers"];
    [self.mainTileView reloadData];
}

-(void) labelSetting:(NSString *)selected {
    if ([selected isEqualToString:@"Moments"]) {
        [self.momentsMenu setTitleColor:self.teamstoryColor forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.thoughtsMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.followerMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.followerMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [UIView animateWithDuration:0.1f animations:^{
            self.highlightBar.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 3, 41.0f, [UIScreen mainScreen].bounds.size.width / 3, 3.0f);
        }];
    } else if ([selected isEqualToString:@"Thoughts"]) {
        [self.thoughtsMenu setTitleColor:self.teamstoryColor forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.momentsMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.followerMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.followerMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [UIView animateWithDuration:0.1f animations:^{
            self.highlightBar.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 2 / 3, 41.0f, [UIScreen mainScreen].bounds.size.width / 3, 3.0f);
        }];
    } else if ([selected isEqualToString:@"Followers"]) {
        [self.followerMenu setTitleColor:self.teamstoryColor forState:UIControlStateNormal];
        self.followerMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.momentsMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.thoughtsMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [UIView animateWithDuration:0.1f animations:^{
            self.highlightBar.frame = CGRectMake(0.0f, 41.0f, [UIScreen mainScreen].bounds.size.width / 3, 3.0f);
        }];
    }
    
}

- (void)setNavigationController:(UINavigationController *)navigationController {
    self.navController = navigationController;
}

# pragma UITableViewDelegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.inviteImage = [UIImage imageNamed:@"inviteDiscover.png"];
    UIImageView *inviteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.inviteImage.size.width, self.inviteImage.size.height)];
    inviteImageView.image = self.inviteImage;
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, self.inviteImage.size.height + headerViewHeight)];
    mainView.backgroundColor = [UIColor whiteColor];
    [mainView addSubview:inviteImageView];
    
    UILabel *recomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, self.inviteImage.size.height, self.inviteImage.size.width, headerViewHeight)];
    recomLabel.text = @"Recommended People";
    recomLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0f];
    [recomLabel setTextColor:[UIColor colorWithRed:146.0f/255.0f green:146.0f/255.0f blue:146.0f/255.0f alpha:1.0f]];
    
    [mainView addSubview:recomLabel];
    
    UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(95.0f, 49.0f, 130.0f, 27.0f)];
    [inviteButton setBackgroundColor:[UIColor clearColor]];
    [inviteButton addTarget:self action:@selector(inviteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:inviteButton];
    
    return mainView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return headerViewHeight + self.inviteImage.size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.menuSelection isEqualToString:@"Moments"]) {
        return [self.pictureQuery count] / 3;
    } else if ([self.menuSelection isEqualToString:@"Thoughts"]){
        return [self.thoughtQuery count] / 3;
    } else {
        return followerQueryNum;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.menuSelection isEqualToString:@"Followers"]) {
        return headerViewHeight + photoCellHeight + 5.0f;
    } else {
        return photoCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Calculating the total_number of rows.
    NSNumber *rowCount;
    
    if ([self.menuSelection isEqualToString:@"Moments"]) {
        rowCount = [NSNumber numberWithLong:[self.pictureQuery count] / 3 - 1];
    } else if ([self.menuSelection isEqualToString:@"Thoughts"]){
        rowCount = [NSNumber numberWithLong:[self.thoughtQuery count] / 3 - 1];
    }
    
    if ([rowCount intValue] == indexPath.row && _tableReload == YES && ([self.menuSelection isEqualToString:@"Moments"] || [self.menuSelection isEqualToString:@"Thoughts"])) {
        _tableReload = NO;
        if ([self.menuSelection isEqualToString:@"Moments"]) {
            skipQueryCountPic = (NSUInteger *)[self.pictureQuery count];
            [self loadMoreCellforPic];
        } else if ([self.menuSelection isEqualToString:@"Thoughts"]) {
            skipQueryCountThought = (NSUInteger *)[self.thoughtQuery count];
            [self loadMoreCellforThought];
        }
    }
    
    if ([self.menuSelection isEqualToString:@"Followers"]) {
        // --------------------------- For Followers
        static NSString *CellIdentifier = @"Discover Cell Followers";
        
        PAPdiscoverFollowerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PAPdiscoverFollowerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setDelegate:self];
        }
        
        UIImage *placeHolderImage = [UIImage imageNamed:@"PlaceholderPhoto"];
        cell.PFimageViewForButton1.image = placeHolderImage;
        cell.PFimageViewForButton2.image = placeHolderImage;
        cell.PFimageViewForButton3.image = placeHolderImage;
        
        PFUser *user = [self.recomUserList objectAtIndex:indexPath.row];
        if (user) {
            PFQuery *photoQuery = [PFQuery queryWithClassName:@"Photo"];
            [photoQuery whereKey:@"user" equalTo:user];
            [photoQuery setLimit:3];
            [photoQuery orderByDescending:@"createdAt"];
            [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count > 2) {
                    cell.PFimageViewForButton1.file = [[objects objectAtIndex:0] objectForKey:@"image"];
                    cell.PFimageViewForButton2.file = [[objects objectAtIndex:1] objectForKey:@"image"];
                    cell.PFimageViewForButton3.file = [[objects objectAtIndex:2] objectForKey:@"image"];
                    
                    [cell.PFimageViewForButton1 loadInBackground];
                    [cell.PFimageViewForButton2 loadInBackground];
                    [cell.PFimageViewForButton3 loadInBackground];
                }
            }];
        }
        
        [cell.photoHeaderView setUserForHeaderView:user];
        [cell.photoHeaderView.followButton setTag:indexPath.row];
        
        if([[self.followerListArray objectAtIndex:indexPath.row] isEqualToString:@"No"]) {
            [cell.photoHeaderView.followButton setSelected:NO];
        }
        else
{
            [cell.photoHeaderView.followButton setSelected:YES];
        }
        
        return cell;
    } else {
        
        // --------------------------- For Moments and Thoughts
        static NSString *CellIdentifier = @"Discover Cell";
        
        PAPdiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PAPdiscoverCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if ([self.menuSelection isEqualToString:@"Moments"]) {
            [cell setImage1:[[self.pictureQuery objectAtIndex:(indexPath.row * 3)] objectForKey:@"image"] setImage2:[[self.pictureQuery objectAtIndex:(indexPath.row * 3) + 1] objectForKey:@"image"] setImage3:[[self.pictureQuery objectAtIndex:(indexPath.row * 3) + 2] objectForKey:@"image"]];
        } else {
            [cell setImage1:[[self.thoughtQuery objectAtIndex:(indexPath.row * 3)] objectForKey:@"image"] setImage2:[[self.thoughtQuery objectAtIndex:(indexPath.row * 3) + 1] objectForKey:@"image"] setImage3:[[self.thoughtQuery objectAtIndex:(indexPath.row * 3) + 2] objectForKey:@"image"]];
        }
        
        cell.imageViewButton1.tag = indexPath.row * 3;
        cell.imageViewButton2.tag = (indexPath.row * 3) + 1;
        cell.imageViewButton3.tag = (indexPath.row * 3) + 2;
        
        [cell.imageViewButton1 addTarget:self action:@selector(photoTapAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.imageViewButton2 addTarget:self action:@selector(photoTapAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.imageViewButton3 addTarget:self action:@selector(photoTapAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

# pragma ()

-(void)photoTapAction:(UIButton *)sender {
    if ([self.menuSelection isEqualToString:@"Moments"]) {
        PFObject *photo = [self.pictureQuery objectAtIndex:sender.tag];
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Selected From Discover" properties:@{@"Type":@"Picture", @"Selected":[photo objectId]}];
        
        // flightrecorder event analytics
        [[FlightRecorder sharedInstance] trackEventWithCategory:@"discover_screen" action:@"tapped_post" label:@"" value:@"picture"];
    
        if (photo) {
            PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo source:@"tapDiscoverPhoto"];
            
            // hides tab bar so we can add custom keyboard
            photoDetailsVC.hidesBottomBarWhenPushed = YES;
            
            self.navController.navigationBar.hidden = NO;
            [self.navController pushViewController:photoDetailsVC animated:YES];
        }
    } else {
        PFObject *photo = [self.thoughtQuery objectAtIndex:sender.tag];
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Selected From Discover" properties:@{@"Type":@"Thought", @"Selected":[photo objectId]}];
        
        // flightrecorder event analytics
        [[FlightRecorder sharedInstance] trackEventWithCategory:@"discover_screen" action:@"tapped_post" label:@"" value:@"thought"];
        
        if (photo) {
            PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo source:@"tapDiscoverPhoto"];
            
            // hides tab bar so we can add custom keyboard
            photoDetailsVC.hidesBottomBarWhenPushed = YES;
            
            self.navController.navigationBar.hidden = NO;
            [self.navController pushViewController:photoDetailsVC animated:YES];
        }
    }
}


-(void) loadMoreCellforPic {
    PFQuery *postQuery_pic = [PFQuery queryWithClassName:@"Photo"];
    [postQuery_pic setLimit:30];
    [postQuery_pic setSkip:(int)skipQueryCountPic];
    [postQuery_pic whereKey:@"type" equalTo:@"picture"];
    [postQuery_pic orderByDescending:@"createdAt"];
    [postQuery_pic findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _tableReload = YES;
            NSUInteger count = [objects count];
            NSMutableArray *randomArray = [[NSMutableArray alloc] initWithArray:objects];
            
            for (int i = 0; i < count; i++) {
                NSInteger remainingCount = count - i;
                NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
                [randomArray exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
            }
            
            [self.pictureQuery addObjectsFromArray:randomArray];
            [self.mainTileView reloadData];
        } else {
            NSLog(@"PostQuery Picture Error: %@", error);
        }
    }];
}

-(void) loadMoreCellforThought {
    PFQuery *postQuery_thoughts = [PFQuery queryWithClassName:@"Photo"];
    [postQuery_thoughts setLimit:30];
    [postQuery_thoughts setSkip:(int)skipQueryCountThought];
    [postQuery_thoughts whereKey:@"type" equalTo:@"thought"];
    [postQuery_thoughts orderByDescending:@"createdAt"];
    [postQuery_thoughts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _tableReload = YES;
            
            NSUInteger count = [objects count];
            NSMutableArray *randomArray = [[NSMutableArray alloc] initWithArray:objects];
            
            for (int i = 0; i < count; i++) {
                NSInteger remainingCount = count - i;
                NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
                [randomArray exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
            }
            
            [self.thoughtQuery addObjectsFromArray:objects];
            [self.mainTileView reloadData];
        } else {
            NSLog(@"PostQuery Picture Error: %@", error);
        }
    }];
}

-(void) loadFollowers {
    PFQuery *userFollowerQuery = [PFQuery queryWithClassName:@"Activity"];
    [userFollowerQuery whereKey:@"type" equalTo:@"follow"];
    [userFollowerQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [userFollowerQuery setLimit:1000];
    [userFollowerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray *objectIds = [objects valueForKeyPath:@"toUser.objectId"];
        
        PFQuery *followerByActivityPointsQuery = [PFUser query];
        [followerByActivityPointsQuery orderByDescending:@"activityPoints"];
        [followerByActivityPointsQuery setLimit:followerQueryNum];
        
        // TODO (justin): pointer comparision is not supported yet. Use when it's supported.
        //[followerByActivityPointsQuery whereKey:@"objectId" doesNotMatchKey:@"toUser" inQuery:userFollowerQuery];
        [followerByActivityPointsQuery whereKey:@"objectId" notContainedIn:objectIds];
        [followerByActivityPointsQuery whereKeyExists:@"displayName"];
        [followerByActivityPointsQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
        [followerByActivityPointsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.recomUserList = objects;
                [self.mainTileView reloadData];
            } else {
                NSLog(@"Follower Query loading error %@", error);
            }
        }];
    }];
}


- (void)setPhotoInDiscover:(PFObject *)photo {
    if (photo) {
        PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo source:@"tapDiscoverPhoto"];
        
        // hides tab bar so we can add custom keyboard
        photoDetailsVC.hidesBottomBarWhenPushed = YES;
        
        self.navController.navigationBar.hidden = NO;
        [self.navController pushViewController:photoDetailsVC animated:YES];
    }
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
    [accountViewController setUser:user];
    self.navController.navigationBar.hidden = NO;
    [self.navController pushViewController:accountViewController animated:YES];
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapFollowButtonForDiscover:(UIButton *)button user:(PFUser *)user {
    // temp disable follow button to avoid duplicates
    photoHeaderView.followButton.enabled = NO;
    
    if ([photoHeaderView.followButton isSelected]) {
        NSLog(@"unfollow");
        // Unfollow
        photoHeaderView.followButton.selected = NO;
        
        [PAPUtility unfollowUserEventually:user block:^(BOOL succeeded) {
            
            // enable button again
            photoHeaderView.followButton.enabled = YES;
            [self.followerListArray replaceObjectAtIndex:photoHeaderView.followButton.tag withObject:@"No"];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    } else {
        NSLog(@"follow");
        // Follow
        photoHeaderView.followButton.selected = YES;
        
        [PAPUtility followUserEventually:user block:^(BOOL succeeded, NSError *error) {
            
            // enable button again
            photoHeaderView.followButton.enabled = YES;
            
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
                [self.followerListArray replaceObjectAtIndex:photoHeaderView.followButton.tag withObject:@"Yes"];
            } else {
                photoHeaderView.followButton.selected = NO;
            }
        }];
    }
    
}

- (void)inviteButtonAction:(id)sender {
    NSArray *activityItems = @[self];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
    [activityVC setValue:@"Invitation From Teamstory" forKey:@"subject"];
    
    [self.navController presentViewController:activityVC animated:YES completion:nil];
    
    // this gets handled after an activity is completed.
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if (completed) {
            if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
                
                [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Shared Post", @"Source": @"Details", @"Platform": @"Facebook"}];
                
                NSLog(@"facebook");
            } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
                
                [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Shared Post", @"Source": @"Details", @"Platform": @"Twitter"}];
                
                NSLog(@"twitter");
            } else if ([activityType isEqualToString:UIActivityTypeMail]) {
                
                [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Shared Post", @"Source": @"Details", @"Platform": @"Email"}];
                
                NSLog(@"email");
            } else {
                // all other activities.
            }
        }
    }];
    
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)])
    {
        // iOS 8+
        UIPopoverPresentationController *presentationController = [activityVC popoverPresentationController];
        presentationController.sourceView = self; // if button or change to self.view.
    }
}

# pragma UIActivityViewControllerDelegate
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
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

@end