//
//  discoverPageViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 1/10/14.
//
//

#import "discoverPageViewController.h"
#import "Mixpanel.h"
#import "Intercom.h"
#import "PAPFindFriendsCell.h"
#import "PAPAccountViewController.h"
#import "PAPdiscoverTileView.h"
#import "SVProgressHUD.h"

#define screenWidth 320.0f

NSInteger selection = 1;

@interface discoverPageViewController() {
    BOOL isSearchString;
    NSInteger skip;
    NSInteger limit;
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
@property (nonatomic, strong) NSMutableArray *userList;
@property (nonatomic, strong) NSMutableArray *userFilterList;
@property (nonatomic, strong) NSMutableArray *userFilterListIndustry;
@property (nonatomic, strong) NSMutableArray *industryFilterList;
@property (nonatomic, strong) NSMutableArray *follwerList;
@property (nonatomic, strong) NSArray *postPicQueryResults;
@property (nonatomic, strong) NSArray *postThoughtQueryResults;
@property (nonatomic, strong) PAPdiscoverTileView *discoverTileView;

@end

@implementation discoverPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userList = [[NSMutableArray alloc] init];
    self.userFilterList = [[NSMutableArray alloc] init];
    self.industryFilterList = [[NSMutableArray alloc] init];
    self.userFilterListIndustry = [[NSMutableArray alloc] init];
    self.follwerList = [[NSMutableArray alloc] init];
    
    [SVProgressHUD show];
    self.view.backgroundColor = [UIColor whiteColor];
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    self.navigationController.navigationBar.hidden = YES;
    
    UIView *navBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth, 20.0f)];
    [navBackground setBackgroundColor:teamStoryColor];
    [self.view addSubview:navBackground];
    
    
    // --------------- Search option menu
    
    self.searchOptionBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 20.0f, screenWidth, 37.5f)];
    [self.searchOptionBgView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    [self.view addSubview:self.searchOptionBgView];
    
    self.searchOptionView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, screenWidth - 10.0f, 27.5f)];
    [self.searchOptionView setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    self.searchOptionView.layer.cornerRadius = 5.0f;
    [self.searchOptionBgView addSubview:self.searchOptionView];
    
    self.searchMovementBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height)];
    [self.searchMovementBar setBackgroundColor:[UIColor whiteColor]];
    self.searchMovementBar.layer.cornerRadius = 5.0f;
    self.searchMovementBar.layer.borderWidth = 2.0f;
    self.searchMovementBar.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    [self.searchOptionView addSubview:self.searchMovementBar];
    
    self.searchSelection = @"users";
    
    self.usersLabel = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height)];
    [self.usersLabel setTitle:@"Users" forState:UIControlStateNormal];
    self.usersLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.usersLabel setTitleColor:[UIColor colorWithWhite:0.4f alpha:1.0f] forState:UIControlStateHighlighted];
    [self.usersLabel setTitleColor:[UIColor colorWithWhite:0.4f alpha:1.0f] forState:UIControlStateNormal];
    [self.usersLabel addTarget:self action:@selector(usersLabelAction:) forControlEvents:UIControlEventTouchUpInside];
    self.usersLabel.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.searchOptionView addSubview:self.usersLabel];
    
    self.industryLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.searchOptionView.bounds.size.width / 2, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height)];
    [self.industryLabel setTitle:@"Industries" forState:UIControlStateNormal];
    self.industryLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.industryLabel setTitleColor:[UIColor colorWithWhite:0.4f alpha:1.0f] forState:UIControlStateHighlighted];
    [self.industryLabel setTitleColor:[UIColor colorWithWhite:0.4f alpha:1.0f] forState:UIControlStateNormal];
    self.industryLabel.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
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
    searchField.tintColor = [UIColor whiteColor];
    searchField.textColor = [UIColor whiteColor];
    
    
    // --------------- UITableView
    self.industry_datasource = [NSArray arrayWithObjects:@"Information Technology", @"Consumers", @"Enterprises", @"Media", @"Education", @"Health Care", @"Finance", @"Sales and Marketing", @"Fashion", @"Health and Wellness", @"Retail", @"Sports", @"UI/UX Design", @"Travel", @"Web Development", @"Real Estate", @"Recruiting", @"Entertainment", @"Clean Technology", @"Events", @"B2B", @"Restaurants", @"Lifestyle", @"Big Data Analytics", @"Music Services", @"Event Management", @"Non Profits", @"Discovery", @"Incubators", @"Other", nil];
    
    
    float tableViewSP = self.searchBar.bounds.size.height + self.searchOptionBgView.bounds.size.height + 20;
    float tabBarHeight = 30.0f;
    float keyboardHeight = 216.0f;
    float tableViewHeight = [UIScreen mainScreen].bounds.size.height - (keyboardHeight + tableViewSP);
    
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

