//
//  PAPlinkPostViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-06-25.
//
//

#import "PAPlinkPostViewController.h"
#import "Embedly.h"
#import "SVProgressHUD.h"
#import "PAPTabBarController.h"
#import "PAPHomeViewController.h"
#import "Mixpanel.h"
#import "FlightRecorder.h"
#import "Intercom.h"
#import "ParseFacebookUtils/PFFacebookUtils.h"
#import "UIImageEffects.h"


@interface PAPlinkPostViewController ()

@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIView *popUpBox;
@property (nonatomic, strong) UITextField *url_textField;
@property (nonatomic, strong) UIButton *okayButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *popUpBoxurlLabel;
@property (nonatomic, strong) PFImageView *imageView;
@property (nonatomic, strong) UITextView *commentTextView;
@property (nonatomic, strong) UIView *linkPostView;
@property (nonatomic, strong) UILabel *linkPostViewLabel_title;
@property (nonatomic, strong) NSString *linkPostDescription;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *urlLabel;

@end

@implementation PAPlinkPostViewController

@synthesize dimView;
@synthesize popUpBox;
@synthesize url_textField;
@synthesize okayButton;
@synthesize nextButton;
@synthesize titleLabel;
@synthesize popUpBoxurlLabel;
@synthesize imageView;
@synthesize commentTextView;
@synthesize linkPostView;
@synthesize linkPostViewLabel_title;
@synthesize urlString;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;
@synthesize linkPostDescription;
@synthesize placeholderLabel;
@synthesize urlLabel;

static NSString *const EMBEDLY_APP_ID = @"5cf1f13ea680488fb54b346ffef85f93";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Link"}];
    
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"Link"];
    
    // init nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    UIImage *navNext = [UIImage imageNamed:@"button_done.png"];
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setImage:navNext forState:UIControlStateNormal];
    [postButton setFrame:CGRectMake(0.0f, 0.0f, navNext.size.width, navNext.size.height)];
    [postButton addTarget:self action:@selector(postButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postButton];
    
    
    // set logo and nav bar buttons
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
    
    
    // populating dim View (background).
    self.dimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.dimView setBackgroundColor:[UIColor colorWithWhite:0.5f alpha:0.8f]];
    [self.dimView setTag:111];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.dimView];
    
    float popUpBoxOffset;
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        popUpBoxOffset = 30.0f;
    } else {
        popUpBoxOffset = 75.0f;
    }
    
    self.popUpBox = [[UIView alloc] initWithFrame:CGRectMake(20.0f, popUpBoxOffset, 280.0f, 230.0f)];
    [self.popUpBox setBackgroundColor:[UIColor whiteColor]];
    self.popUpBox.layer.cornerRadius = 8.0f;
    [self.popUpBox setTag:110];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.popUpBox];
    
    UIView *popUpBoxHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 40.0f)];
    [popUpBoxHeader setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0]];
    popUpBoxHeader.clipsToBounds = YES;
    
    // Creating layer to only initiate the top right and left round corners.
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:popUpBoxHeader.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(8.0, 8.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = popUpBoxHeader.bounds;
    maskLayer.path = maskPath.CGPath;
    popUpBoxHeader.layer.mask = maskLayer;
    
    [self.popUpBox addSubview:popUpBoxHeader];
    
    UILabel *popUpBoxHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 80.0f, 30.0f)];
    [popUpBoxHeaderLabel setText:@"Add Link"];
    [popUpBoxHeaderLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
    [popUpBoxHeaderLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [popUpBoxHeader addSubview:popUpBoxHeaderLabel];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(popUpBoxHeader.bounds.size.width - 30.0f, 10.0f, 20.0f, 20.0f)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"button_cancel_selected.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [popUpBoxHeader addSubview:cancelButton];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 85.0f, 170.0f, 55.0f)];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    self.titleLabel.textColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    self.titleLabel.numberOfLines = 2;
    [self.popUpBox addSubview:self.titleLabel];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 85.0f, 170.0f, 80.0f)];
    [self.placeholderLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [self.placeholderLabel setTextColor:[UIColor colorWithWhite:0.85f alpha:1.0f]];
    [self.placeholderLabel setText:@"Insert your link above"];
    [self.popUpBox addSubview:self.placeholderLabel];
    
    self.popUpBoxurlLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 110.0f, 170.0f, 60.0f)];
    [self.popUpBoxurlLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    self.popUpBoxurlLabel.numberOfLines = 1;
    [self.popUpBoxurlLabel setTextColor:[UIColor colorWithWhite:0.5f alpha:10.0f]];
    [self.popUpBox addSubview:self.popUpBoxurlLabel];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    
    self.url_textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 50.0f, 200.0f, 30.0f)];
    [self.url_textField setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    self.url_textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.url_textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.url_textField.leftView = paddingView;
    self.url_textField.leftViewMode = UITextFieldViewModeAlways;
    self.url_textField.delegate = self;
    [self.url_textField becomeFirstResponder];
    [self.popUpBox addSubview:self.url_textField];
    
    self.imageView = [[PFImageView alloc] initWithFrame:CGRectMake(10.0f, 90.0f, 80.0f, 80.0f)];
    self.imageView.image = [UIImage imageNamed:@"link_thumbnail.png"];
    [self.popUpBox addSubview:self.imageView];
    
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    self.okayButton = [[UIButton alloc] initWithFrame:CGRectMake(220.0f, 50.0f, 50.0f, 30.0f)];
    [self.okayButton setBackgroundColor:[UIColor whiteColor]];
    self.okayButton.clipsToBounds = YES;
    self.okayButton.layer.cornerRadius = 3.0f;
    [self.okayButton.layer setBorderWidth:2.0f];
    [self.okayButton setTitleColor:teamStoryColor forState:UIControlStateNormal];
    [self.okayButton.layer setBorderColor:teamStoryColor.CGColor];
    [self.okayButton setTitle:@"OK" forState:UIControlStateNormal];
    [self.okayButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [self.okayButton addTarget:self action:@selector(okayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.popUpBox addSubview:self.okayButton];
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 180.0f, 260.0f, 40.0f)];
    [self.nextButton setBackgroundColor:teamStoryColor];
    self.nextButton.alpha = 0.5;
    self.nextButton.layer.cornerRadius = 3.0f;
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.enabled = NO;
    [self.popUpBox addSubview:self.nextButton];
    
    self.commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 310.0f, 171.0f)];
    self.commentTextView.delegate = self;
    self.commentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.commentTextView.text = @"Add a link comment";
    self.commentTextView.font = [UIFont systemFontOfSize:17.0f];
    [self.view addSubview:self.commentTextView];
}


