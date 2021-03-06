//
//  ThoughtPostViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-05-22.
//
//

#import "ThoughtPostViewController.h"
#import "SVProgressHUD.h"
#import "PAPTabBarController.h"
#import "PAPHomeViewController.h"
#include <stdlib.h>
#import "AppDelegate.h"

@interface ThoughtPostViewController ()

@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, strong) NSMutableArray *bkgdOptions;
@property (nonatomic, strong) NSMutableArray *suggOptions;
@property (nonatomic, strong) UIBarButtonItem *rightNavButton;
@property (nonatomic, strong) NSString *placeholderSuggestion;
@property (nonatomic, strong) NSString *postType;
@property int prevBkgdIndex;
@property BOOL isSaveButtonShownOnStart;

@end

@implementation ThoughtPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.postType = @"thought";
    
    // set color of nav bar to custom grey
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(79/255.0) green:(91/255.0) blue:(100/255.0) alpha:(0.0/255.0)];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Update Thought";

    // set logo and nav bar buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    self.isSaveButtonShownOnStart = NO;
    self.rightNavButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit:)];
    self.rightNavButton.tintColor = [UIColor whiteColor];
    
    
    // personalize suggestion, check if name is not empty
    NSString *userName = ![[[PFUser currentUser] objectForKey:@"displayName"] isEqualToString:@" "] ? [[PFUser currentUser] objectForKey:@"displayName"] : @"You";
    
    // set suggestions
    NSString *sugg1 = [userName stringByAppendingString:@", you are freakin' awesome."];
    NSString *sugg2 = [userName stringByAppendingString:@" for president."];
    NSString *sugg3 = @"Always pass on what you have learned.";
    NSString *sugg4 = @"Do or do not. There is no try.";
    NSString *sugg5 = @"Zuck ain’t got nothing on you.";
    NSString *sugg6 = @"What you do in life, echoes in eternity.";
    NSString *sugg7 = @"How was your day?";
    NSString *sugg8 = @"What's new?";
    NSString *sugg9 = @"Share something with the community!";
    NSString *sugg10 = @"How's work?";
    NSString *sugg11 = @"What did you learn today?";
    NSString *sugg12 = @"What are you grateful for?";
    NSString *sugg13 = @"Run, Forest, run.";
    NSString *sugg14 = @"Only at the end do you realize the power of the Dark Side.";
    NSString *sugg15 = @"Keep calm and keep coding.";
    NSString *sugg16 = @"This is a bullshit free zone.";
    NSString *sugg17 = @"This is where you vent.";
    NSString *sugg18 = @"Ready. Set. Go!";
    NSString *sugg19 = @"[insert rant]";
    
    
    // suggestion selection
    self.suggOptions = [[NSMutableArray alloc]initWithObjects:sugg1, sugg2, sugg3, sugg4, sugg5, sugg6, sugg7, sugg8, sugg9, sugg10, sugg11, sugg12, sugg13, sugg14, sugg15, sugg16, sugg17, sugg18, sugg19, nil];
    
    // create and set background options
    [self setBackgroundOptions:[self createBackgroundOptions]];
    
    // random suggestion within selection bounds
    int randomSuggOption = [self generateRandomNumFromCount:self.suggOptions.count];
    int randomBkgdOption = [self generateRandomNumFromCount:self.bkgdOptions.count];
    
    [self setBkgIndex:randomBkgdOption];
    
    // used to keep track of current background color 
    self.prevBkgdIndex = randomBkgdOption;
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.leftSwipe addTarget:self action:@selector(leftNav:)];
    [self.rightSwipe addTarget:self action:@selector(rightNav:)];
    
    [self.thoughtTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.thoughtTextView setReturnKeyType:UIReturnKeyDone];
    
    // default placeholder suggestion
    [self.placeholder setText:[self.suggOptions objectAtIndex:randomSuggOption]];

    [self.view addGestureRecognizer:tapOutside];
}

- (int)generateRandomNumFromCount:(NSUInteger)count{
    int randomNum = arc4random_uniform((int)count);
    return randomNum;
}

- (void)setBkgIndex:(int)index{
    self.backgroundImg.backgroundColor = [self.bkgdOptions objectAtIndex:index];
}