- (void)dismissHUD {
    [SVProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self.navigationController.tabBarController.viewControllers objectAtIndex:1] tabBarItem].image = [[UIImage imageNamed:@"nav_discover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)viewWillAppear:(BOOL)animated{
    // analytics
    [PAPUtility captureScreenGA:@"Discover"];
        
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Discover"}];
    
    [SVProgressHUD setImageName:@"loading_discover.png"];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeCustom];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(dismissHUD) userInfo:nil repeats:NO];
    
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    self.navigationController.navigationBar.hidden = YES;
    
    [[PFUser currentUser] setObject:[NSDate date]  forKey:@"discoverUpdate"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Saved successfully current Date:%@", [[PFUser currentUser] objectForKey:@"discoverUpdate"]);
        } else {
            NSLog(@"error: %@", error);
        }
    }];
    
    self.postThoughtQueryResults = nil;
    self.postPicQueryResults = nil;
    
    PFQuery *postQuery_pic = [PFQuery queryWithClassName:@"Photo"];
    [postQuery_pic setLimit:30];
    [postQuery_pic whereKey:@"type" equalTo:@"picture"];
    [postQuery_pic orderByDescending:@"createdAt"];
    //[postQuery_pic whereKey:@"createdAt" greaterThanOrEqualTo:twoWeeks];
    [postQuery_pic findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.postPicQueryResults = objects;
            [self loadContents];
        } else {
            NSLog(@"PostQuery Picture Error: %@", error);
        }
    }];
    
    PFQuery *postQuery_thoughts = [PFQuery queryWithClassName:@"Photo"];
    [postQuery_thoughts setLimit:30];
    [postQuery_thoughts whereKey:@"type" equalTo:@"thought"];
    //[postQuery_thoughts whereKey:@"createdAt" greaterThanOrEqualTo:twoWeeks];
    [postQuery_thoughts orderByDescending:@"createdAt"];
    [postQuery_thoughts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.postThoughtQueryResults = objects;
            [self loadContents];
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
                [self.follwerList removeAllObjects];
                [self.follwerList addObjectsFromArray:objects];
                [self isSearchBarReady];
            } else {
                NSLog(@"Activity Query Error: %@", error);
            }
        }];
        
        limit = 1000;
        skip = 0;
        [self.userList removeAllObjects];
        [self userQueryPagination];
    }
}

#pragma - ()

-(void) userQueryPagination {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKeyExists:@"displayName"];
    [userQuery orderByDescending:@"updatedAt"];
    [userQuery setLimit:limit];
    [userQuery setSkip:skip];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.userList addObjectsFromArray:objects];
            if (objects.count == limit) {
                skip += limit;
                [userQuery setSkip:skip];
                [userQuery findObjectsInBackgroundWithTarget:self selector:@selector(userQueryPagination)];
            } else {
                [self isSearchBarReady];
            }
        } else {
            NSLog(@"User query error: %@", error);
        }
    }];

}

- (void)isSearchBarReady {
    if ([self.follwerList count] > 0 && [self.userList count] > 0) {
        NSLog(@"User data Successfully Loaded");
        [self.searchTV reloadData];
    }
    
}

-(void)loadContents {
    if ([self.postPicQueryResults count] > 0 && [self.postThoughtQueryResults count] > 0) {
        
        NSMutableArray *filterEmptyPicResult = [[NSMutableArray alloc] init];
        NSMutableArray *filterEmptyThoughtResult = [[NSMutableArray alloc] init];
        
        NSNumber *zero = [NSNumber numberWithInt:0];
        [filterEmptyPicResult addObjectsFromArray:[self.postPicQueryResults filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"discoverCount >= %@", zero]]];
        [filterEmptyThoughtResult addObjectsFromArray:[self.postThoughtQueryResults filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"discoverCount >= %@", zero]]];
        
        
        NSArray *subPicArray;
        NSArray *subThoughtArray;
        
        if ([filterEmptyPicResult count] >= 21) {
            subPicArray = [filterEmptyPicResult subarrayWithRange:NSMakeRange(0, 21)];
        } else {
            subPicArray = filterEmptyPicResult;
        }
        if ([filterEmptyThoughtResult count] >= 21) {
            subThoughtArray = [filterEmptyThoughtResult subarrayWithRange:NSMakeRange(0, 21)];
        } else {
            subThoughtArray = filterEmptyPicResult;
        }

        
        NSArray *finalPictureArray = [filterEmptyPicResult sortedArrayUsingComparator:^(id obj1, id obj2) {
            NSNumber *rating1 = [(NSDictionary *)obj1 objectForKey:@"discoverCount"];
            NSNumber *rating2 = [(NSDictionary *)obj2 objectForKey:@"discoverCount"];
            
            return [rating2 compare:rating1];
        }];
        
        NSArray *finalThoughtArray = [filterEmptyThoughtResult sortedArrayUsingComparator:^(id obj1, id obj2) {
            NSNumber *rating1 = [(NSDictionary *)obj1 objectForKey:@"discoverCount"];
            NSNumber *rating2 = [(NSDictionary *)obj2 objectForKey:@"discoverCount"];
            return [rating2 compare:rating1];
        }];
        
        NSUInteger count = [finalPictureArray count];
        NSMutableArray *finalPictureArray_MT = [[NSMutableArray alloc] initWithArray:finalPictureArray];
        NSMutableArray *finalThoughtArray_MT = [[NSMutableArray alloc] initWithArray:finalThoughtArray];
        
        for (int i = 0; i < [finalPictureArray count]; i++) {
            NSInteger remainingCount = count - i;
            NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
            [finalPictureArray_MT exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
            [finalThoughtArray_MT exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
        }
        
        [self.discoverTileView setPictureQuery:finalPictureArray_MT setThoughtQuery:finalThoughtArray_MT];
        
    }
}

