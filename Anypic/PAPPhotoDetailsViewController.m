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
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "AppDelegate.h"
#import "Intercom.h"
#import "AtMention.h"

#define APP ((AppDelegate *)[[UIApplication sharedApplication] delegate])

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
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) PAPPhotoDetailsHeaderView *headerView;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) PFObject *current_photo;
@property (nonatomic, strong) PFUser *reported_user;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSMutableArray *userList;
@property (nonatomic, strong) NSString *atmentionSearchString;
@property (nonatomic, strong) UITableView *autocompleteTableView;
@property (nonatomic, strong) NSArray *filteredArray;
@property (nonatomic, strong) NSString *cellType;
@property (nonatomic, strong) PFQuery *userQuery;
@property (nonatomic, strong) NSMutableArray *atmentionUserArray;
@property (nonatomic, strong) NSMutableArray *atmentionUserNames;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIView *hideCommentsView;
@property CGFloat previousKbHeight;
@end

static const CGFloat kPAPCellInsetWidth = 7.5f;

@implementation PAPPhotoDetailsViewController

@synthesize photo, headerView;
@synthesize photoID;
@synthesize current_photo;
@synthesize reported_user;
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
    
    self = [super init];
    
    if (self) {
        
        self.photo = aPhoto;
        
        self.likersQueryInProgress = NO;
        
        // notification or activity item source
        self.source = source;
        
        self.postDetails = [[UITableView alloc] init];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.postDetails setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.postDetails.delegate = self;
    self.postDetails.dataSource = self;
    self.postDetails.frame = self.view.frame;
    [self.postDetails setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    [self.view addSubview:self.postDetails];
    
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    [self.navigationItem.titleView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapNavTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTop)];
    [self.navigationItem.titleView addGestureRecognizer:tapNavTitle];
    
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
    self.postDetails.backgroundView = texturedBackgroundView;
    
    
    NSString *caption_local = [self.photo objectForKey:@"caption"];
    
    if ([caption_local length] > 0) {
        
        CGSize maximumLabelSize = CGSizeMake(320.0f - 7.5f * 4, MAXFLOAT);
        
        
        CGSize expectedSize = ([caption_local boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil]).size;
        
        // Set table header
        if ([[self.photo objectForKey:@"type"] isEqualToString:@"link"]) {
            self.headerView = [[PAPPhotoDetailsHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 146.0f + expectedSize.height + 56.0f + 15.0f) photo:self.photo description:caption_local navigationController:self.navigationController];
        } else {
            
            self.headerView = [[PAPPhotoDetailsHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 351.0f + expectedSize.height + 43.0f + 37.0f + 15.0f) photo:self.photo description:caption_local navigationController:self.navigationController];
        }
        self.headerView.delegate = self;
        self.postDetails.tableHeaderView = self.headerView;
    } else {
        if ([[self.photo objectForKey:@"type"] isEqualToString:@"link"]) {
            self.headerView = [[PAPPhotoDetailsHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 187.0f) photo:self.photo description:nil navigationController:self.navigationController];
        } else {
            self.headerView = [[PAPPhotoDetailsHeaderView alloc] initWithFrame:[PAPPhotoDetailsHeaderView rectForView] photo:self.photo description:nil navigationController:self.navigationController];
        }
        self.headerView.delegate = self;
        self.postDetails.tableHeaderView = self.headerView;
    }
    
    self.dimView = [[UIView alloc] init];
    self.dimView.hidden = YES;
    self.dimView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];
    [self.view addSubview:self.dimView];
    
    self.autocompleteTableView = [[UITableView alloc] init];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:self.autocompleteTableView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedPhoto:) name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
    
    // set comment block view for spinner
    float tableCommentVerticalPos = self.postDetails.tableHeaderView.frame.origin.y + self.postDetails.tableHeaderView.frame.size.height;
    
    // make this tall enough to cover all comments
    float tableCommentHeight = self.postDetails.frame.size.height * 4;
    self.hideCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, tableCommentVerticalPos, 320.0f, tableCommentHeight)];
    [self.hideCommentsView setBackgroundColor:[UIColor whiteColor]];
    
    // set spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.postDetails.frame.size.width/2 - 50,0,100,100)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.spinner.color = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    [self.hideCommentsView addSubview:self.spinner];
    
    self.spinner.hidesWhenStopped = YES;
    self.postDetails.showsVerticalScrollIndicator = NO;
    
    [self loadObjects];
    
    NSString *postType = [self.photo objectForKey:@"type"] != nil ? [self.photo objectForKey:@"type"] : @"";
    
    self.customKeyboard = [[CustomKeyboardViewController alloc] initWithNibName:@"CustomKeyboardViewController" bundle:nil];
    self.customKeyboard.delegate = self;
    [self.customKeyboard setTextViewPosition:64];
    [self.customKeyboard setPostType:postType];
    [self.customKeyboard.sendButton setTitle:@"Post" forState:UIControlStateNormal];
    self.customKeyboard.view.layer.zPosition = 100;
    [self.customKeyboard setBackgroundTable:self.postDetails];
    [self.view addSubview:self.customKeyboard.view];
    
    // at mention
    self.filteredArray = [[NSMutableArray alloc]init];
    self.atmentionUserArray = [[NSMutableArray alloc] init];
    self.atmentionUserNames = [[NSMutableArray alloc] init];
    self.autocompleteTableView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.headerView reloadLikeBar];
    
    // we will only hit the network if we have no cached data for this photo
    BOOL hasCachedLikers = [[PAPCache sharedCache] attributesForPhoto:self.photo] != nil;
    if (!hasCachedLikers) {
        [self loadLikers];
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

- (void)loadObjects {
    
    PFQuery *commentQuery = [PFQuery queryWithClassName:@"Activity"];
    [commentQuery whereKey:kPAPActivityPhotoKey equalTo:self.photo];
    [commentQuery includeKey:kPAPActivityFromUserKey];
    [commentQuery includeKey:@"User"];
    [commentQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    [commentQuery orderByAscending:@"createdAt"];
    [commentQuery setCachePolicy:kPFCachePolicyNetworkOnly];

    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.objects = [NSMutableArray arrayWithArray:objects];
            [self objectsDidLoad:error];
        }
    }];
}

