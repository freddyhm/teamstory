//
//  ThoughtPostViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-05-22.
//
//

#import "ThoughtPostViewController.h"
#import "SVProgressHUD.h"
#import "CameraFilterViewController.h"
#import "PAPEditPhotoViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPTabBarController.h"
#import "PAPHomeViewController.h"

@interface ThoughtPostViewController ()

@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, strong) NSMutableArray *bkgdOptions;
@property int prevBkgdIndex;

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
    
    // init nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // set logo and nav bar buttons
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit:)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    // set colors
    UIColor *original = [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1];
    UIColor *green = [UIColor colorWithRed:156.0f/255.0f green:209.0f/255.0f blue:105.0f/255.0f alpha:1];
    UIColor *blue = [UIColor colorWithRed:19.0f/255.0f green:149.0f/255.0f blue:217.0f/255.0f alpha:1];
    UIColor *deepPurple = [UIColor colorWithRed:166.0f/255.0f green:109.0f/255.0f blue:170.0f/255.0f alpha:1];
    UIColor *pink = [UIColor colorWithRed:234.0f/255.0f green:108.0f/255.0f blue:135.0f/255.0f alpha:1];
    UIColor *pinkRed = [UIColor colorWithRed:253.0f/255.0f green:89.0f/255.0f blue:89.0f/255.0f alpha:1];
    UIColor *yellow = [UIColor colorWithRed:236.0f/255.0f green:198.0f/255.0f blue:84.0f/255.0f alpha:1];
    UIColor *orange = [UIColor colorWithRed:249.0f/255.0f green:155.0f/255.0f blue:72.0f/255.0f alpha:1];
    UIColor *blueGrey = [UIColor colorWithRed:89.0f/255.0f green:94.0f/255.0f blue:100.0f/255.0f alpha:1];
    UIColor *darkGrey = [UIColor colorWithRed:41.0f/255.0f green:41.0f/255.0f blue:41.0f/255.0f alpha:1];
    
    // color selection
    self.bkgdOptions = [[NSMutableArray alloc]initWithObjects:original, green, blue, deepPurple, pink, pinkRed, yellow, orange, blueGrey, darkGrey, nil];
    self.backgroundImg.backgroundColor = [self.bkgdOptions objectAtIndex:0];
    self.prevBkgdIndex = 0;
    
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapOutside];
    
    [self.thoughtTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
}

-(void)viewWillAppear:(BOOL)animated{
    
    // analytics
    [PAPUtility captureScreenGA:@"Thought Post"];
    
    // set color of nav bar to teal
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if(!self.placeholder.hidden){
        self.placeholder.hidden = YES;
    }
    
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    //Center vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
    /*
    //Bottom vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height);
    topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
     */
}

#pragma mark - ()

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)updateTextColor{
    
    // check if current bkgd is white or not
    self.thoughtTextView.textColor = self.prevBkgdIndex == 0 ? [UIColor blackColor]:[UIColor whiteColor];
}

- (IBAction)rightNav:(id)sender{
    
    // update index, reset to first if reached end of array
    int currentBkgdIndex = self.prevBkgdIndex + 1;
    
    if(currentBkgdIndex < [self.bkgdOptions count]){
        self.backgroundImg.backgroundColor = [self.bkgdOptions objectAtIndex:currentBkgdIndex];
        self.prevBkgdIndex = currentBkgdIndex;
    }else{
        self.backgroundImg.backgroundColor = [self.bkgdOptions objectAtIndex:0];
        self.prevBkgdIndex = 0;
    }
    
    // change present text color
    [self updateTextColor];
}

- (IBAction)leftNav:(id)sender{
    
    // update index, set to last if reached end of array
    int currentBkgdIndex = self.prevBkgdIndex - 1;
    
    if(currentBkgdIndex > -1){
        self.backgroundImg.backgroundColor = [self.bkgdOptions objectAtIndex:currentBkgdIndex];
        self.prevBkgdIndex = currentBkgdIndex;
    }else{
        self.prevBkgdIndex = [self.bkgdOptions count] - 1;
        self.backgroundImg.backgroundColor = [self.bkgdOptions objectAtIndex:self.prevBkgdIndex];
    }
    
    // change present text color
    [self updateTextColor];
}

- (void)saveEdit:(id)sender {
    
    
    // analytics for upload and background
    [PAPUtility captureEventGA:@"Engagement" action:@"Upload Thought" label:@"Photo"];
    [PAPUtility captureEventGA:@"Thought Bkgd" action:[[NSNumber numberWithInt:self.prevBkgdIndex] stringValue] label:@"Photo"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.thoughtTextView.frame];
    label.text = self.thoughtTextView.text;
    label.font = self.thoughtTextView.font;
    label.textColor = self.thoughtTextView.textColor;
    label.textAlignment = self.thoughtTextView.textAlignment;
    label.numberOfLines = 0;
    [label sizeToFit];
    
    [self.backgroundImg addSubview:label];
    
    UIGraphicsBeginImageContextWithOptions(self.backgroundImg.bounds.size, NO, 0.0); //retina res
    [self.backgroundImg.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [label removeFromSuperview];
    
   
    [SVProgressHUD show];
    
    [self shouldUploadImage:image block:^(BOOL completed) {
        
        if(completed){
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
            [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
            [photo setObject:@"thought" forKey:kPAPPhotoType];
            
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
            
            [self exitPost];
        }else{
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)shouldUploadImage:(UIImage *)anImage block:(void (^)(BOOL))completed
{
    
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(anImage, 0.8f);
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

- (void)exitPost{
    
    // hide custom grey bar and pop to home
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // get tab bar and home controller from stack
    PAPTabBarController *tabBarController =[[self.navigationController viewControllers] objectAtIndex:1];
    NSArray *tabBarViewControllers = [tabBarController viewControllers];
    
    // get home and phototimeline, if there are children pop 'em to get back to timeline
    PAPHomeViewController *homeViewController = [tabBarViewControllers objectAtIndex:0];
    PAPPhotoTimelineViewController *photoViewController = [homeViewController.childViewControllers objectAtIndex:0];
    
    if([homeViewController.childViewControllers count] > 1){
        [photoViewController.navigationController popViewControllerAnimated:NO];
    }
    
    [tabBarController setSelectedViewController:homeViewController];
    
    NSArray *m = homeViewController.childViewControllers;
    
    [m objectAtIndex:0];
    
    // push tab bar with home controller now selected
    [self.navigationController popToViewController:tabBarController animated:YES];
}


- (void)backButtonAction:(id)sender {
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end