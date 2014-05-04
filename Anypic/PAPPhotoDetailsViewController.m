//
//  PAPPhotoDetailViewController.m
//  Teamstory
//
//

#import "PAPPhotoDetailsViewController.h"
#import "PAPBaseTextCell.h"
#import "PAPActivityCell.h"
#import "PAPPhotoDetailsFooterView.h"
#import "PAPConstants.h"
#import "PAPAccountViewController.h"
#import "PAPLoadMoreCell.h"
#import "PAPUtility.h"
#import "SVProgressHUD.h"


enum ActionSheetTags {
    MainActionSheetTag = 0,
    reportTypeTag = 1,
    deletePhoto = 2
};


@interface PAPPhotoDetailsViewController () {
    NSInteger text_location;
    NSInteger atmentionLength;
    NSRange atmentionRange;
    NSInteger text_offset;
}
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PAPPhotoDetailsHeaderView *headerView;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) PFObject *current_photo;
@property (nonatomic, strong) PFUser *reported_user;
@property (nonatomic, strong) UITextView *commentTextView;
@property (nonatomic, strong) PAPPhotoDetailsFooterView *footerView;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, strong) NSString *atmentionSearchString;
@property (nonatomic, strong) UITableView *autocompleteTableView;
@property (nonatomic, strong) NSArray *filteredArray;
@property (nonatomic, strong) NSString *cellType;
@property (nonatomic, strong) PFQuery *userQuery;
@property (nonatomic, strong) NSMutableArray *atmentionUserArray;
@property (nonatomic, strong) UIView *dimView;
@property CGRect defaultFooterViewFrame;
@property CGRect defaultCommentTextViewFrame;
@property CGRect previousRect;
@end

static const CGFloat kPAPCellInsetWidth = 7.5f;

@implementation PAPPhotoDetailsViewController

@synthesize commentTextField;
@synthesize photo, headerView;
@synthesize photoID;
@synthesize current_photo;
@synthesize reported_user;
@synthesize commentTextView;
@synthesize footerView;
@synthesize userArray;
@synthesize autocompleteTableView;
@synthesize atmentionSearchString;
@synthesize filteredArray;
@synthesize cellType;
@synthesize userQuery;
@synthesize atmentionUserArray;
@synthesize dimView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
}

- (id)initWithPhoto:(PFObject *)aPhoto source:(NSString *)source{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of comments to show per page
        self.objectsPerPage = 30;
        
        self.photo = aPhoto;
        
        self.likersQueryInProgress = NO;
        
        self.source = source;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    // set current default back button to nil and set new one
    self.navigationItem.leftBarButtonItem = nil;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake( 0.0f, 0.0f, 22.0f, 22.0f);
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // Set table view properties
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    NSString *caption_local = [self.photo objectForKey:@"caption"];
    
    if ([caption_local length] > 0) {
        CGSize maximumLabelSize = CGSizeMake(320.0f - 7.5f * 4, 9999.0f);
        CGSize expectedSize = [caption_local sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:maximumLabelSize];
        
        // Set table header
        self.headerView = [[PAPPhotoDetailsHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 351.0f + expectedSize.height + 43.0f) photo:self.photo description:caption_local navigationController:self.navigationController];
        self.headerView.delegate = self;
        self.tableView.tableHeaderView = self.headerView;
    } else {
        self.headerView = [[PAPPhotoDetailsHeaderView alloc] initWithFrame:[PAPPhotoDetailsHeaderView rectForView] photo:self.photo description:nil navigationController:self.navigationController];
        self.headerView.delegate = self;
        self.tableView.tableHeaderView = self.headerView;
    }
    
    self.dimView = [[UIView alloc] init];
    self.dimView.hidden = YES;
    self.dimView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];
    [self.view addSubview:self.dimView];
    
    
    // Set table footer
    
    self.footerView = [[PAPPhotoDetailsFooterView alloc] initWithFrame:[PAPPhotoDetailsFooterView rectForView]];
    commentTextView = footerView.commentView;
    self.defaultFooterViewFrame = self.footerView.mainView.frame;
    self.defaultCommentTextViewFrame = self.commentTextView.frame;
    commentTextView.delegate = self;
    self.tableView.tableFooterView = self.footerView;
    
    
    self.autocompleteTableView = [[UITableView alloc] init];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:self.autocompleteTableView];



    /*
    if ([self currentUserOwnsPhoto]) {
        
        // Else we only want to show an action button if the user owns the photo and has permission to delete it.
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake( 0.0f, 0.0f, 22.0f, 22.0f);
        [shareButton addTarget:self action:@selector(actionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
        
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonAction:)];
    } else if (NSClassFromString(@"UIActivityViewController")) {
        // Use UIActivityViewController if it is available (iOS 6 +)
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(activityButtonAction:)];
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake( 0.0f, 0.0f, 22.0f, 22.0f);
        [shareButton addTarget:self action:@selector(activityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setBackgroundImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
        
        
    }
     */
    /*
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake( 0.0f, 0.0f, 22.0f, 22.0f);
    [shareButton addTarget:self action:@selector(activityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
     */
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedPhoto:) name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];

}