-(void)usersLabelAction:(id)sender {
    
    // mixpane analytics
    [[Mixpanel sharedInstance] track:@"Touched Tab In Discover Search" properties:@{@"Selected":@"Users"}];
    
    [self labelSetting:@"users"];
    self.searchTV.contentOffset = CGPointMake(0, 0);
    [self.searchTV reloadData];
    [UIView animateWithDuration:0.2f animations:^{
        self.searchMovementBar.frame = CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height);
    }];
}

-(void)industryLabelAction:(id)sender {
    
    // mixpane analytics
    [[Mixpanel sharedInstance] track:@"Touched Tab In Discover Search" properties:@{@"Selected":@"Industries"}];
    
    [self labelSetting:@"industry"];
    self.searchTV.contentOffset = CGPointMake(0, 0);
    [self.searchTV reloadData];
    [UIView animateWithDuration:0.2f animations:^{
        self.searchMovementBar.frame = CGRectMake(self.searchOptionView.bounds.size.width / 2, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height);
    }];
}

-(void) labelSetting:(NSString *)selected {
    if ([selected isEqualToString:@"users"]) {
        self.usersLabel.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.industryLabel.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        self.searchSelection = @"users";
        self.searchBar.placeholder = @"Search users";
    } else {
        self.industryLabel.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.usersLabel.titleLabel.font = [UIFont systemFontOfSize:13.0f];
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
    
    if ([self.searchSelection isEqualToString:@"users"] && [searchString length] > 0) {
        [self.userFilterList addObjectsFromArray:[self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", searchString]]];
    } else if ([self.searchSelection isEqualToString:@"industry"] && [searchString length] > 0){
        [self.industryFilterList addObjectsFromArray:[self.industry_datasource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchString]]];
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
    [self labelSetting:@"users"];
    [self.searchTV reloadData];
    [self.searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.searchOptionBgView.frame = CGRectMake(0.0f, 20.0f, screenWidth, 44.0f);
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //Remove all objects first.
    [self.userFilterList removeAllObjects];
    [self.industryFilterList removeAllObjects];
    
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
    if ([self.searchSelection isEqualToString:@"users"] || [self.searchSelection isEqualToString:@"usersIndustry"]) {
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
    } else if ([self.searchSelection isEqualToString:@"usersIndustry"]){
        return [self.userFilterListIndustry count];
    } else {
        if (isSearchString) {
            return [self.industryFilterList count];
        } else {
            return [self.industry_datasource count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    if ([self.searchSelection isEqualToString:@"users"] || [self.searchSelection isEqualToString:@"usersIndustry"]) {
        static NSString *FriendCellIdentifier = @"FriendCell";
        
        PAPFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
        if (cell == nil) {
            cell = [[PAPFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
            cell.delegate = self;
        }
        
        if ([self.searchSelection isEqualToString:@"users"] && [self.follwerList count] > 0 && [self.userList count] > 0) {
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
                } else {
                    cell.followButton.hidden = NO;
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
                } else {
                    cell.followButton.hidden = NO;
                }
                
                [cell setUser:[self.userList objectAtIndex:indexPath.row]];
            }
        } else {
            //Searching for followers
            for (int i = 0; i < [self.follwerList count]; i++) {
                if ([[[[self.follwerList objectAtIndex:i] objectForKey:@"toUser"] objectId] isEqualToString:[[self.userFilterListIndustry objectAtIndex:indexPath.row] objectId]]) {
                    cell.followButton.selected = YES;
                    break;
                } else {
                    cell.followButton.selected = NO;
                }
            }
            if ([[[self.userFilterListIndustry objectAtIndex:indexPath.row] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                cell.followButton.hidden = YES;
            } else {
                cell.followButton.hidden = NO;
            }
            
            [cell setUser:[self.userFilterListIndustry objectAtIndex:indexPath.row]];
        }
            
    
        return cell;
    } else {
        static NSString *CellIdentifier = @"discoverIndustryCell";
        
        PAPdiscoverIndustryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PAPdiscoverIndustryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.delegate = self;
        }
        
        if (isSearchString) {
            [cell.cellButton setTitle:[self.industryFilterList objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            [cell.cellButton addTarget:self action:@selector(discoverCellButtonActionWithSearchString:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.cellButton setTitle:[self.industry_datasource objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            [cell.cellButton addTarget:self action:@selector(discoverCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            cell.cellButton.tag = indexPath.row;
        
        return cell;
    }
}

-(void) discoverCellButtonAction:(UIButton *)sender {
    [self.userFilterListIndustry removeAllObjects];
    
    // check if industry datasource is not empty
    NSString *industry = self.industry_datasource.count > 0 ? [self.industry_datasource objectAtIndex:sender.tag] : @"";
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Selected From Discover" properties:@{@"Type": @"Industry", @"Selected":industry}];
    
    if (![industry isEqualToString:@"Other"]) {
        [self.userFilterListIndustry addObjectsFromArray:[self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"industry contains[c] %@", industry]]];
    } else {
        [self.userFilterListIndustry addObjectsFromArray:[self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"industry == nil"]]];
    }
    
    self.searchSelection = @"usersIndustry";
    [self.searchTV reloadData];
}

- (void) discoverCellButtonActionWithSearchString:(UIButton *)sender{
    [self.userFilterListIndustry removeAllObjects];
    
    // check if filter list is not empty
    NSString *industry = self.industryFilterList.count > 0 ? [self.industryFilterList objectAtIndex:sender.tag] : @"";
    
    if (![industry isEqualToString:@"Other"]) {
        [self.userFilterListIndustry addObjectsFromArray:[self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"industry contains[c] %@", industry]]];
    } else {
        [self.userFilterListIndustry addObjectsFromArray:[self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"industry.length < 1"]]];
    }
    
    NSLog(@"%@", self.userFilterListIndustry);
    
    self.searchSelection = @"usersIndustry";
    [self.searchTV reloadData];
}

#pragma mark - PAPFindFriendsCellDelegate

- (void)cell:(PAPFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    
    // mixpanel analytics
    NSString *selectedUser = [aUser objectForKey:@"displayName"] != nil ? [aUser objectForKey:@"displayName"] : [aUser objectId];
    [[Mixpanel sharedInstance] track:@"Selected From Discover" properties:@{@"Type": @"User", @"Selected": selectedUser}];
    
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
    ;
    [accountViewController setUser:aUser];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(PAPFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser {
    
    // mixpanel analytics
    NSString *selectedUser = [aUser objectForKey:@"displayName"] != nil ? [aUser objectForKey:@"displayName"] : [aUser objectId];
    
    [[Mixpanel sharedInstance] track:@"Selected From Discover" properties:@{@"Type": @"Followed", @"Selected":selectedUser}];
    
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Followed User", @"Source": @"Discover", @"Followed User": selectedUser}];
    
    // intercome analytics
    [Intercom logEventWithName:@"followed-user" optionalMetaData:@{@"followed": selectedUser, @"source": @"discover"}
                    completion:^(NSError *error) {}];

    
    [self shouldToggleFollowFriendForCell:cellView];
}

- (void)shouldToggleFollowFriendForCell:(PAPFindFriendsCell*)cell {
    
    // temp disable follow button to avoid duplicates
    cell.followButton.enabled = NO;

    PFUser *cellUser = cell.user;
    if ([cell.followButton isSelected]) {
        NSLog(@"unfollow");
        // Unfollow
        cell.followButton.selected = NO;
        
        for (int i = 0; i < [self.follwerList count]; i++) {
            if ([[cellUser objectId] isEqualToString:[[[self.follwerList objectAtIndex:i] objectForKey:@"toUser"] objectId]]) {
                [self.follwerList removeObject:[self.follwerList objectAtIndex:i]];
            }
        }
        [PAPUtility unfollowUserEventually:cellUser block:^(BOOL succeeded) {
            
            // enable button again
            cell.followButton.enabled = YES;
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    } else {
        NSLog(@"follow");
        // Follow
        cell.followButton.selected = YES;
        
        if ([self.follwerList count] > 0 ) {
            PFObject *copyOneObject = [self.follwerList objectAtIndex:0];
            [copyOneObject setObject:cellUser forKey:@"toUser"];
            [self.follwerList addObject:copyOneObject];
        }
        
        [PAPUtility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            
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


@end