- (void)objectsDidLoad:(NSError *)error {
    
    [self.headerView reloadLikeBar];
    [self loadLikers];
    
    BOOL newLikes = [self.source isEqual:@"activityLikeComment"] || [self.source isEqual:@"notificationLikeComment"];
    
    // send mutable copy of objects
    NSMutableArray *loadedObjects = [[NSMutableArray alloc]initWithArray:self.objects];
    
    // refresh based on source when comments are present
    if([loadedObjects count] > 0){
        
        [self refreshCommentLikes:loadedObjects pullFromServer:newLikes block:^(BOOL succeeded) {
            if(succeeded){
                
                // move to last comments when notification relates to a new comment
                if(self.objects.count > 0 && ([self.source isEqual:@"notificationComment"] || [self.source isEqual:@"activityComment"] || [self.source isEqual:@"commentButton"] || [self.source isEqual:@"postedComment"]  )){
                    
                    
                    float newVerticalPos = self.postDetails.contentSize.height - self.postDetails.bounds.size.height + 84;
                    
                    if(newVerticalPos > 0){
                        [self.postDetails setContentOffset:CGPointMake(0, newVerticalPos)];
                    }
                    
                    if([self.source isEqualToString:@"commentButton"]){
                        [self.customKeyboard setObjCount:[loadedObjects count]];
                        [self.customKeyboard.messageTextView becomeFirstResponder];
                    }
                    
                }
            }
        }];
    }
    
    [self.postDetails reloadData];
    
    
    if([self.source isEqualToString:@"commentButton"] && [loadedObjects count] == 0){
        
        [self.customKeyboard setObjCount:0];
        [self.customKeyboard.messageTextView becomeFirstResponder];
        
        float newVerticalPos = self.postDetails.contentSize.height - self.postDetails.bounds.size.height + 44;
        
        if(newVerticalPos > 0){
            [self.postDetails setContentOffset:CGPointMake(0, newVerticalPos)];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView != self.autocompleteTableView) {
        NSString *cellID = @"CommentCell";
        
        if ([[[PFUser currentUser] objectId] isEqualToString:[[[self.objects objectAtIndex:indexPath.row] objectForKey:@"fromUser"] objectId]]) {
            cellID = @"CommentCellCurrentUser";
        }
        // Try to dequeue a cell and create one if necessary
        PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil) {
            cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.cellInsetWidth = kPAPCellInsetWidth;
            cell.delegate = self;
        }
        [cell navigationController:self.navigationController];
        [cell object:[self.objects objectAtIndex:indexPath.row]];
        
        NSLog(@"%@", [[self.objects objectAtIndex:indexPath.row] objectForKey:@"atmention_names"]);
        
        [cell setParentView:self.view];
        [cell photo:self.photo];
        
        [cell setUser:[[self.objects objectAtIndex:indexPath.row] objectForKey:kPAPActivityFromUserKey]];
        [cell setContentText:[[self.objects objectAtIndex:indexPath.row] objectForKey:kPAPActivityContentKey]];
        [cell setDate:[[self.objects objectAtIndex:indexPath.row] createdAt]];
        
        // get comment info from cache
        NSDictionary *attributesForComment = [[PAPCache sharedCache] attributesForComment:[self.objects objectAtIndex:indexPath.row]];
        
        // reset default attributes for cell comments -- need to refactor this into own method
        cell.likeCommentHeart.hidden = YES;
        cell.likeCommentCount.hidden = YES;
        cell.likeCommentButton.selected = NO;
        cell.likeCommentHeart.selected = NO;
        
        if(attributesForComment){
            
            NSNumber *likeCount = [attributesForComment objectForKey:kPAPCommentAttributesLikeCountKey];
            
            // take out heart and count if like count is 0
            if([likeCount intValue] != 0){
                // set properties
                BOOL likedByCurrentUser = [[PAPCache sharedCache] isCommentLikedByCurrentUser:[self.objects objectAtIndex:indexPath.row]];
                
                [cell setLikeCommentButtonState:YES forCurrentUser:likedByCurrentUser];
                [cell.likeCommentCount setText:[likeCount stringValue]];
            }
        }
        
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

#pragma mark - CustomKeyboardDelegate & Related

- (void)dismissKeyboard {
    self.autocompleteTableView.hidden = YES;
    self.dimView.hidden = YES;
    [self.customKeyboard dismissKeyboard];
}


- (void)keyboardDidBeginEditing{
    
    // get post type
    NSString *postType = [self.photo objectForKey:@"type"] != nil ? [self.photo objectForKey:@"type"] : @"";
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Started Writing Comment" properties:@{@"Post Type" : postType}];
}

- (BOOL)keyboardShouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text{
    
    if ([cellType isEqualToString:@"atmentionCell"]) {
        text = [text stringByAppendingString:@" "];
        
        if (range.location != NSNotFound) {
            
            
            /* If the user presses the Delete key, the length of the range is 1 and an empty string object replaces that single character. Goes out of bounds when user presses delete and selects display name at the start of message.*/
            
            long replacementRange = range.length + 1;
            
            // Check if new range is in bounds of current text, accounting for extra key when deleting
            if(replacementRange < self.customKeyboard.messageTextView.text.length){
                self.customKeyboard.messageTextView.text = [self.customKeyboard.messageTextView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, replacementRange) withString:text];
            }else{
                self.customKeyboard.messageTextView.text = [self.customKeyboard.messageTextView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
            }
        }
        
        cellType = nil;
        return YES;
    }
    
    // at mention, setting users
    if ([text isEqualToString:@"@"]){
        self.userList = [[AtMention sharedAtMention] userList];
        self.filteredArray = self.userList;
    }
    
    if ([self.userList count] > 0) {
        NSMutableString *updatedText = [[NSMutableString alloc] initWithString:self.customKeyboard.messageTextView.text];
        if (range.location == 0 || range.location == text_location) {
            self.autocompleteTableView.hidden = YES;
            self.dimView.hidden = YES;
            self.postDetails.scrollEnabled = YES;
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
            
            self.filteredArray = [self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", atmentionSearchString]];
            
            // Check system version for keyboard offset, ios8 added suggestion bar
            // Align the mention table view
            self.dimView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 9999.0f);
            
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
                self.autocompleteTableView.frame = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.frame.size.height - self.customKeyboard.view.frame.size.height - 273);
            }else{
                self.autocompleteTableView.frame = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.frame.size.height - self.customKeyboard.view.frame.size.height - 273 + 37);
            }
            
            if ([self.filteredArray count] < 1) {
                self.dimView.hidden = YES;
            } else {
                self.dimView.hidden = NO;
            }
            
            self.autocompleteTableView.hidden = NO;
            self.postDetails.scrollEnabled = NO;
            [self.autocompleteTableView reloadData];
        }
    }
    
    return YES;
}

