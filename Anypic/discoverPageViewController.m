//
//  discoverPageViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 1/10/14.
//
//

#import "discoverPageViewController.h"

#define screenWidth 320.0f

NSInteger selection = 1;

@interface discoverPageViewController() {
    BOOL isSearchString;
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
@property (nonatomic, strong) NSArray *userList;
@property (nonatomic, strong) NSMutableArray *userFilterList;

@end

@implementation discoverPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    self.navigationController.navigationBar.hidden = YES;
    
    UIView *navBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth, 20.0f)];
    [navBackground setBackgroundColor:teamStoryColor];
    [self.view addSubview:navBackground];
    
    
    // --------------- Search option menu
    
    self.searchOptionBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 20.0f, screenWidth, 44.0f)];
    [self.searchOptionBgView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    [self.view addSubview:self.searchOptionBgView];
    
    self.searchOptionView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, screenWidth - 10.0f, 34.0f)];
    [self.searchOptionView setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    self.searchOptionView.layer.cornerRadius = 5.0f;
    [self.searchOptionBgView addSubview:self.searchOptionView];
    
    self.searchMovementBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height)];
    [self.searchMovementBar setBackgroundColor:[UIColor whiteColor]];
    self.searchMovementBar.layer.cornerRadius = 5.0f;
    self.searchMovementBar.layer.borderWidth = 1.0f;
    self.searchMovementBar.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [self.searchOptionView addSubview:self.searchMovementBar];
    
    self.searchSelection = @"users";
    
    self.usersLabel = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height)];
    [self.usersLabel setTitle:@"Users" forState:UIControlStateNormal];
    self.usersLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.usersLabel setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.usersLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.usersLabel addTarget:self action:@selector(usersLabelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchOptionView addSubview:self.usersLabel];
    
    self.industryLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.searchOptionView.bounds.size.width / 2, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height)];
    [self.industryLabel setTitle:@"Industries" forState:UIControlStateNormal];
    self.industryLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.industryLabel setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.industryLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    //[self.searchBar setImage:<#(UIImage *)#> forSearchBarIcon:<#(UISearchBarIcon)#> state:<#(UIControlState)#>]
    [self.view addSubview:self.searchBar];
    
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    
    // --------------- UITableView
    self.industry_datasource = [NSArray arrayWithObjects:@"Information Technology", @"Consumers", @"Enterprises", @"Media", @"Education", @"Health Care", @"Finance", @"Sales and Marketing", @"Fashion", @"Health and Wellness", @"Retail", @"Sports", @"UI/UX Design", @"Travel", @"Web Development", @"Real Estate", @"Recruiting", @"Entertainment", @"Clean Technology", @"Events", @"B2B", @"Restaurants", @"Lifestyle", @"Big Data Analytics", @"Music Services", @"Event Management", @"Non Profits", @"Discovery", @"Incubators", @"Other", nil];
    
    
    float tableViewSP = self.searchBar.bounds.size.height + self.searchOptionBgView.bounds.size.height + 20;
    float tabBarHeight = 30.0f;
    float tableViewHeight = [UIScreen mainScreen].bounds.size.height - (tabBarHeight + tableViewSP);
    
    self.searchTV = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, tableViewSP, screenWidth, tableViewHeight) style:UITableViewStylePlain];
    self.searchTV.delegate = self;
    self.searchTV.dataSource = self;
    self.searchTV.hidden = YES;
    [self.view addSubview:self.searchTV];
    
	   
}

- (void)viewWillAppear:(BOOL)animated{
    // analytics
    [PAPUtility captureScreenGA:@"Discover"];
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:100] removeFromSuperview];
    
    PFQuery *userQuery = [PFUser query];
    userQuery.limit = MAXFLOAT;
    [userQuery whereKeyExists:@"displayName"];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.userList = objects;
            [self.searchTV reloadData];
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    
}

#pragma - ()

-(void)usersLabelAction:(id)sender {
    [self labelSetting:@"users"];
    [self.searchTV reloadData];
    [UIView animateWithDuration:0.2f animations:^{
        self.searchMovementBar.frame = CGRectMake(0.0f, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height);
    }];
}

-(void)industryLabelAction:(id)sender {
    [self labelSetting:@"industry"];
    [self.searchTV reloadData];
    [UIView animateWithDuration:0.2f animations:^{
        self.searchMovementBar.frame = CGRectMake(self.searchOptionView.bounds.size.width / 2, 0.0f, self.searchOptionView.bounds.size.width / 2, self.searchOptionView.bounds.size.height);
    }];
}

-(void) labelSetting:(NSString *)selected {
    if ([selected isEqualToString:@"users"]) {
        self.usersLabel.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.industryLabel.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        self.searchSelection = @"users";
        self.searchBar.placeholder = @"Search users";
    } else {
        self.industryLabel.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.usersLabel.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        self.searchSelection = @"industry";
        self.searchBar.placeholder = @"Search industry";
    }
    
}

- (void)setSearchIconTo {
    // Really a UISearchBarTextField, but the header is private.
    UITextField *searchField = nil;
    for (UIView *subview in self.searchBar.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            searchField = (UITextField *)subview;
            break;
        }
    }
    
    if (searchField) {
        UIImage *image = [UIImage imageNamed: @"favicon.png"];
        UIImageView *iView = [[UIImageView alloc] initWithImage:image];
        searchField.leftView = iView;
    }  
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [self searchTableList];
}


- (void)searchTableList {
    NSString *searchString = self.searchBar.text;
        /*
    for (int i = 0; i < [self.userList count]; i++) {

        for (NSString *tempStr in [[self.userList objectAtIndex:i] objectForKey:@"displayName"]) {
            NSComparisonResult result = [tempStr compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
            if (result == NSOrderedSame) {
                [self.userFilterList addObject:tempStr];
            }
        }
         */
        [self.userFilterList addObjectsFromArray:[self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", searchString]]];
    NSLog(@"userfilterlist: %lu", (unsigned long)[self.userFilterList count]);
    NSLog(@"search string: %@", searchString);
    //}
}


# pragma UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.userFilterList = [[NSMutableArray alloc] init];
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
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = nil;
    [self.searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.searchOptionBgView.frame = CGRectMake(0.0f, 20.0f, screenWidth, 44.0f);
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //Remove all objects first.
    [self.userFilterList removeAllObjects];
    
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([self.searchSelection isEqualToString:@"users"]) {
        if (isSearchString) {
            return [self.userFilterList count];
        } else {
            return [self.userList count];
        }
    } else {
        return [self.industry_datasource count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if ([self.searchSelection isEqualToString:@"users"]) {
        if (isSearchString) {
            cell.textLabel.text = [[self.userFilterList objectAtIndex:indexPath.row] objectForKey:@"displayName"];
        } else {
            cell.textLabel.text = [[self.userList objectAtIndex:indexPath.row] objectForKey:@"displayName"];
        }
    }
    else {
        cell.textLabel.text = [self.industry_datasource objectAtIndex:indexPath.row];
    }
    
    return cell;
    
}


@end
