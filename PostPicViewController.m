//
//  PostPicViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-11-24.
//
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "PostPicViewController.h"
#import "PAPUtility.h"
#import "SVProgressHUD.h"
#import "PAPTabBarController.h"
#import "PAPHomeViewController.h"
#import "PAPAccountViewController.h"
#import "Mixpanel.h"
#import <FlightRecorder/FlightRecorder.h>
#import "AtMention.h"
#import "AppDelegate.h"

@interface PostPicViewController ()

// ui variables
@property (nonatomic, strong) UIScrollView *cropScrollView;
@property (nonatomic, strong) UIImageView *cropImgView;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIImage *originalImg;
@property (nonatomic, strong) UIImage *croppedImg;
@property (nonatomic, strong) UIBarButtonItem *rightNavButton;
@property (nonatomic, strong) NSString *placeholderText;
@property (nonatomic, strong) UIColor *placeholderTextColor;
//@property (nonatomic, strong) NSMutableArray *userArray;
//@property (nonatomic, strong) NSString *atmentionSearchString;
//@property (nonatomic, strong) UITableView *autocompleteTableView;
//@property (nonatomic, strong) NSArray *filteredArray;
//@property (nonatomic, strong) NSString *cellType;
//@property (nonatomic, strong) PFQuery *userQuery;
//@property (nonatomic, strong) NSMutableArray *atmentionUserArray;
//@property (nonatomic, strong) UIView *dimView;
//@property NSInteger text_location;
//@property NSInteger atmentionLength;
//@property NSRange atmentionRange;


// upload variables
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSString *source;

@end

@implementation PostPicViewController

- (id)initWithImage:(UIImage *)originalImg source:(NSString *)source
{
    self = [super init];
    if (self) {
        
        if (!originalImg) {
            return nil;
        }

        self.source = source;
        self.originalImg = originalImg;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
        self.placeholderText = @"Add a description to your moment...";
        self.placeholderTextColor = [UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    
    // google analytics
    [PAPUtility captureScreenGA:@"Post Pic Upload"];

    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Post Photo"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"post_photo_screen" action:@"viewing_post_photo" label:@"" value:@""];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"Post Photo"];
    
    // change proportions based on iphone height
    float cropScrollHeight;
    float descriptionTextViewHeight;
    
     if ([UIScreen mainScreen].bounds.size.height > 480) {
         cropScrollHeight = 320;
         descriptionTextViewHeight = 180;
     }else{
         cropScrollHeight = 290;
         descriptionTextViewHeight = 120;
     }
    
    // set view's background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // scrollview set up
    self.cropScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, cropScrollHeight)];
    [self.cropScrollView setDelegate:self];
    [self.cropScrollView setBackgroundColor:[UIColor blackColor]];
    [self.cropScrollView setShowsHorizontalScrollIndicator:NO];
    [self.cropScrollView setShowsVerticalScrollIndicator:NO];
    [self.cropScrollView setMaximumZoomScale:2.0];
    
    // image view set up
    self.cropImgView = [[UIImageView alloc] initWithImage:self.originalImg];
    [self.cropImgView setBackgroundColor:[UIColor redColor]];
    [self.cropImgView setFrame:CGRectMake(0.0, 0.0, self.originalImg.size.width, self.originalImg.size.height)];
    [self.cropScrollView setContentSize:self.originalImg.size];
    
    // calculate minimum zoom for selected image
    CGRect scrollViewFrame = self.cropScrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.cropScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.cropScrollView.contentSize.height;
    CGFloat minScale = MAX(scaleWidth,scaleHeight);
    
    // set imageview and add to scrollview
    [self.cropScrollView setMinimumZoomScale:minScale];
    [self.cropScrollView setZoomScale:minScale];
    [self.cropScrollView addSubview:self.cropImgView];
    
    // center image by manipulting scrollview's offset
    CGFloat newContentOffsetX = (self.cropScrollView.contentSize.width/2) - (self.cropScrollView.bounds.size.width/2);
    [self.cropScrollView setContentOffset:CGPointMake(newContentOffsetX, 0)];
    
    [self.view addSubview:self.cropScrollView];
    
    // create text view placed below crop area
    self.descriptionTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, self.cropScrollView.frame.origin.y + self.cropScrollView.frame.size.height + 8, [UIScreen mainScreen].bounds.size.width - 20, descriptionTextViewHeight)];
    [self.descriptionTextView setDelegate:self];
    [self.descriptionTextView setText:self.placeholderText];
    [self.descriptionTextView setFont:[UIFont systemFontOfSize:15.0f]];
    [self.descriptionTextView setTextColor:self.placeholderTextColor];
    [self.view addSubview:self.descriptionTextView];
    
    /*
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
     */

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:NO];
    self.firstPicViewController = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // set color of nav bar to custom grey
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(79/255.0) green:(91/255.0) blue:(100/255.0) alpha:(0.0/255.0)];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Update Moment";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
        
    self.rightNavButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(cropPressed)];
    self.rightNavButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.rightNavButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];

}