# pragma mark - ()
- (void)cancelButtonAction:(id)sender {
    if ([self.titleLabel.text length] > 0) {
        [[[[UIApplication sharedApplication] delegate] window] viewWithTag:110].hidden = YES;
        [[[[UIApplication sharedApplication] delegate] window] viewWithTag:111].hidden = YES;
    } else {
        [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:110] removeFromSuperview];
        [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:111] removeFromSuperview];
        
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backButtonAction:(id)sender {
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:110] removeFromSuperview];
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:111] removeFromSuperview];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)okayButtonAction:(id)sender {
    [SVProgressHUD show];
    
    if ([self.url_textField.text length] > 0 && ([self.url_textField.text rangeOfString:@"http"].location == NSNotFound)) {
        self.url_textField.text = [NSString stringWithFormat:@"%@%@", @"http://", self.url_textField.text];
    }
    
    Embedly *embedlyInit = [[Embedly alloc] initWithKey:EMBEDLY_APP_ID delegate:self];
    [embedlyInit callEmbedlyApi:@"/1/oembed" withUrl:self.url_textField.text params:nil];
}

- (void)postButtonAction:(id)sender {
    
    // analytics
    [PAPUtility captureEventGA:@"Engagement" action:@"Upload Link" label:@"Photo"];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type": @"Core", @"Action": @"Posted Link"}];
    
    // intercome analytics
    [Intercom logEventWithName:@"posetd-link" optionalMetaData:nil
                    completion:^(NSError *error) {}];
    
    
    // increment user link count by one
    [[Mixpanel sharedInstance].people increment:@"Link Count" by:[NSNumber numberWithInt:1]];
    
    [self.view endEditing:YES];
    [SVProgressHUD show];
    
    UIImage *newLinkImage = [self createNewLinkPost];
    
    [self shouldUploadImage:newLinkImage block:^(BOOL completed) {
        
        if(completed){
            // both files have finished uploading
            if ([self.commentTextView.text isEqualToString:@"Add a link comment"]) {
                self.commentTextView.text = @"";
            }
            
            // create a photo object
            PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
            [photo setObject:self.commentTextView.text forKey:@"caption"];
            [photo setObject:@"link" forKey:kPAPPhotoType];
            [photo setObject:self.url_textField.text forKey:@"link"];
            [photo setObject:self.titleLabel.text forKey:@"linkTitle"];
            
            if ([self.linkPostDescription length] > 0) {
                [photo setObject:self.linkPostDescription forKey:@"linkDesc"];
            }
            
            if (self.imageView.image != nil) {
                [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
                [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
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
                    
                    // create activity for posted
                    [PAPUtility posted:photo];
                    
                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
                } else {
                    NSLog(@"Photo failed to save: %@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your link" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
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

- (UIImage *)createNewLinkPost{
    
    // create new imageview and set blurred image
    UIImage *resizedImg = [PAPUtility resizeImage:self.imageView.image width:320.0f height:320.0f];
    UIImageView *newLinkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    newLinkImageView.image = [self blurWithImageEffects:resizedImg];
    newLinkImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // create title to wrap around imageview bounds, add to image view
    UILabel *newLinkTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, newLinkImageView.frame.size.width - 35, newLinkImageView.frame.size.height)];
    [newLinkTitle setFont:[UIFont fontWithName:@"Avenir-Black"  size:22.0f]];
    [newLinkTitle setTextColor:[UIColor whiteColor]];
    [newLinkTitle setTextAlignment:NSTextAlignmentCenter];
    [newLinkTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [newLinkTitle setNumberOfLines:5];
    
    // add image as attachment to string so always at the end of text
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"icon_link"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];

    // couldn't add padding through frame or bounds so here's a quick hack
    NSString *formattedTitleLabelTxt = [self.titleLabel.text stringByAppendingString:@" "].uppercaseString;
    
    // build the final string
    NSMutableAttributedString *linkAtttributedText = [[NSMutableAttributedString alloc] initWithString:formattedTitleLabelTxt];
    [linkAtttributedText appendAttributedString:attachmentString];
    
    newLinkTitle.attributedText = linkAtttributedText;
    [newLinkImageView addSubview:newLinkTitle];

    // make an image out of imageview
    UIImage *newImg = [self ChangeImageViewToImage:newLinkImageView];
    
    return newImg;
}

-(UIImage *)ChangeImageViewToImage:(UIImageView *) view{
    
    // create and push image context to the stack with imageview bounds
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // get image from the context
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    // remove context from the stack
    UIGraphicsEndImageContext();
    
    return img;
}


- (UIImage *)blurWithImageEffects:(UIImage *)image
{
    return [UIImageEffects imageByApplyingBlurToImage:image withRadius:5 tintColor:[UIColor colorWithWhite:0 alpha:0.5] saturationDeltaFactor:1.5 maskImage:nil];
    
}

- (void)shouldUploadImage:(UIImage *)anImage block:(void (^)(BOOL))completed
{
    if (anImage == nil) {
        completed(YES);
        return;
    }
    
    UIImage *thumbnailImage = [PAPUtility resizeImage:anImage width:86.0f height:86.0f];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
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

- (void)nextButtonAction:(id)sender {
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:110] endEditing:YES];
    [[[[UIApplication sharedApplication] delegate] window] viewWithTag:110].hidden = YES;
    [[[[UIApplication sharedApplication] delegate] window] viewWithTag:111].hidden = YES;
    
    [self.linkPostView removeFromSuperview];
    
    [self.commentTextView becomeFirstResponder];
    
    if ([self.titleLabel.text length] > 0 ) {
        float heightOffset;
        heightOffset = 0;
        if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
            heightOffset = 95.0f;
            self.commentTextView.frame = CGRectMake(5.0f, 5.0f, 310.0f, 85.0f);
            
        } else {
            heightOffset = 180.0f;
            self.commentTextView.frame = CGRectMake(5.0f, 5.0f, 310.0f, 171.0f);
        }
        
        UITapGestureRecognizer *popUpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popUpTapAction:)];
        
        self.linkPostView = [[UIView alloc] initWithFrame:CGRectMake(5.0f, heightOffset, [UIScreen mainScreen].bounds.size.width - 10.0f, 100.0f)];
        [self.linkPostView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:0.5f]];
        [self.linkPostView.layer setBorderColor:[UIColor colorWithWhite:0.8f alpha:1.0f].CGColor];
        [self.linkPostView addGestureRecognizer:popUpTap];
        [self.linkPostView setUserInteractionEnabled:YES];
        [self.linkPostView.layer setBorderWidth:0.5f];
        [self.view addSubview:self.linkPostView];
        
        UIImageView *linkPostImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 80.0f, 80.0f)];
        linkPostImageView.image = self.imageView.image;
        linkPostImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.linkPostView addSubview:linkPostImageView];
        
        self.linkPostViewLabel_title = [[UILabel alloc] init];
        [self.linkPostViewLabel_title setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [self.linkPostViewLabel_title setText:self.titleLabel.text];
        self.linkPostViewLabel_title.numberOfLines = 2;
        [self.linkPostView addSubview:self.linkPostViewLabel_title];
        
        self.urlLabel = [[UILabel alloc] init];
        [self.urlLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
        self.urlLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.urlLabel setText:self.urlString];
        self.urlLabel.numberOfLines = 1;
        [self.linkPostView addSubview:self.urlLabel];
        
        if (self.imageView.image == nil) {
            self.linkPostViewLabel_title.frame = CGRectMake(10.0f, 10.0f, self.linkPostView.bounds.size.width - 20.0f, 55.0f);
            self.urlLabel.frame = CGRectMake(10.0f, 55.0f, self.linkPostView.bounds.size.width - 20.0f, 17.5f);
        } else {
            self.linkPostViewLabel_title.frame = CGRectMake(100.0f, 10.0f, self.linkPostView.bounds.size.width - 110.0f, 55.0f);
            self.urlLabel.frame = CGRectMake(100.0f, 55.0f, self.linkPostView.bounds.size.width - 110.0f, 17.5f);
        }
    }
    
}