- (void)sendButtonAction:(id)sender{
    
    // hide mention tableview
    self.autocompleteTableView.hidden = YES;
    self.dimView.hidden = YES;
    
    NSString *trimmedComment = [self.customKeyboard.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedComment.length != 0 && [self.photo objectForKey:kPAPPhotoUserKey]) {
        
        PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
        [comment setObject:trimmedComment forKey:kPAPActivityContentKey]; // Set comment text
        [comment setObject:[self.photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey]; // Set toUser
        [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
        [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
        [comment setObject:self.photo forKey:kPAPActivityPhotoKey];
        
        // storing atmention user list to the array (only filtered cases).
        if ([self.atmentionUserArray count] > 0) {
            NSArray *mod_atmentionUserArray = [self.atmentionUserArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName IN %@", self.customKeyboard.messageTextView.text]];
            
            NSArray *mod_atmentionUserNames = [self.atmentionUserNames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"MATCHES %@", self.customKeyboard.messageTextView.text]];
            
            [comment setObject:mod_atmentionUserArray forKey:@"atmention"];
            [comment setObject:mod_atmentionUserNames forKey:@"atmention_names"];
        }
        
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.photo objectForKey:kPAPPhotoUserKey]];
        comment.ACL = ACL;
        
        [[PAPCache sharedCache] incrementCommentCountForPhoto:self.photo];
        
        // get post type
        NSString *postType = [self.photo objectForKey:@"type"] != nil ? [self.photo objectForKey:@"type"] : @"";
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Commented", @"Post Type" : postType}];
        
        // intercome analytics
        [Intercom logEventWithName:@"commented" optionalMetaData:nil
                        completion:^(NSError *error) {}];

        
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
            self.atmentionUserNames = [[NSMutableArray alloc]init];
            
            [SVProgressHUD dismiss];
            [self loadObjects];
            
            // suscribe to post if commenter is not photo owner
            if(![[[self.photo objectForKey:kPAPPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]){
                [PAPUtility updateSubscriptionToPost:self.photo forState:@"Subscribe"];
            }
            
        }];
        
        // reset textview to default height, update flag so table goes to posted comment
        [self.customKeyboard.messageTextView setText:@""];
        [self.customKeyboard.messageTextView resignFirstResponder];
        [self.customKeyboard resetTextViewHeight];
        [self.customKeyboard setTextViewPosition:64];
        self.source = @"postedComment";
    }
}


#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser cellType:(NSString *)acellType{
    if ([acellType isEqualToString:@"atmentionCell"]) {
        cellType = acellType;
        text_location = 0;
        
        if (atmentionRange.location != NSNotFound) {
            [self keyboardShouldChangeTextInRange:atmentionRange replacementText:[aUser objectForKey:@"displayName"]];
        }
        
        self.autocompleteTableView.hidden = YES;
        self.dimView.hidden = YES;
        self.postDetails.scrollEnabled = YES;
        
        [self.atmentionUserArray addObject:aUser];
        [self.atmentionUserNames addObject:[@"@" stringByAppendingString:[aUser objectForKey:@"displayName"]]];
    } else {
        [self shouldPresentAccountViewForUser:aUser];
    }
}