#pragma mark - Crop Methods

- (UIImage *)cropImage{
    float zoomScale = 1.0 / [self.cropScrollView zoomScale];
    
    CGRect rect;
    rect.origin.x = [self.cropScrollView contentOffset].x * zoomScale;
    rect.origin.y = [self.cropScrollView contentOffset].y * zoomScale;
    rect.size.width = [self.cropScrollView bounds].size.width * zoomScale;
    rect.size.height = [self.cropScrollView bounds].size.height * zoomScale;
    
    CGImageRef cr = CGImageCreateWithImageInRect([[self.cropImgView image] CGImage], rect);
    
    UIImage *cropped = [UIImage imageWithCGImage:cr];
    
    CGImageRelease(cr);
    
    // check if crop has been used
    if(self.cropScrollView.contentOffset.y > 0){
        // Mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Used photo crop" properties:@{}];
    }
    
    return cropped;
}

- (UIImage *)processImage{
    
    // Cropping & resizing picture
    UIImage *resizedCroppedPic = [PAPUtility resizeImage:[self cropImage] width:640 height:640];
    
    return resizedCroppedPic;
}

- (void)cropPressed {
    
    // increment activity point
    [[AtMention sharedAtMention] addPointToActivityCount];
    
    // show spinning indicator
    [SVProgressHUD show];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type": @"Core", @"Action": @"Posted Moment"}];
    
    // intercom analytics
    [Intercom logEventWithName:@"posted-moment" metaData:nil];

    
    // increment user photo count by one
    [[Mixpanel sharedInstance].people increment:@"Photo Count" by:[NSNumber numberWithInt:1]];
    
    //resize cropped image (work on background thread)
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // crop and resize image from scroll view
        self.croppedImg = [self processImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // save image to teamstory folder    
            [self saveImageToCustomFolder:self.croppedImg];
        
            // upload pic to server
            [self startUploadProcess:self.croppedImg];
        });
    });
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.cropImgView;
}

#pragma mark - Upload Methods