-(void)popUpTapAction:(UITapGestureRecognizer *)tgr {
    [[[[UIApplication sharedApplication] delegate] window] viewWithTag:110].hidden = NO;
    [[[[UIApplication sharedApplication] delegate] window] viewWithTag:111].hidden = NO;
    
    [self.url_textField becomeFirstResponder];
}

- (void)exitPost{
    [SVProgressHUD dismiss];
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
    
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:110] removeFromSuperview];
    [[[[[UIApplication sharedApplication] delegate] window] viewWithTag:111] removeFromSuperview];
    
    // push tab bar with home controller now selected
    [self.navigationController popToViewController:tabBarController animated:YES];
}

# pragma mark - Embedly.h

- (void)embedlyFailure:(NSString *)callUrl withError:(NSError *)error endpoint:(NSString *)endpoint operation:(AFHTTPRequestOperation *)operation {
    
    [SVProgressHUD dismiss];
    
    NSLog(@"embedly failure %@", callUrl);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check the url or internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)embedlySuccess:(NSString *)callUrl withResponse:(id)response endpoint:(NSString *)endpoint operation:(AFHTTPRequestOperation *)operation {
    if ([[response objectForKey:@"thumbnail_url"] length] <= 0) {
        [SVProgressHUD dismiss];
        
        self.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
        self.titleLabel.frame = CGRectMake(10.0f, 85.0f, 260.0f, 55.0f);
        self.popUpBoxurlLabel.frame = CGRectMake(10.0f, 110.0f, 260.0f, 60.0f);
        
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.text = [response objectForKey:@"title"];
        self.popUpBoxurlLabel.text = [response objectForKey:@"url"];
        self.urlString = [response objectForKey:@"url"];
        self.linkPostDescription = [response objectForKey:@"description"];
        [self.placeholderLabel removeFromSuperview];
        
        self.nextButton.enabled = YES;
        self.nextButton.alpha = 1.0f;
    } else {
        self.titleLabel.frame = CGRectMake(100.0f, 85.0f, 170.0f, 55.0f);
        self.popUpBoxurlLabel.frame = CGRectMake(100.0f, 110.0f, 170.0f, 60.0f);
        
        self.imageView.image = [self getImageFromURL:[response objectForKey:@"thumbnail_url"] block:^(BOOL completed){
            self.titleLabel.textColor = [UIColor blackColor];
            self.titleLabel.text = [response objectForKey:@"title"];
            self.popUpBoxurlLabel.text = [response objectForKey:@"url"];
            self.urlString = [response objectForKey:@"url"];
            self.linkPostDescription = [response objectForKey:@"description"];
            [self.placeholderLabel removeFromSuperview];
            
            if(completed) {
                [SVProgressHUD dismiss];
                self.nextButton.enabled = YES;
                self.nextButton.alpha = 1.0f;
            }
            
        }];
    }
}

-(UIImage *) getImageFromURL:(NSString *)fileURL block:(void (^)(BOOL))completed{
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    completed(YES);
    return result;
}

# pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *lowerCase_pasteboard = [pasteboard.string lowercaseString];
    
    // checking for http values.
    if ([lowerCase_pasteboard hasPrefix:@"http"]) {
        textField.text = pasteboard.string;
    }
}

# pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Add a link comment"]) {
        textView.text = @"";
    }
}


@end