//
//  PAPEditPhotoViewController.m
//  Teamstory
//
//

#import "PAPEditPhotoViewController.h"

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PAPPhotoDetailsFooterView.h"
#import "PAPTabBarController.h"
#import "PAPHomeViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPBaseTextCell.h"
#import "SVProgressHUD.h"
#import "PAPLoadMoreCell.h"
#import "PAPConstants.h"
#import "Mixpanel.h"


@interface PAPEditPhotoViewController () {
    NSInteger text_location;
    NSRange atmentionRange;
    NSInteger text_offset;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UITextView *commentTextView;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property CGRect previousRect;
@property (nonatomic, strong) PAPPhotoDetailsFooterView *footerView;
@property (nonatomic, strong) NSString *cellType;
@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, strong) NSMutableArray *atmentionUserArray;
@property (nonatomic, strong) NSArray *filteredArray;
@property (nonatomic, strong) PFQuery *userQuery;
@property (nonatomic, strong) UITableView *autocompleteTableView;
@property (nonatomic, strong) NSString *atmentionSearchString;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIBarButtonItem *doneBtn;


@property CGRect defaultFooterViewFrame;

@end

@implementation PAPEditPhotoViewController
@synthesize cellType;
@synthesize userArray;
@synthesize userQuery;
@synthesize atmentionUserArray;
@synthesize filteredArray;
@synthesize autocompleteTableView;
@synthesize atmentionSearchString;
@synthesize dimView;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"Memory warning on Edit");
}


#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    self.view = self.scrollView;
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f)];
    [photoImageView setBackgroundColor:[UIColor blackColor]];
    [photoImageView setImage:self.image];
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];

    CALayer *layer = photoImageView.layer;
    layer.masksToBounds = NO;
    layer.shadowRadius = 3.0f;
    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    layer.shadowOpacity = 0.5f;

    
    [self.scrollView addSubview:photoImageView];
    
    CGRect footerRect = [PAPPhotoDetailsFooterView rectForView];
    footerRect.origin.y = photoImageView.frame.origin.y + photoImageView.frame.size.height;
    
    self.dimView = [[UIView alloc] init];
    self.dimView.hidden = YES;
    self.dimView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];
    [self.view addSubview:self.dimView];
    
    self.footerView = [[PAPPhotoDetailsFooterView alloc] initWithFrame:footerRect];
    self.defaultFooterViewFrame = self.footerView.mainView.frame;
    self.commentTextView = self.footerView.commentView;
    self.commentTextView.text = @"Add a caption";
    self.commentTextView.delegate = self;
    [self.commentTextView setAutocorrectionType:UITextAutocorrectionTypeDefault];
    
    [self.scrollView addSubview:self.footerView];
    

    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y + photoImageView.frame.size.height + self.footerView.frame.size.height)];
    
    self.scrollView.scrollEnabled = YES;
    
    
  }

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(exitPhoto)];
    
    
    self.doneBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    self.navigationItem.rightBarButtonItem = self.doneBtn;

    
    self.autocompleteTableView = [[UITableView alloc] init];
    self.autocompleteTableView.delegate = self;
    //self.autocompleteTableView.separatorInset = UIEdgeInsetsZero;
    self.autocompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:autocompleteTableView];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self shouldUploadImage:self.image];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
    self.autocompleteTableView.hidden = YES;
    self.dimView.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    // analytics
    [PAPUtility captureScreenGA:@"Edit Photo"];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Edit Photo"}];

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doneButtonAction:textField];
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - ()

- (void)exitPhoto{
    
    // set color of nav bar back to teal
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    
    // hide custom grey bar and pop to home
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // get tab bar and home controller from stack
    PAPTabBarController *tabBarController =[[self.navigationController viewControllers] objectAtIndex:1];
    NSArray *tabBarViewControllers = [tabBarController viewControllers];
    
    // get home and phototimeline, if there are children pop 'em to get back to timeline
    PAPHomeViewController *homeViewController = [tabBarViewControllers objectAtIndex:0];
    PhotoTimelineViewController *photoViewController = [homeViewController.childViewControllers objectAtIndex:0];
    
    if([homeViewController.childViewControllers count] > 1){
        [photoViewController.navigationController popViewControllerAnimated:NO];
    }
    
    [tabBarController setSelectedViewController:homeViewController];
    
    NSArray *m = homeViewController.childViewControllers;
    
    [m objectAtIndex:0];
    // push tab bar with home controller now selected
    [self.navigationController popToViewController:tabBarController animated:YES];
}


- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %d for Teamstory photo upload", (int)self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Thumbnail uploaded successfully");
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}



#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredArray count];
}

#pragma mark - Custom TextView

- (void)updateTextView:(float)newHeight{
    
    // expands textview based on content
    self.footerView.mainView.frame = CGRectMake(self.footerView.mainView.frame.origin.x, self.footerView.mainView.frame.origin.y, self.footerView.mainView.frame.size.width, newHeight + 20);
    
    // expands footer frame that contains textview
    self.footerView.frame =  CGRectMake(self.footerView.frame.origin.x, self.footerView.frame.origin.y, self.footerView.frame.size.width, newHeight + 20);
}