- (void)didTapCommentLikeButton:(PAPBaseTextCell *)cellView{
    
    // set button as liked
    UIButton *cellLikeCommentButton = cellView.likeCommentButton;
    UILabel *cellLikeCommentCount = cellView.likeCommentCount;
    BOOL liked = !cellLikeCommentButton.selected;
    
    [cellView setLikeCommentButtonState:liked forCurrentUser:YES];
    
    // get comment object
    NSIndexPath *cellIndexPath = [self.postDetails indexPathForCell:cellView];
    PFObject *comment = [self.objects  objectAtIndex:cellIndexPath.row];
    
    // disable like button temp
    [cellView shouldEnableLikeCommentButton:NO];
    
    // get count from button string
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSNumber *likeCommentCount = [numberFormatter numberFromString:cellLikeCommentCount.text];
    
    if (liked) {
        
        // analytics
        [PAPUtility captureEventGA:@"Engagement" action:@"Like Comment" label:@"Photo"];
        
        // get post type
        NSString *postType = [self.photo objectForKey:@"type"] != nil ? [self.photo objectForKey:@"type"] : @"";
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Liked Comment", @"Post Type": postType}];
    
        // increment user like comment count by one
        [[Mixpanel sharedInstance].people increment:@"Like Comment Count" by:[NSNumber numberWithInt:1]];
        
        // intercom analytics
        [Intercom logEventWithName:@"liked-comment" optionalMetaData:nil
                        completion:^(NSError *error) {}];
        
        
        likeCommentCount = [NSNumber numberWithInt:[likeCommentCount intValue] + 1];
        
        // increment in cache
        [[PAPCache sharedCache] incrementLikerCountForComment:comment];
        
    } else {
        if ([likeCommentCount intValue] > 0) {
            likeCommentCount = [NSNumber numberWithInt:[likeCommentCount intValue] - 1];
            
            // if likes equal to 0, remove heart and counter
            if([likeCommentCount intValue] == 0){
                [cellView removeCommentCountHeart];
            }
        }
        
        // decrement in cache
        [[PAPCache sharedCache] decrementLikerCountForComment:comment];
    }
    
    // update liked by current user in cache
    [[PAPCache sharedCache] setCommentIsLikedByCurrentUser:comment liked:liked];
    
    [cellLikeCommentCount setText:[numberFormatter stringFromNumber:likeCommentCount]];
    
    if (liked) {
        [PAPUtility likeCommentInBackground:comment photo:self.photo block:^(BOOL succeeded, NSError *error) {
            [cellView shouldEnableLikeCommentButton:YES];
            if (!succeeded) {
                [cellView setLikeCommentButtonState:NO forCurrentUser:YES];
            }
        }];
        
    } else {
        [PAPUtility unlikeCommentInBackground:comment block:^(BOOL succeeded, NSError *error) {
            [cellView shouldEnableLikeCommentButton:YES];
            if (!succeeded) {
                [cellView setLikeCommentButtonState:YES forCurrentUser:YES];
            }
        }];
    }
}