- (void)setBackgroundOptions:(NSMutableArray *)bkgdOptions{
    self.bkgdOptions = bkgdOptions;
}

- (NSMutableArray *)createBackgroundOptions{
    
    // set colors
    UIColor *gray = [UIColor colorWithRed:42.0f/255.0f green:42.0f/255.0f blue:42.0f/255.0f alpha:1];
    UIColor *green = [UIColor colorWithRed:75.0f/255.0f green:82.0f/255.0f blue:95.0f/255.0f alpha:1];
    UIColor *teal = [UIColor colorWithRed:98.0f/255.0f green:195.0f/255.0f blue:112.0f/255.0f alpha:1];
    UIColor *orange = [UIColor colorWithRed:132.0f/255.0f green:198.0f/255.0f blue:201.0f/255.0f alpha:1];
    UIColor *redOrange = [UIColor colorWithRed:249.0f/255.0f green:175.0f/255.0f blue:54.0f/255.0f alpha:1];
    UIColor *purple = [UIColor colorWithRed:243.0f/255.0f green:137.0f/255.0f blue:100.0f/255.0f alpha:1];
    UIColor *pink = [UIColor colorWithRed:125.0f/255.0f green:112.0f/255.0f blue:186.0f/255.0f alpha:1];
    UIColor *blue = [UIColor colorWithRed:237.0f/255.0f green:86.0f/255.0f blue:118.0f/255.0f alpha:1];
    UIColor *olive = [UIColor colorWithRed:85.0f/255.0f green:67.0f/255.0f blue:72.0f/255.0f alpha:1];
    
    // color selection
    NSMutableArray *bckgdColorOptions = [[NSMutableArray alloc]initWithObjects:gray, green, teal, orange, redOrange, purple, pink, blue, olive, nil];
    
    return bckgdColorOptions;
}