- (void)saveImageToCustomFolder:(UIImage *)anImage{
    
    // Save image to custom photo album
    void (^failure)(NSError *) = ^(NSError *error) {
        if (error == nil) return;
        
        NSLog(@"Photo failed to save in album: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't save photo in album :( Check your internet connection or contact us at info@teamstoryapp.com" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        
    };
    
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [self.assetsLibrary saveImage:anImage
                          toAlbum:@"Teamstory"
                       completion:nil
                          failure:failure];
}

- (void)startUploadProcess:(UIImage *)anImage {
    
    UIImage *thumbnailImage = [PAPUtility resizeImage:anImage width:86.0f height:86.0f];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return;
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
                    
                    [self uploadFinishedImage:anImage];
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
}

- (void)uploadFinishedImage:(UIImage *)anImage {
    
    // prepare comment for saving
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
    
    // set comment to photo
    if (userInfo) {
        NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
        if (commentText && commentText.length != 0 && ![commentText isEqualToString:self.placeholderText]) {
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
    
    // upload to server
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded");
            
            // create activity for posted
            [PAPUtility posted:photo];
            
            [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
        } else {
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo :( Check your internet connection or contact us at info@teamstoryapp.com" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        
        [SVProgressHUD dismiss];
        [self exitPhoto];
    }];
}

#pragma mark - Nav Methods

-(void)dismissKeyboard {
    [self.view endEditing:YES];
 //   self.autocompleteTableView.hidden = YES;
  //  self.dimView.hidden = YES;
}

- (void)backButtonAction{
    if (self.firstPicViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)exitPhoto{
    [self.view endEditing:YES];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([[textView text] isEqualToString:self.placeholderText]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text length] == 0) {
        [textView setText:self.placeholderText];
        [textView setTextColor:self.placeholderTextColor];
    }
}

#pragma mark - UIKeyboard

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve) {
    return (UIViewAnimationOptions)curve << 16;
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSNumber *number = [[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationCurve animationCurve = [[[note userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    float keyboardDuration = [number doubleValue];

    
    CGFloat offset = keyboardFrameEnd.size.height;
    
    // Check system version for keyboard offset, ios8 added suggestion bar
    // Align the bottom edge of the photo with the keyboardr
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        offset += 20;
    }
    

    // ---------- Animation in sync with keyboard moving up
    [UIView animateWithDuration:keyboardDuration delay:0 options:animationOptionsWithCurve(animationCurve) animations:^{
        [self.view setBounds:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + offset, self.view.bounds.size.width,self.view.bounds.size.height)];
        
    } completion:^(BOOL finished) {
    }];

}

- (void)keyboardWillHide:(NSNotification *)note {
    
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat offset = keyboardFrameEnd.size.height;
    NSNumber *number = [[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationCurve animationCurve = [[[note userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    float keyboardDuration = [number doubleValue];

    // Check system version for keyboard offset, ios8 added suggestion bar
    // Align the bottom edge of the photo with the keyboardr
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        offset += 20;
    }
    
    // ---------- Animation in sync with keyboard moving up
    [UIView animateWithDuration:keyboardDuration delay:0 options:animationOptionsWithCurve(animationCurve) animations:^{
        [self.view setBounds:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y - offset, self.view.bounds.size.width,self.view.bounds.size.height)];
    
    } completion:^(BOOL finished) {
    }];
    
}

#pragma mark - Mention Method

/*

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

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithNibName:@"PhotoTimelineViewController" bundle:nil];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser cellType:(NSString *)acellType{
   
    self.cellType = acellType;
    self.text_location = 0;
    
    if (self.atmentionRange.location != NSNotFound) {
        [self textView:self.descriptionTextView shouldChangeTextInRange:self.atmentionRange replacementText:[aUser objectForKey:@"displayName"]];
    }
    
    self.autocompleteTableView.hidden = YES;
    self.dimView.hidden = YES;
  
    [self.atmentionUserArray addObject:aUser];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([self.cellType isEqualToString:@"atmentionCell"]) {
        text = [text stringByAppendingString:@" "];
        
        if (range.location != NSNotFound) {
            
            
             If the user presses the Delete key, the length of the range is 1 and an empty string object replaces that single character. Goes out of bounds when user presses delete and selects display name at the start of message.
            
            long replacementRange = range.length + 1;
            
            // Check if new range is in bounds of current text, accounting for extra key when deleting
            if(replacementRange < self.descriptionTextView.text.length){
                self.descriptionTextView.text = [self.descriptionTextView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, replacementRange) withString:text];
            }else{
                self.descriptionTextView.text = [self.descriptionTextView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
            }
        }
        
        self.cellType = nil;
        return YES;
    }
    
    if ([text isEqualToString:@"@"]){
        [SVProgressHUD show];
        
        
        CGPoint cursorPosition = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
        
        float offsetEmptyTextViewToKb = self.descriptionTextView.frame.size.height - cursorPosition.y;
        
        [self.view setBounds:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y - offsetEmptyTextViewToKb, self.view.bounds.size.width,self.view.bounds.size.height)];
        
        
        NSLog(@"offsetToKb %f", offsetEmptyTextViewToKb);
        
        if ([self.userArray count] < 1) {
            self.userQuery = [PFUser query];
            self.userQuery.limit = MAXFLOAT;
            [self.userQuery whereKeyExists:@"displayName"];
            [self.userQuery orderByAscending:@"displayName"];
            [self.userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
        
    }
    
    if ([self.userArray count] > 0) {
        NSMutableString *updatedText = [[NSMutableString alloc] initWithString:self.descriptionTextView.text];
        if (range.location == 0 || range.location == self.text_location) {
            self.autocompleteTableView.hidden = YES;
            self.dimView.hidden = YES;
            self.text_location = 0;
        } else if (range.location > 0 && [[updatedText substringWithRange:NSMakeRange(range.location - 1, 1)] isEqualToString:@"@"]) {
            self.text_location = range.location;
        }
        
        if ([text isEqualToString:@""] && self.text_location > 1) {
            range.location -=1;
            
            if (self.text_location > range.location) {
                self.text_location -= 1;
            }
        }
        
        if (self.text_location > 0) {
            if (range.location == NSNotFound) {
                NSLog(@"range location not found");
            } else {
                self.atmentionRange = NSMakeRange(self.text_location, range.location - self.text_location);
                self.atmentionSearchString = [updatedText substringWithRange:self.atmentionRange];
                self.atmentionSearchString = [self.atmentionSearchString stringByAppendingString:text];
            }
            
            self.filteredArray = [self.userArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", self.atmentionSearchString]];
            
            // Check system version for keyboard offset, ios8 added suggestion bar
            // Align the mention table view
            self.dimView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 9999.0f);
            
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
                self.autocompleteTableView.frame = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.frame.size.height - self.descriptionTextView.frame.size.height - 273);
            }else{
                self.autocompleteTableView.frame = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.frame.size.height - self.descriptionTextView.frame.size.height - 273 + 37);
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