- (float)getCurrentScrollViewContentHeightWithTextView{
    
    // set offset for  based on current table height
    float currentTextViewContentHeight = self.footerView.mainView.frame.size.height - self.defaultFooterViewFrame.size.height;
    
    float newScrollViewContentHeight = self.scrollView.contentSize.height + currentTextViewContentHeight;
    
    return currentTextViewContentHeight != 0 ? newScrollViewContentHeight : self.scrollView.contentSize.height;
}


- (float)getCurrentTextViewHeight{
    
    float currentTextViewHeight = (self.footerView.mainView.frame.size.height - self.defaultFooterViewFrame.size.height) == 0 ? self.defaultFooterViewFrame.size.height : self.footerView.mainView.frame.size.height - self.defaultFooterViewFrame.size.height;
    
    return currentTextViewHeight;
}

#pragma mark - UIKeyboard 

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float scrollViewContentSize = [self getCurrentScrollViewContentHeightWithTextView];
    scrollViewContentSize += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, scrollViewContentSize)];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    
    // Check system version for keyboard offset, ios8 added suggestion bar
    // Align the bottom edge of the photo with the keyboardr
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height;
    }else{
        // Align the bottom edge of the photo with the keyboard
        scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height + [self getCurrentTextViewHeight] + 30;
    }
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        
        [self.scrollView setContentSize:scrollViewContentSize];
        
        // set new content size for scrollview, update with current textview height
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, [self getCurrentScrollViewContentHeightWithTextView] + scrollViewContentSize.height)];
    }];
}

# pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    CGSize scrollViewContentSize = self.scrollView.bounds.size;

    // update content size - especially important when dragging while editing
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, [self getCurrentScrollViewContentHeightWithTextView] + scrollViewContentSize.height)];
    
    if ([[textView text] isEqualToString:@"Add a caption"]) {
        [textView setText:@""];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text length] == 0) {
        [textView setText:@"Add a caption"];
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    
    // get current frame position of text with proper height
    UITextPosition* pos = textView.endOfDocument;
    CGRect currentRect = [textView caretRectForPosition:pos];
    
    CGRect frame = textView.frame;
    frame.size.height = [textView contentSize].height;
    textView.frame = frame;
    if (text_offset == NSNotFound) {
        text_offset = 0;
    }
    
    // for next line excl. first line
    if (currentRect.origin.y > self.previousRect.origin.y && self.previousRect.origin.y != 0){
        text_offset += 15.0f;
        
        // expands textview based on content
        [self updateTextView:frame.size.height];
        
        // moves keyboard to proper height
        [self.scrollView setContentOffset:CGPointMake(0.0f, self.scrollView.contentOffset.y + 15) animated:YES];
    
    // for prev line excl. first line
    }else if (currentRect.origin.y < self.previousRect.origin.y && self.previousRect.origin.y != 0){
        text_offset -= 15.0f;
        
        // expands textview based on content
        [self updateTextView:frame.size.height];
        
        // moves keyboard to proper height
        [self.scrollView setContentOffset:CGPointMake(0.0f, self.scrollView.contentOffset.y  - 15) animated:YES];
    }
    
    self.previousRect = currentRect;
}