#pragma mark - PAPPhotoDetailsHeaderViewDelegate

-(void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

#pragma mark - ()

- (void)scrollToTop{
    
    // scroll to the top (header view incl.)
    [self.postDetails scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)refreshCommentLikes:(NSMutableArray *)comments pullFromServer:(BOOL)pullFromServer block:(void (^)(BOOL succeeded))completionBlock{
    
    //start spinner
    [self.spinner startAnimating];
    [self.postDetails addSubview:self.hideCommentsView];
    
    //refresh comment(s) on background thread
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // set like comments for loaded comments
        for (PFObject *obj in comments) {
            [self setLikedComments:obj refreshCache:pullFromServer];
        }
        
        // reload table with updated data from cache/server
        [self.postDetails reloadData];
        
        // hide spinner and blocking comments view
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            [self.hideCommentsView removeFromSuperview];
            completionBlock(YES);
        });
    });
}

-(void)setLikedComments:(PFObject *)comment refreshCache:(BOOL)refreshCache{
    
    // get comment info from cache
    NSDictionary *attributesForComment = [[PAPCache sharedCache] attributesForComment:comment];
    
    // check cache before pulling from server or pull directly if refresh flag true
    if (!attributesForComment || refreshCache){
        
        // get all likes for comment
        PFQuery *queryExistingCommentLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryExistingCommentLikes whereKey:@"forComment" equalTo:comment];
        [queryExistingCommentLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLikeComment];
        [queryExistingCommentLikes setCachePolicy:kPFCachePolicyNetworkOnly];
        [queryExistingCommentLikes includeKey:kPAPActivityFromUserKey];
        NSArray *activities = [queryExistingCommentLikes findObjects];
        
        if ([activities count] > 0) {
            
            // check if current user likes comment
            for (PFObject *obj in activities) {
                if([[[obj objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]){
                    [[PAPCache sharedCache] setCommentIsLikedByCurrentUser:comment liked:YES];
                }
            }
        }
        
        // add comment count to cache when count is at least one
        [[PAPCache sharedCache] setLikesForComment:comment count:(int)[activities count]];
    }
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
    [actionSheet showInView:self.view];
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
            [actionSheet showInView:self.view];
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


- (void)handleCommentTimeout:(NSTimer *)aTimer {
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Comment", nil) message:NSLocalizedString(@"Your comment will be posted next time there is an Internet connection.", nil)  delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil];
    [alert show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userLikedOrUnlikedPhoto:(NSNotification *)note {
    
    
    [self.headerView reloadLikeBar];
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

- (void)setTableViewHeight{
    
    /* Called in kb class on key pressed. Keep track of textview height so we change tableview content size accordingly - need to refactor */
    
    CGFloat msgTxtViewDiff = 0;
    
    if(!(self.previousKbHeight == 0)){
        msgTxtViewDiff = self.customKeyboard.messageTextView.frame.size.height - self.previousKbHeight;
    }
    
    [self.postDetails setContentSize:CGSizeMake(self.postDetails.frame.size.width, self.postDetails.contentSize.height + msgTxtViewDiff)];
    
    self.previousKbHeight = self.customKeyboard.messageTextView.frame.size.height;
}




@end