- (void)createOutstandingViews {
    
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
    self.autocompleteTableView.hidden = YES;
    self.dimView.hidden = YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.previousRect = CGRectZero;

    [self.headerView reloadLikeBar];
    
    // we will only hit the network if we have no cached data for this photo
    BOOL hasCachedLikers = [[PAPCache sharedCache] attributesForPhoto:self.photo] != nil;
    if (!hasCachedLikers) {
        [self loadLikers];
    }
    
    if(self.objects.count > 0 && ([self.source isEqual:@"notificationComment"] ||[self.source isEqual:@"activityComment"])){
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height + 44)];
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.autocompleteTableView && indexPath.row < self.objects.count) { // A comment row
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if (object) {
            NSString *commentString = [self.objects[indexPath.row] objectForKey:kPAPActivityContentKey];
            
            PFUser *commentAuthor = (PFUser *)[object objectForKey:kPAPActivityFromUserKey];
            
            NSString *nameString = @"";
            if (commentAuthor) {
                nameString = [commentAuthor objectForKey:kPAPUserDisplayNameKey];
            }
            
            return [PAPBaseTextCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kPAPCellInsetWidth];
            
        }
    }
    
    // The pagination row
    return 44.0f;
}

#pragma mark - PFQueryTableViewController
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPAPActivityPhotoKey equalTo:self.photo];
    [query includeKey:kPAPActivityFromUserKey];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    [query orderByAscending:@"createdAt"];

    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    /*
    SEL isParseReachableSelector = sel_registerName("isParseReachable");
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:isParseReachableSelector]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
     */
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {

    [super objectsDidLoad:error];
    [self.headerView reloadLikeBar];
    [self loadLikers];
    
    if(self.objects.count > 0 && ([self.source isEqual:@"notificationComment"] ||[self.source isEqual:@"activityComment"])){
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height + 44)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView != self.autocompleteTableView) {
        static NSString *cellID = @"CommentCell";
        // Try to dequeue a cell and create one if necessary
        PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.cellInsetWidth = kPAPCellInsetWidth;
            cell.delegate = self;
        }
        [cell navigationController:self.navigationController];
        [cell setUser:[[self.objects objectAtIndex:indexPath.row] objectForKey:kPAPActivityFromUserKey]];
        [cell setContentText:[[self.objects objectAtIndex:indexPath.row] objectForKey:kPAPActivityContentKey]];
        [cell setDate:[[self.objects objectAtIndex:indexPath.row] createdAt]];
        [self setLikedComments:cell comment:[self.objects objectAtIndex:indexPath.row]];
        
        return cell;
    } else {
        static NSString *cellID = @"atmentionCell";
        // Try to dequeue a cell and create one if necessary
        PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.delegate = self;
        }
        [cell setUser:[self.filteredArray objectAtIndex:indexPath.row]];
        [cell setContentText:@" "];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.autocompleteTableView) {
        return [self.filteredArray count];
    } else {
        return [self.objects count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
}

#pragma mark - UITextViewDelegate


- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([[textView text] isEqualToString:@"Add a comment"]) {
        [textView setText:@""];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text length] == 0) {
        // reset default text view and frame
        [textView setText:@"Add a comment"];
        self.footerView.mainView.frame = self.defaultFooterViewFrame;
        textView.frame = self.defaultCommentTextViewFrame;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    
    UITextPosition* pos = textView.endOfDocument;
    CGRect currentRect = [textView caretRectForPosition:pos];
    
    CGRect frame = textView.frame;
    frame.size.height = [textView contentSize].height;
    textView.frame = frame;
    
    if (text_offset == NSNotFound) {
        text_offset = 0;
    }

    // Expandable textview.
    if (currentRect.origin.y > self.previousRect.origin.y && self.previousRect.origin.y != 0){
        text_offset += 15.0f;
        self.footerView.mainView.frame = CGRectMake(self.footerView.mainView.frame.origin.x, self.footerView.mainView.frame.origin.y, self.footerView.mainView.frame.size.width, frame.size.height + 20);
        [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentOffset.y + 15) animated:YES];
    }else if (currentRect.origin.y < self.previousRect.origin.y && self.previousRect.origin.y != 0){
        text_offset -= 15.0f;
        self.footerView.mainView.frame = CGRectMake(self.footerView.mainView.frame.origin.x, self.footerView.mainView.frame.origin.y, self.footerView.mainView.frame.size.width, frame.size.height + 20);
        [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentOffset.y  - 15) animated:YES];
    }
    
    self.previousRect = currentRect;
}


