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

@end

@implementation PAPdiscoverTileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.teamstoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        _tableReload = YES;
        
        // ----------------- initiate menues
        self.mainMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 44.0f)];
        self.mainMenuView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        [self addSubview:self.mainMenuView];
        
        self.momentsMenu = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width / 2, 44.0f)];
        [self.momentsMenu setTitle:@"Moments" forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.momentsMenu addTarget:self action:@selector(momentsMenuAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainMenuView addSubview:self.momentsMenu];
        
        self.thoughtsMenu = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 0.0f, [UIScreen mainScreen].bounds.size.width / 2, 44.0f)];
        [self.thoughtsMenu setTitle:@"Thoughts" forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.thoughtsMenu addTarget:self action:@selector(thoughtsMenuAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainMenuView addSubview:self.thoughtsMenu];
        
        self.highlightBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.0f, [UIScreen mainScreen].bounds.size.width / 2, 3.0f)];
        [self.highlightBar setBackgroundColor:self.teamstoryColor];
        [self.mainMenuView addSubview:self.highlightBar];
        
        self.menuSelection = @"Moments";
        [self labelSetting:@"Moments"];
        
        float searchBarHeight = 44.0f;
        float menuHeight = 44.0f;
        float tabBarHeight = 30.0f;
        
        
        // ------------- UITableView
        self.mainTileView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, menuHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (searchBarHeight + menuHeight + 39.0f + tabBarHeight)) style:UITableViewStylePlain];
        self.mainTileView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.mainTileView.delegate = self;
        self.mainTileView.dataSource = self;
        [self addSubview:self.mainTileView];
        
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

-(void) labelSetting:(NSString *)selected {
    if ([selected isEqualToString:@"Moments"]) {
        [self.momentsMenu setTitleColor:self.teamstoryColor forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.thoughtsMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [UIView animateWithDuration:0.1f animations:^{
            self.highlightBar.frame = CGRectMake(0.0f, 41.0f, [UIScreen mainScreen].bounds.size.width / 2, 3.0f);
        }];
    } else {
        [self.thoughtsMenu setTitleColor:self.teamstoryColor forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.momentsMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [UIView animateWithDuration:0.1f animations:^{
            self.highlightBar.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 41.0f, [UIScreen mainScreen].bounds.size.width / 2, 3.0f);
        }];
    }
    
}

- (void)setNavigationController:(UINavigationController *)navigationController {
    self.navController = navigationController;
}

# pragma UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.menuSelection isEqualToString:@"Moments"]) {
        return [self.pictureQuery count] / 3;
    } else {
        return [self.thoughtQuery count] / 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Calculating the total_number of rows.
    NSNumber *rowCount;
    
    if ([self.menuSelection isEqualToString:@"Moments"]) {
        rowCount = [NSNumber numberWithLong:[self.pictureQuery count] / 3 - 1];
    } else {
        rowCount = [NSNumber numberWithLong:[self.thoughtQuery count] / 3 - 1];
    }
    
    if ([rowCount intValue] == indexPath.row && _tableReload == YES) {
        _tableReload = NO;
        if ([self.menuSelection isEqualToString:@"Moments"]) {
            skipQueryCountPic = (NSUInteger *)[self.pictureQuery count];
            [self loadMoreCellforPic];
        } else {
            skipQueryCountThought = (NSUInteger *)[self.thoughtQuery count];
            [self loadMoreCellforThought];
        }
    }
    
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

@end