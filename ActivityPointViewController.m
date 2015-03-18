//
//  ActivityPointViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-01-29.
//
//

#import "ActivityPointViewController.h"
#import "PAPAccountViewController.h"
#import "PAPLoginSelectionViewController.h"

#define PhotoHeaderViewHeight 44.0f

@interface ActivityPointViewController ()
@property (strong, nonatomic) UITableView *mainTableView;
@property (nonatomic, strong) NSArray *activeUserArray;

@end

@implementation ActivityPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type": @"Activity Points"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"activity_points_screen" action:@"viewing_activity_points" label:@"" value:@""];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"Activity Points"];
    
    //UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    self.mainTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mainTableView.backgroundColor = [UIColor whiteColor];
    self.mainTableView.allowsSelection = NO;
    [self.view addSubview:self.mainTableView];
    
    [SVProgressHUD show];
    
    
    PFQuery *activeUserQuery = [PFUser query];
    [activeUserQuery whereKeyExists:@"displayName"];
    [activeUserQuery whereKeyExists:@"activityPoints"];
    [activeUserQuery whereKey:@"displayName" notEqualTo:@"Teamstory"];
    [activeUserQuery orderByDescending:@"activityPoints"];
    [activeUserQuery setLimit:10];
    [activeUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.activeUserArray = objects;
            [self.mainTableView reloadData];
        } else {
            NSLog(@"loading query error : %@", error);
        }
        [SVProgressHUD dismiss];
    }];
}

#pragma UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 314.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PhotoHeaderViewHeight;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 314.0f)];
    [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_points.png"]]];
    
    float offset;
    offset = 20.0f;
    
    UILabel *activityPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0f, 70.0f - offset, 251.0f, 106.0f)];
    activityPointLabel.text = [(NSNumber *)[[PFUser currentUser] objectForKey:@"activityPoints"] stringValue];
    activityPointLabel.textAlignment = NSTextAlignmentCenter;
    activityPointLabel.textColor = [UIColor whiteColor];
    activityPointLabel.font = [UIFont boldSystemFontOfSize:80.0f];
    [headerView addSubview:activityPointLabel];
    
    UILabel *earnLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0f, 174.0f - offset, 48.0f, 23.0f)];
    earnLabel.textAlignment = NSTextAlignmentCenter;
    earnLabel.text = @"Earn";
    earnLabel.textColor = [UIColor whiteColor];
    earnLabel.font = [UIFont systemFontOfSize:16.0f];
    [headerView addSubview:earnLabel];
    
    UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(112.0f, 175.0f - offset, 135.0f, 21.0f)];
    pointLabel.textAlignment = NSTextAlignmentCenter;
    pointLabel.text = @"Teamstory Points";
    pointLabel.textColor = [UIColor whiteColor];
    pointLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [headerView addSubview:pointLabel];
    
    UILabel *restLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 193.0f - offset, [UIScreen mainScreen].bounds.size.width, 42.0f)];
    restLabel.numberOfLines = 2;
    restLabel.textAlignment = NSTextAlignmentCenter;
    restLabel.text = @"by liking, commenting and posting.\nBecome a Teamstory Hero!";
    restLabel.textColor = [UIColor whiteColor];
    restLabel.font = [UIFont systemFontOfSize:16.0f];
    [headerView addSubview:restLabel];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 249.0f, [UIScreen mainScreen].bounds.size.width, 65.0f)];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.text = @"Most Active People on Teamstory";
    headerLabel.textColor = [UIColor colorWithRed:146.0f/255.0f green:146.0f/255.0f blue:146.0f/255.0f alpha:1.0f];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0f];
    [headerView addSubview:headerLabel];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(266.0f, 20.0f, 46.0f, 37.0f)];
    [cancelButton setImage:[UIImage imageNamed:@"button_cancel.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:cancelButton];
    
    return headerView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.activeUserArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ActivityPointCell";
    
    PAPActivityPointCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PAPActivityPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    
    [cell.photoHeaderView setForActivityPointView:[self.activeUserArray objectAtIndex:indexPath.row]];
    return  cell;
}

- (void)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    
    if (user) {
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Selected In Activity Points" properties:@{@"Type": @"User", @"Name": [user objectForKey:@"displayName"]}];
        
        // flightrecorder event analytics
        [[FlightRecorder sharedInstance] trackEventWithCategory:@"selected_in_activity" action:@"user" label:@"" value:[user objectForKey:@"displayName"]];
        
        PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
        [accountViewController setUser:user];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:accountViewController];
        [self presentViewController:navController animated:YES completion:nil];
        
    }
}
@end