- (BOOL) textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text{
    if ([cellType isEqualToString:@"atmentionCell"]) {
        text = [text stringByAppendingString:@" "];
        textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length + 1) withString:text];
        
        cellType = nil;
        return YES;
    }
    
    if ([text isEqualToString:@"@"]){
        [SVProgressHUD show];
        
        if ([self.userArray count] < 1) {
            userQuery = [PFUser query];
            [userQuery whereKeyExists:@"displayName"];
            [userQuery orderByAscending:@"displayName"];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [SVProgressHUD dismiss];
                if (!error) {
                    self.userArray = [[NSMutableArray alloc] initWithArray:objects];
                    self.atmentionUserArray = [[NSMutableArray alloc] init];
                    self.filteredArray = objects;
                    self.autocompleteTableView.backgroundColor = [UIColor clearColor];
                    
                } else {
                    NSLog(@"%@", error);
                }
            }]; } else {
                [SVProgressHUD dismiss];
            }
        
    } else if ([text isEqualToString:@"\n"]) {
        NSString *trimmedComment = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (trimmedComment.length != 0 && [self.photo objectForKey:kPAPPhotoUserKey]) {
            PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
            [comment setObject:trimmedComment forKey:kPAPActivityContentKey]; // Set comment text
            [comment setObject:[self.photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey]; // Set toUser
            [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
            [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
            [comment setObject:self.photo forKey:kPAPActivityPhotoKey];
            
            // storing atmention user list to the array (only filtered cases).
            if ([self.atmentionUserArray count] > 0) {
                NSArray *mod_atmentionUserArray = [self.atmentionUserArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName IN %@", textView.text]];
                [comment setObject:mod_atmentionUserArray forKey:@"atmention"];
            }
            
            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [ACL setPublicReadAccess:YES];
            [ACL setWriteAccess:YES forUser:[self.photo objectForKey:kPAPPhotoUserKey]];
            comment.ACL = ACL;
            
            [[PAPCache sharedCache] incrementCommentCountForPhoto:self.photo];
            
            // Show HUD view
            [SVProgressHUD show];
            
            // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": comment} repeats:NO];
            
            [comment saveEventually:^(BOOL succeeded, NSError *error) {
                [timer invalidate];
                
                if (error && error.code == kPFErrorObjectNotFound) {
                    [[PAPCache sharedCache] decrementCommentCountForPhoto:self.photo];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not post comment", nil) message:NSLocalizedString(@"This photo is no longer available", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:self.photo userInfo:@{@"comments": @(self.objects.count + 1)}];
                
                self.atmentionUserArray = nil;
                self.atmentionUserArray = [[NSMutableArray alloc] init];
                [SVProgressHUD dismiss];
                [self loadObjects];
                
                // suscribe to post if commenter is not photo owner
                if(![[[self.photo objectForKey:kPAPPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]){
                    [PAPUtility updateSubscriptionToPost:self.photo.objectId forState:@"Subscribe"];
                }
                
            }];
        }
        
        [textView setText:@""];
        [textView resignFirstResponder];
        return NO;
    }
    
    if ([self.userArray count] > 0) {
        NSMutableString *updatedText = [[NSMutableString alloc] initWithString:textView.text];
        if (range.location == 0 || range.location == text_location) {
            self.autocompleteTableView.hidden = YES;
            self.dimView.hidden = YES;
            self.tableView.scrollEnabled = YES;
            text_location = 0;
        } else if (range.location > 0 && [[updatedText substringWithRange:NSMakeRange(range.location - 1, 1)] isEqualToString:@"@"]) {
            text_location = range.location;
        }
        
        if ([text isEqualToString:@""] && text_location > 1) {
            range.location -=1;
            
            if (text_location > range.location) {
                text_location -= 1;
            }
        }
        
        if (text_location > 0) {
            if (range.location == NSNotFound) {
                NSLog(@"range location not found");
            } else {
                atmentionRange = NSMakeRange(text_location, range.location - text_location);
                atmentionSearchString = [updatedText substringWithRange:atmentionRange];
                atmentionSearchString = [atmentionSearchString stringByAppendingString:text];
            }
            
            self.filteredArray = [self.userArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", atmentionSearchString]];
            
            // frames should be handled differently for iphone 4 and 5.
            if ([UIScreen mainScreen].bounds.size.height == 480) {
                self.dimView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 9999.0f);
                self.autocompleteTableView.frame = CGRectMake(7.5f, self.tableView.contentSize.height - 212.0f + text_offset, 305.0f, 143.0f - text_offset);
            } else {
                self.dimView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 9999.0f);
                self.autocompleteTableView.frame = CGRectMake(7.5f, self.tableView.contentSize.height - 302.0f + text_offset, 305.0f, 232.0f - text_offset);
            }
            
            if ([self.filteredArray count] < 1) {
                self.dimView.hidden = YES;
            } else {
                self.dimView.hidden = NO;
            }

            self.autocompleteTableView.hidden = NO;
            self.tableView.scrollEnabled = NO;
            [self.autocompleteTableView reloadData];
        }
    }

    return YES;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextField resignFirstResponder];
    [scrollView setShowsVerticalScrollIndicator:NO];
}


#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser cellType:(NSString *)acellType{
    if ([acellType isEqualToString:@"atmentionCell"]) {
        cellType = acellType;
        text_location = 0;
        [self textView:commentTextView shouldChangeTextInRange:atmentionRange replacementText:[aUser objectForKey:@"displayName"]];
        self.autocompleteTableView.hidden = YES;
        self.dimView.hidden = YES;
        self.tableView.scrollEnabled = YES;
        [self.atmentionUserArray addObject:aUser];
    } else {
        [self shouldPresentAccountViewForUser:aUser];
    }
}

- (void)didTapCommentLikeButton:(PAPBaseTextCell *)cellView{
    
    // set button as liked
    UIButton *cellLikeCommentButton = cellView.likeCommentButton;
    UILabel *cellLikeCommentCount = cellView.likeCommentCount;
    BOOL liked = !cellLikeCommentButton.selected;
    [cellView setLikeCommentButtonState:liked];
    
    // get comment object
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cellView];
    PFObject *likedComment = [self.objects  objectAtIndex:cellIndexPath.row];
    
    // disable like button temp
    [cellView shouldEnableLikeCommentButton:NO];
    
    // get count from button string
   // NSString *originalButtonTitle = cellLikeCommentCountButton.titleLabel.text;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSNumber *likeCommentCount = [numberFormatter numberFromString:cellLikeCommentCount.text];
    
    if (liked) {
        
        // analytics
     //  [PAPUtility captureEventGA:@"Engagement" action:@"Like Comment" label:@"Photo"];
        likeCommentCount = [NSNumber numberWithInt:[likeCommentCount intValue] + 1];
    //    [[PAPCache sharedCache] incrementLikerCountForPhoto:photo];
    } else {
        if ([likeCommentCount intValue] > 0) {
            likeCommentCount = [NSNumber numberWithInt:[likeCommentCount intValue] - 1];
            
            // if likes equal to 0, remove heart and counter
            if([likeCommentCount intValue] == 0){
                [cellView removeCommentCountHeart];
            }
        }
      //  [[PAPCache sharedCache] decrementLikerCountForPhoto:photo];
    }
    
    //[[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:photo liked:liked];
    
    if (liked == YES) {
        [cellLikeCommentCount setText:[numberFormatter stringFromNumber:likeCommentCount]];
    } else if (liked == NO) {
        [cellLikeCommentCount setText:[numberFormatter stringFromNumber:likeCommentCount]];
    }
    
    if (liked) {
        [PAPUtility likeCommentInBackground:likedComment photo:self.photo block:^(BOOL succeeded, NSError *error) {
            [cellView shouldEnableLikeCommentButton:YES];
            if (!succeeded) {
                [cellView setLikeCommentButtonState:NO];
            }
        }];
        
    } else {
        [PAPUtility unlikeCommentInBackground:likedComment block:^(BOOL succeeded, NSError *error) {
            [cellView shouldEnableLikeCommentButton:YES];
            if (!succeeded) {
                [cellView setLikeCommentButtonState:YES];
            }
        }];
    }
}




#pragma mark - PAPPhotoDetailsHeaderViewDelegate

-(void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

#pragma mark - ()

-(void)setLikedComments:(PAPBaseTextCell *)cellView comment:(PFObject *)comment{
    
    // get button counter
    UILabel *cellLikeCommentCount = cellView.likeCommentCount;
    
    // get all likes for comment
    PFQuery *queryExistingCommentLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingCommentLikes whereKey:@"forComment" equalTo:comment];
    [queryExistingCommentLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLikeComment];
    [queryExistingCommentLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingCommentLikes includeKey:kPAPActivityFromUserKey];
    [queryExistingCommentLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            // get count from button string
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            NSNumber *likeCommentCount = [numberFormatter numberFromString:cellLikeCommentCount.text];
            
            if ([activities count] != 0) {
                
                // show heart + new count
                [cellView setLikeCommentButtonState:YES];
                likeCommentCount = [NSNumber numberWithInteger:[activities count]];
                [cellLikeCommentCount setText:[numberFormatter stringFromNumber:likeCommentCount]];
            }
            
            BOOL userLikesComment = NO;
            
            for (PFObject *activity in activities) {
                
                // mark as liked if user has liked comment
                if([[[activity objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]){
                    userLikesComment = YES;
                }
            }
            
            [cellView setLikeCommentButtonState:userLikesComment];
        }
        
    }];
    
}


- (void) moreActionButton_inflator:(PFUser *)user photo:(PFObject *)user_photo {
    self.photoID = [user_photo objectId];
    self.reported_user = [user objectForKey:@"displayName"];
    self.current_photo = user_photo;
    
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
            
            //NSLog(@"%@", kPAPPhotoClassKey);
            
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Successful" message:@"Message has been successfully sent" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alertView show];
            break;
        }
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your message was not sent! Please check your internet connection!" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alertView show];
            break;
        }
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)handleCommentTimeout:(NSTimer *)aTimer {
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Comment", nil) message:NSLocalizedString(@"Your comment will be posted next time there is an Internet connection.", nil)  delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil];
    [alert show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userLikedOrUnlikedPhoto:(NSNotification *)note {
    

    [self.headerView reloadLikeBar];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSInteger offset = 0.0f;
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        offset = 60.0f;
    } else {
        offset = 150.0f;
    }
    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height-kbSize.height - offset) animated:YES];
}

- (void)loadLikers {
    if (self.likersQueryInProgress) {
        return;
    }

    self.likersQueryInProgress = YES;
    PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.likersQueryInProgress = NO;
        if (error) {
            [self.headerView reloadLikeBar];
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
        [self.headerView reloadLikeBar];
    }];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self.refreshControl endRefreshing];
    self.tableView.scrollEnabled = YES;
}
@end