-(void)viewWillAppear:(BOOL)animated{
    
    // google analytics
    [PAPUtility captureScreenGA:@"Thought Upload"];
    
    // new analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Thought"}];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"thought_screen" action:@"viewing_thought" label:@"" value:@""];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"Thought"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextViewDelegate & TextView related methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    // align cursor vertically
    [self verticalAlignTextview];
    
    if(!self.placeholder.hidden){
        self.placeholder.hidden = YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if(!self.isSaveButtonShownOnStart){
        [self showSaveButtonAfterEditingTextView:textView];
    }
    
    // align cursor vertically dynamically
    [self verticalAlignTextview];
}

- (void)showSaveButtonOnStart{
    self.navigationItem.rightBarButtonItem = self.rightNavButton;
    self.isSaveButtonShownOnStart = YES;
}


-(void)verticalAlignTextview{
    
    UITextView *tv = self.thoughtTextView;
    
    //Center vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - [tv sizeThatFits:tv.bounds.size].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : (topCorrect - 10.0f) );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)showSaveButtonAfterEditingTextView:(UITextView *)textView{
    self.navigationItem.rightBarButtonItem = [textView.text isEqualToString:@""] ? nil : self.rightNavButton;
}


#pragma mark - Saving Related Methods

- (void)trackAnalytics:(NSString *)type{
    
    NSString *postedAction = [type isEqualToString:@"thought"] ? @"Posted Thought" : @"Posted Project";
    NSString *eventTitle = [type isEqualToString:@"thought"] ? @"posted-thought" : @"posted-project";
    NSString *postCountTitle = [type isEqualToString:@"thought"] ? @"Thought Count" : @"Project Count";
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type": @"Core", @"Action": postedAction}];
    
    // intercom analytics
    [Intercom logEventWithName:eventTitle metaData:@{@"":@""}];
    
    // track selected color and current suggestion
    [[Mixpanel sharedInstance] track:@"Uploaded Color Index" properties:@{@"Type": [[NSNumber numberWithInt:self.prevBkgdIndex] stringValue]}];
    
    if([type isEqualToString:@"thought"]){
        [[Mixpanel sharedInstance] track:@"Uploaded Suggestion" properties:@{@"Type": self.placeholder.text}];
    }
    
    // increment user thought count by one
    [[Mixpanel sharedInstance].people increment:postCountTitle by:[NSNumber numberWithInt:1]];
    
}

- (BOOL)validateBeforeSaving{
    
    BOOL isValid = YES;
    
    // make sure our content is always smaller than the actual frame
    if(self.thoughtTextView.contentSize.height > self.thoughtTextView.frame.size.height){
        isValid = NO;
        [self showFailValidateBeforeSaveAlert];
    }
    
    return isValid;
}



- (UIImageView *)buildImageWithSubviews:(UIImageView *)backgroundView{
    [backgroundView addSubview:self.thoughtTextView];
    return backgroundView;
}

- (UIImage *)createImage:(UIImageView *)backgroundView{
    // create image
    UIGraphicsBeginImageContextWithOptions(backgroundView.bounds.size, NO, 0.0); //retina res
    [backgroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// overwritten by inerited objects
- (void)addExtraValueToPost:(PFObject *)post{}

- (PFObject *)createPostObj:(NSString *)type{
    // create a photo object
    PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
    [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
    [photo setObject:type forKey:kPAPPhotoType];
    [photo setObject:[NSNumber numberWithInt:0] forKey:@"discoverCount"];
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    [self addExtraValueToPost:photo];

    return photo;
}

- (void)savePostObj:(PFObject *)post{
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // save
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            NSLog(@"Photo uploaded");
            
            // create activity for posted
            [PAPUtility posted:post];
            
            // set cache
            [[PAPCache sharedCache] setAttributesForPhoto:post likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:post];
            
        } else {
            
            // error alert box
            NSLog(@"Post failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
}

- (void)shouldUploadImage:(UIImage *)anImage block:(void (^)(BOOL))completed
{
    
    UIImage *thumbnailImage = [PAPUtility resizeImage:anImage width:86.0f height:86.0f];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        completed(NO);
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
            completed(YES);
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            completed(NO);
        }
    }];
}


- (void)saveEdit:(id)sender {
    
    // increment activity point
    [[ActivityPointSystem sharedActivityPointSystem] addPointToActivityCount:@"post"];
    
    // track analytics
    [self trackAnalytics:self.postType];
    
    if([self validateBeforeSaving]){
        
        // disable save button so duplicates are not sent by mistake
        [self.rightNavButton setEnabled:NO];
    
        // dismiss keyboard before taking picture
        [self dismissKeyboard];
        
        // add label to background image for picture
        UIImage *renderedBkgdImg = [self createImage:[self buildImageWithSubviews:self.backgroundImg]];
        
        [SVProgressHUD show];
        
        // prepare image for upload
        [self shouldUploadImage:renderedBkgdImg block:^(BOOL completed) {
            
            if(completed){
                if (!self.photoFile || !self.thumbnailFile) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                    return;
                }
                
                // create, save post, and exit
                [self savePostObj:[self createPostObj:self.postType]];
                [self exitPost];
            }else{
                [SVProgressHUD dismiss];
                [self.rightNavButton setEnabled:YES];
            }
        }];
    }
}

- (void)showFailValidateBeforeSaveAlert{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:[NSString stringWithFormat:@"Your post is too long"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Navigation Related Methods

- (void)exitPost{
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] settingRootViewAsTabBarController];
}


- (void)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)rightNav:(id)sender{
    
    // update index, reset to first if reached end of array
    int currentBkgdIndex = self.prevBkgdIndex + 1;
    
    if(currentBkgdIndex < [self.bkgdOptions count]){
        [self setBkgIndex:currentBkgdIndex];
        self.prevBkgdIndex = currentBkgdIndex;
    }else{
        [self setBkgIndex:0];
        self.prevBkgdIndex = 0;
    }
}

- (IBAction)leftNav:(id)sender{
    
    // update index, set to last if reached end of array
    int currentBkgdIndex = self.prevBkgdIndex - 1;
    
    if(currentBkgdIndex > -1){
        [self setBkgIndex:currentBkgdIndex];
        self.prevBkgdIndex = currentBkgdIndex;
    }else{
        self.prevBkgdIndex = (int)[self.bkgdOptions count] - 1;
        [self setBkgIndex:self.prevBkgdIndex];
    }
}


@end