- (BOOL) textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text{
    if ([cellType isEqualToString:@"atmentionCell"]) {
        text = [text stringByAppendingString:@" "];
        
        if (range.location != NSNotFound) {
            textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length + 1) withString:text];
        }
        
        cellType = nil;
        return YES;
    }
    
    if ([text isEqualToString:@"@"]){
        [SVProgressHUD show];
        
        if ([self.userArray count] < 1) {
            userQuery = [PFUser query];
            userQuery.limit = 100000;
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
    
    }else if ([text isEqualToString:@"\n"]) {
        
        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (trimmedComment.length != 0) {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        trimmedComment,kPAPEditPhotoViewControllerUserInfoCommentKey,
                        nil];
        }
        
        if (!self.photoFile || !self.thumbnailFile) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            return NO;
        }
        
        // both files have finished uploading
        
        // create a photo object
        PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
        [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
        [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
        [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
        [photo setObject:@"picture" forKey:kPAPPhotoType];
        [photo setObject:[NSNumber numberWithInt:0] forKey:@"discoverCount"];
        
        // storing atmention user list to the array (only filtered cases).
        if ([self.atmentionUserArray count] > 0) {
            NSArray *mod_atmentionUserArray = [self.atmentionUserArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName IN %@", self.commentTextView.text]];
            [photo setObject:mod_atmentionUserArray forKey:@"atmention"];
        }
        
        
        if (userInfo) {
            NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
            
            if (commentText && commentText.length != 0 && ![commentText isEqualToString:@"Add a caption"]) {
                [photo setObject:commentText forKey:@"caption"];
            }
        }
        
        // photos are public, but may only be modified by the user who uploaded them
        PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [photoACL setPublicReadAccess:YES];
        photo.ACL = photoACL;
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
        

        
        // save
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Photo uploaded");
                
                [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
            } else {
                NSLog(@"Photo failed to save: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
        
        [self exitPhoto];
    }
    
    if ([self.userArray count] > 0) {
        NSMutableString *updatedText = [[NSMutableString alloc] initWithString:textView.text];
        if (range.location == 0 || range.location == text_location) {
            self.autocompleteTableView.hidden = YES;
            self.dimView.hidden = YES;
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
            };

            self.filteredArray = [self.userArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", atmentionSearchString]];
            
            // frames should be handled differently for iphone 4 and 5.
            if ([UIScreen mainScreen].bounds.size.height == 480) {
                self.dimView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 9999.0f);
                self.autocompleteTableView.frame = CGRectMake(7.5f, 203.0f + text_offset, 305.0f, 145.0f - text_offset);
            } else {
                self.dimView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 9999.0f);
                self.autocompleteTableView.frame = CGRectMake(7.5f, 115.0f + text_offset, 305.0f, 232.0f - text_offset);
            }
            
            if ([self.filteredArray count] < 1) {
                self.dimView.hidden = YES;
            } else {
                self.dimView.hidden = NO;
            }
            
            self.autocompleteTableView.hidden = NO;
            [self.autocompleteTableView reloadData];
        }
    }
    return YES;
}

#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser cellType:(NSString *)acellType{
    if ([acellType isEqualToString:@"atmentionCell"]) {
        cellType = acellType;
        text_location = 0;
        
        if (atmentionRange.location != NSNotFound) {
            [self textView:self.commentTextView shouldChangeTextInRange:atmentionRange replacementText:[aUser objectForKey:@"displayName"]];
        }
        
        self.autocompleteTableView.hidden = YES;
        self.dimView.hidden = YES;
        [self.atmentionUserArray addObject:aUser];
    }
}

- (void)doneButtonAction:(id)sender {
    
    // disable done bar button while pic is uploading
    [self.doneBtn setEnabled:NO];
    
    // show hud while saving pic in background
    [SVProgressHUD show];
    
    // analytics
    [PAPUtility captureEventGA:@"Engagement" action:@"Upload Picture" label:@"Photo"];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type": @"Core", @"Action": @"Posted Moment"}];
    
    // fb analytics
    [FBAppEvents logEvent:FBAppEventNameViewedContent
               valueToSum:1
               parameters:@{ FBAppEventParameterNameContentType : @"Uploaded Photo"}];

    
    // increment user photo count by one
    [[Mixpanel sharedInstance].people increment:@"Photo Count" by:[NSNumber numberWithInt:1]];
    
    
    
    // make sure placeholder gets erased
    if([[self.commentTextView text] isEqualToString:@"Add a caption"]){
        [self.commentTextView setText:@""];
    }
    
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  trimmedComment,kPAPEditPhotoViewControllerUserInfoCommentKey,
                                  nil];
    }
    
    if (!self.photoFile || !self.thumbnailFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    // both files have finished uploading
    
    // create a photo object
    PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
    [photo setObject:@"picture" forKey:kPAPPhotoType];
    [photo setObject:[NSNumber numberWithInt:0] forKey:@"discoverCount"];
    
    // storing atmention user list to the array (only filtered cases).
    if ([self.atmentionUserArray count] > 0) {
        NSArray *mod_atmentionUserArray = [self.atmentionUserArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName IN %@", self.commentTextView.text]];
        [photo setObject:mod_atmentionUserArray forKey:@"atmention"];
    }
    
    if (userInfo) {
        NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
        
        if (commentText && commentText.length != 0 && ![commentText isEqualToString:@"Add a caption"]) {
            [photo setObject:commentText forKey:@"caption"];
        }
    }
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // The completion block to be executed after image taking action process done
    void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
        
        [SVProgressHUD dismiss];
        [self exitPhoto];
    };
    
    void (^failure)(NSError *) = ^(NSError *error) {
        if (error == nil) return;
    
        [SVProgressHUD dismiss];
        
        
        NSLog(@"Photo failed to post: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo :( Check your internet connection or contact us at info@teamstoryapp.com" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        
        
        [self exitPhoto];
    };
    
    // save
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded");
            
            [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
            
            // Save image to custom photo album
            // The lifetimes of objects you get back from a library instance are tied to
            //   the lifetime of the library instance.
            
            self.assetsLibrary = [[ALAssetsLibrary alloc] init];
            
            [self.assetsLibrary saveImage:self.image
                                  toAlbum:@"Teamstory"
                               completion:completion
                                  failure:failure];
            
        } else {
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo :( Check your internet connection or contact us at info@teamstoryapp.com" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    

}




@end
