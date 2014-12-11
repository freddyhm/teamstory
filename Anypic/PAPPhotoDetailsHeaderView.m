//
//  PAPPhotoDetailsHeaderView.m
//  Teamstory
//
//

#import "PAPPhotoDetailsHeaderView.h"
#import "PAPProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "MBProgressHUD.h"
#import "PAPwebviewViewController.h"
#import "Mixpanel.h"
#import "Intercom.h"

#define baseHorizontalOffset 0.0f
#define baseWidth 320.0f

#define horiBorderSpacing 6.0f
#define horiMediumSpacing 8.0f

#define vertBorderSpacing 6.0f
#define vertSmallSpacing 2.0f


#define nameHeaderX baseHorizontalOffset
#define nameHeaderY 0.0f
#define nameHeaderWidth baseWidth
#define nameHeaderHeight 44.0f

#define avatarImageX horiBorderSpacing
#define avatarImageY vertBorderSpacing
#define avatarImageDim 35.0f

#define nameLabelX avatarImageX+avatarImageDim+horiMediumSpacing
#define nameLabelY avatarImageY+vertSmallSpacing
#define nameLabelMaxWidth 305.0f - (horiBorderSpacing+avatarImageDim+horiMediumSpacing+horiBorderSpacing)

#define timeLabelX 282.0f
#define timeLabelMaxWidth nameLabelMaxWidth

#define mainImageX baseHorizontalOffset
#define mainImageY nameHeaderHeight
#define mainImageWidth baseWidth
#define mainImageHeight 320.0f

#define likeBarX baseHorizontalOffset
#define likeBarY nameHeaderHeight + mainImageHeight
#define likeBarWidth baseWidth
#define likeBarHeight 43.0f

#define likeButtonX 9.0f
#define likeButtonY 7.0f
#define likeButtonDim 28.0f

#define likeProfileXBase 46.0f
#define likeProfileXSpace 3.0f
#define likeProfileY 6.0f
#define likeProfileDim 30.0f

#define contentY nameHeaderHeight + mainImageHeight
#define numLikePics 7.0f
static CGSize expectedSize;

@interface PAPPhotoDetailsHeaderView () {
    float viewOffset;
}


// View components
@property (nonatomic, strong) UIView *nameHeaderView;
@property (nonatomic, strong) PFImageView *photoImageView;
@property (nonatomic, strong) UIView *likeBarView;
@property (nonatomic, strong) NSMutableArray *currentLikeAvatars;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) UILabel *photoDescriptionLabel;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) UIImageView *clockIcon;
@property (nonatomic, strong) UIView *linkBackgroundView;
@property (nonatomic, strong) UIView *linkContentView;
@property (nonatomic, strong) UILabel *linkTitleLabel;
@property (nonatomic, strong) UILabel *linkDescription;
@property (nonatomic, strong) UILabel *linkUrlLabel;
@property (nonatomic, strong) UILabel *userInfoLabel;

// Redeclare for edit
@property (nonatomic, strong, readwrite) PFUser *photographer;

// Private methods
- (void)createView;

@end


static TTTTimeIntervalFormatter *timeFormatter;

@implementation PAPPhotoDetailsHeaderView

@synthesize photo;
@synthesize photographer;
@synthesize likeUsers;
@synthesize nameHeaderView;
@synthesize photoImageView;
@synthesize likeBarView;
@synthesize likeButton;
@synthesize delegate;
@synthesize currentLikeAvatars;
@synthesize companyName;
@synthesize photoDescriptionLabel;
@synthesize description;
@synthesize hud;
@synthesize website;
@synthesize navController;
@synthesize linkBackgroundView;
@synthesize linkContentView;
@synthesize linkTitleLabel;
@synthesize linkDescription;
@synthesize linkUrlLabel;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto description:(NSString *)adescription navigationController:(UINavigationController *)anavController{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
            [timeFormatter setUsesAbbreviatedCalendarUnits:YES];
        }
        
        self.photo = aPhoto;
        self.photographer = [self.photo objectForKey:kPAPPhotoUserKey];
        self.likeUsers = nil;
        
        self.navController = anavController;
        self.description = adescription;
        
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }

        self.photo = aPhoto;
        self.photographer = aPhotographer;
        self.likeUsers = theLikeUsers;
        
        self.backgroundColor = [UIColor clearColor];

        if (self.photo && self.photographer && self.likeUsers) {
            [self createView];
        }
        
    }
    return self;
}

#pragma mark - UIView
/*
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [PAPUtility drawSideDropShadowForRect:self.nameHeaderView.frame inContext:UIGraphicsGetCurrentContext()];
    [PAPUtility drawSideDropShadowForRect:self.photoImageView.frame inContext:UIGraphicsGetCurrentContext()];
    [PAPUtility drawSideDropShadowForRect:self.likeBarView.frame inContext:UIGraphicsGetCurrentContext()];
}
*/

#pragma mark - PAPPhotoDetailsHeaderView

- (void)setPhoto:(PFObject *)aPhoto {
    photo = aPhoto;

    if (self.photo && self.photographer && self.likeUsers) {
        [self createView];
        [self setNeedsDisplay];
    }
}

- (void)setLikeUsers:(NSMutableArray *)anArray {
    likeUsers = [anArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *liker1, PFUser *liker2) {
        NSString *displayName1 = [liker1 objectForKey:kPAPUserDisplayNameKey];
        NSString *displayName2 = [liker2 objectForKey:kPAPUserDisplayNameKey];
        
        if ([[liker1 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedAscending;
        } else if ([[liker2 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedDescending;
        }
        
        return [displayName1 compare:displayName2 options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    }];
    
    for (PAPProfileImageView *image in currentLikeAvatars) {
        [image removeFromSuperview];
    }

    [likeButton setTitle:[NSString stringWithFormat:@"%d", (int)self.likeUsers.count] forState:UIControlStateNormal];

    self.currentLikeAvatars = [[NSMutableArray alloc] initWithCapacity:likeUsers.count];
    int i;
    int numOfPics = numLikePics > (int)self.likeUsers.count ? (int)self.likeUsers.count : numLikePics;

    for (i = 0; i < numOfPics; i++) {
        PAPProfileImageView *profilePic = [[PAPProfileImageView alloc] init];
        [profilePic setFrame:CGRectMake(likeProfileXBase + i * (likeProfileXSpace + likeProfileDim), likeProfileY, likeProfileDim, likeProfileDim)];
        [profilePic.profileButton addTarget:self action:@selector(didTapLikerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        profilePic.profileButton.tag = i;
        [profilePic setFile:[[self.likeUsers objectAtIndex:i] objectForKey:kPAPUserProfilePicSmallKey]];
        [likeBarView addSubview:profilePic];
        [currentLikeAvatars addObject:profilePic];
    }
    
    [self setNeedsDisplay];
}

- (void)setLikeButtonState:(BOOL)selected {
    if (selected) {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake(1.0f, 0.5f, -1.0f, -0.5f)];
        //[[likeButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    } else {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake(1.0f, 0.5f, -1.0f, -0.5f)];
        //[[likeButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
    }
    [likeButton setSelected:selected];
}

- (void)reloadLikeBar {
    self.likeUsers = [[PAPCache sharedCache] likersForPhoto:self.photo];
    [self setLikeButtonState:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:self.photo]];
    [likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];    
}


#pragma mark - ()

- (void)createView {    
    /*
     Create middle section of the header view; the image
     */
    [self.hud show:YES];
        
    if ([self.description length] > 0) {
        CGSize maximumLabelSize = CGSizeMake(320.0f - 7.5f * 4, 9999.0f);
        
        NSRange range = [self.description rangeOfString:@"(?i)(http\\S+|www\\.\\S+|\\w+\\.(com|ca|\\w{2,3})(\\S+)?)" options:NSRegularExpressionSearch];
        
        if (range.location != NSNotFound) {
            NSString *lowerCaseString = [[self.description substringWithRange:range] lowercaseString];
            self.description = [self.description stringByReplacingCharactersInRange:range withString:lowerCaseString];
        }
        
        NSMutableAttributedString *captionText = [[NSMutableAttributedString alloc] initWithString:self.description];
        [captionText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:86.0f/255.0f green:130.0f/255.0f blue:164.0f/255.0f alpha:1.0f] range:range];
        
        if (range.length > 0) {
            self.website = [self.description substringWithRange:range];
        }
        
        self.photoDescriptionLabel = [[UILabel alloc] init];
        self.photoDescriptionLabel.backgroundColor = [UIColor clearColor];
        self.photoDescriptionLabel.numberOfLines = 0;
        self.photoDescriptionLabel.font = [UIFont systemFontOfSize:13.0f];
        self.photoDescriptionLabel.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        self.photoDescriptionLabel.attributedText = captionText;
        [self.photoDescriptionLabel setUserInteractionEnabled:YES];
        
        if (range.length > 0) {
            UITapGestureRecognizer *gestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUrl:)];
            gestureRec.numberOfTouchesRequired = 1;
            gestureRec.numberOfTapsRequired = 1;
            [self.photoDescriptionLabel addGestureRecognizer:gestureRec];
        }
        
        expectedSize = [self.photoDescriptionLabel sizeThatFits:maximumLabelSize];
        
        viewOffset = 39;
        
        self.photoImageView = [[PFImageView alloc]init];
        
        [self addSubview:self.photoDescriptionLabel];
        
        if ([[self.photo objectForKey:@"type"] isEqualToString:@"link"]) {
            
            self.photoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageX + 10.0f, mainImageY + 10.0f, 80.0f, 80.0f)];
            
            viewOffset = -190.0f;
            
            UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkPostButtonAction:)];
            [photoTap setNumberOfTapsRequired:1];
            [photoTap setNumberOfTouchesRequired:1];
            
            self.linkBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(mainImageX, mainImageY, mainImageWidth, 100.0f)];
            
            [self.linkBackgroundView setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:self.linkBackgroundView];
            
            self.linkContentView = [[UIView alloc] initWithFrame:CGRectMake(mainImageX + 5.0f, mainImageY + 5.0f, self.linkBackgroundView.bounds.size.width - 10.0f, self.linkBackgroundView.bounds.size.height - 10.0f)];
            [self.linkContentView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
            [self.linkContentView.layer setBorderColor:[UIColor colorWithWhite:0.9f alpha:1.0f].CGColor];
            [self.linkContentView addGestureRecognizer:photoTap];
            [self.linkContentView setUserInteractionEnabled:YES];
            [self addSubview:self.linkContentView];
            
            self.linkTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(95.0f, 5.0f, 190.0f, 30.0f)];
            [self.linkTitleLabel setText:[self.photo objectForKey:@"linkTitle"]];
            self.linkTitleLabel.numberOfLines = 2;
            self.linkTitleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
            [self.linkTitleLabel setTextColor:[UIColor colorWithWhite:0.3f alpha:1.0]];
            [self.linkContentView addSubview:self.linkTitleLabel];
            
            self.linkDescription = [[UILabel alloc] initWithFrame:CGRectMake(95.0f, 35.0f, 190.0f, 30.0f)];
            self.linkDescription.numberOfLines = 2;
            [self.linkDescription setText:[self.photo objectForKey:@"linkDesc"]];
            self.linkDescription.font = [UIFont systemFontOfSize:12.0f];
            [self.linkDescription setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0]];
            [self.linkContentView addSubview:self.linkDescription];
            
            self.linkUrlLabel = [[UILabel alloc] initWithFrame:CGRectMake(95.0f, 65.0f, 190.0f, 15.0f)];
            [self.linkUrlLabel setText:[self.photo objectForKey:@"link"]];
            self.linkUrlLabel.numberOfLines = 1;
            self.linkUrlLabel.font = [UIFont systemFontOfSize:11.0f];
            [self.linkUrlLabel setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0]];
            [self.linkContentView addSubview:self.linkUrlLabel];
            
            self.photoDescriptionLabel.frame = CGRectMake(12.0f, self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height + 20.0f, 295.0f, expectedSize.height + 5.0f);

        } else {
            
            self.photoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageX, mainImageY, mainImageWidth, mainImageHeight)];
            
            self.photoDescriptionLabel.frame = CGRectMake(12.0f, self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height + 20.0f, 295.0f, expectedSize.height);
        }
        
        self.photoImageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
        self.photoImageView.backgroundColor = [UIColor blackColor];
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        PFFile *imageFile = [self.photo objectForKey:kPAPPhotoPictureKey];
        
        if (imageFile) {
            self.photoImageView.file = imageFile;
            [self.photoImageView loadInBackground];
        }
        
        [self addSubview:self.photoImageView];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(baseHorizontalOffset, nameHeaderHeight + 15.0f, mainImageWidth, self.photoImageView.frame.size.height + self.photoDescriptionLabel.frame.size.height + 50.0f)];
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:backgroundView];
        [self sendSubviewToBack:backgroundView];
        
    } else {
        viewOffset = 0;
        
        if ([[self.photo objectForKey:@"type"] isEqualToString:@"link"]) {
            self.photoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageX + 10.0f, mainImageY + 10.0f, 80.0f, 80.0f)];
            viewOffset = -220.0f;
            
            self.linkBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(mainImageX, mainImageY, mainImageWidth, 100.0f)];
            [self.linkBackgroundView setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:self.linkBackgroundView];
            
            UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkPostButtonAction:)];
            [photoTap setNumberOfTapsRequired:1];
            [photoTap setNumberOfTouchesRequired:1];
            
            self.linkContentView = [[UIView alloc] initWithFrame:CGRectMake(mainImageX + 5.0f, mainImageY + 5.0f, self.linkBackgroundView.bounds.size.width - 10.0f, self.linkBackgroundView.bounds.size.height - 10.0f)];
            [self.linkContentView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
            [self.linkContentView.layer setBorderColor:[UIColor colorWithWhite:0.9f alpha:1.0f].CGColor];
            [self.linkContentView addGestureRecognizer:photoTap];
            [self.linkContentView setUserInteractionEnabled:YES];
            [self addSubview:self.linkContentView];
            
            self.linkTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(95.0f, 5.0f, 190.0f, 30.0f)];
            [self.linkTitleLabel setText:[self.photo objectForKey:@"linkTitle"]];
            self.linkTitleLabel.numberOfLines = 2;
            self.linkTitleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
            [self.linkTitleLabel setTextColor:[UIColor colorWithWhite:0.3f alpha:1.0]];
            [self.linkContentView addSubview:self.linkTitleLabel];
            
            self.linkDescription = [[UILabel alloc] initWithFrame:CGRectMake(95.0f, 35.0f, 190.0f, 30.0f)];
            self.linkDescription.numberOfLines = 2;
            [self.linkDescription setText:[self.photo objectForKey:@"linkDesc"]];
            self.linkDescription.font = [UIFont systemFontOfSize:12.0f];
            [self.linkDescription setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0]];
            [self.linkContentView addSubview:self.linkDescription];
            
            self.linkUrlLabel = [[UILabel alloc] initWithFrame:CGRectMake(95.0f, 65.0f, 190.0f, 15.0f)];
            [self.linkUrlLabel setText:[self.photo objectForKey:@"link"]];
            self.linkUrlLabel.numberOfLines = 1;
            self.linkUrlLabel.font = [UIFont systemFontOfSize:11.0f];
            [self.linkUrlLabel setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0]];
            [self.linkContentView addSubview:self.linkUrlLabel];
        } else {
            self.photoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageX, mainImageY, mainImageWidth, mainImageHeight)];
        }
        self.photoImageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
        self.photoImageView.backgroundColor = [UIColor blackColor];
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        PFFile *imageFile = [self.photo objectForKey:kPAPPhotoPictureKey];
            
        if (imageFile) {
            self.photoImageView.file = imageFile;
            
            if(![self.photoImageView.file isDataAvailable]){
                [self.photoImageView loadInBackground];
            }
        }
        
        expectedSize.height = 0.0f;
        
        [self addSubview:self.photoImageView];
        
    }
    
        /*
         Create top of header view with name and avatar
         */
        self.nameHeaderView = [[UIView alloc] initWithFrame:CGRectMake(nameHeaderX, nameHeaderY, nameHeaderWidth, nameHeaderHeight)];
        self.nameHeaderView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.nameHeaderView];
    
    
    
        
        // Load data for header
        [self.photographer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            // Create avatar view
            PAPProfileImageView *avatarImageView = [[PAPProfileImageView alloc] initWithFrame:CGRectMake(avatarImageX, avatarImageY, avatarImageDim, avatarImageDim)];
            [avatarImageView setFile:[self.photographer objectForKey:kPAPUserProfilePicSmallKey]];
            [avatarImageView setBackgroundColor:[UIColor clearColor]];
            [avatarImageView setOpaque:NO];
            [avatarImageView.profileButton addTarget:self action:@selector(didTapUserNameButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            //[avatarImageView load:^(UIImage *image, NSError *error) {}];
            [nameHeaderView addSubview:avatarImageView];
            
            // Create name label
            NSString *nameString = [self.photographer objectForKey:kPAPUserDisplayNameKey];
            UIButton *userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [nameHeaderView addSubview:userButton];
            [userButton setBackgroundColor:[UIColor clearColor]];
            [[userButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15.0f]];
            [userButton setTitle:nameString forState:UIControlStateNormal];
            [userButton setTitleColor:[UIColor colorWithRed:87.0f/255.0f green:185.0f/255.0f blue:159.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            //[userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            [[userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
            //[[userButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
            //[userButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
            [userButton addTarget:self action:@selector(didTapUserNameButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            // we resize the button to fit the user's name to avoid having a huge touch area
            CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
            CGFloat constrainWidth = self.nameHeaderView.bounds.size.width - (avatarImageView.bounds.origin.x + avatarImageView.bounds.size.width);
            
            CGSize constrainSize = CGSizeMake(constrainWidth, self.nameHeaderView.bounds.size.height - userButtonPoint.y*2.0f);
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            
            CGSize userButtonSize = ([userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                                attributes:@{NSFontAttributeName:userButton.titleLabel.font, NSParagraphStyleAttributeName: paragraphStyle.copy}
                                                                                   context:nil]).size;
            
            CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
            [userButton setFrame:userButtonFrame];
            
            // Create time label
            NSString *timeString = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[self.photo createdAt] type:@"header"];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, 12.0f, 23, 18)];
            [timeLabel setText:timeString];
            [timeLabel setFont:[UIFont boldSystemFontOfSize:10.0f]];
            [timeLabel adjustsFontSizeToFitWidth];
            timeLabel.textAlignment = NSTextAlignmentRight;
        
            [timeLabel setTextColor:[UIColor colorWithRed:160.0f/255.0f green:157.0f/255.0f blue:157.0f/255.0f alpha:0.7f]];
            [timeLabel setBackgroundColor:[UIColor clearColor]];
            [self.nameHeaderView addSubview:timeLabel];
            
            [self setNeedsDisplay];
            
            
            self.userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 20.0f, self.bounds.size.width - 50.0f - 72.0f, 18.0f)];
            [self.userInfoLabel setTextColor:[UIColor colorWithRed:157.0f/255.0f green:157.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
            [self.userInfoLabel setFont:[UIFont systemFontOfSize:11.0f]];
            [self.userInfoLabel setBackgroundColor:[UIColor clearColor]];
            [self.userInfoLabel setAdjustsFontSizeToFitWidth:YES];
            
            NSString *industry = [object objectForKey:@"industry"];
            NSString *location = [object objectForKey:@"location"];
            NSString *userInfoSeparator = @" • ";
            NSString *allInfo = @"";
            
            if(industry && location){
                allInfo = [[industry stringByAppendingString:userInfoSeparator] stringByAppendingString:location];
            }else if(!industry && location){
                allInfo = location;
            }else if(industry && !location){
                allInfo = location;
            }
            
            [self.userInfoLabel setText:allInfo];
            
            
            [self.nameHeaderView addSubview:self.userInfoLabel];
        }];
    
        /*
         Create bottom section fo the header view; the likes
         */
        likeBarView = [[UIView alloc] init];
        [likeBarView setFrame:CGRectMake(likeBarX, likeBarY + expectedSize.height + viewOffset, likeBarWidth, likeBarHeight)];
        [likeBarView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:likeBarView];
        
        // Create the heart-shaped like button
        likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [likeButton setFrame:CGRectMake(likeButtonX, likeButtonY, likeButtonDim, likeButtonDim)];
        [likeButton setBackgroundColor:[UIColor clearColor]];
        [likeButton setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
        [likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake(50.0f, 0.0f, 50.0f, 0.0f)];
        [[likeButton titleLabel] setFont:[UIFont systemFontOfSize:9.0f]];
        
        [[likeButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
        [likeButton setAdjustsImageWhenDisabled:NO];
        [likeButton setAdjustsImageWhenHighlighted:NO];
        [likeButton setBackgroundImage:[UIImage imageNamed:@"ButtonLike.png"] forState:UIControlStateNormal];
        [likeButton setBackgroundImage:[UIImage imageNamed:@"ButtonLikeSelected.png"] forState:UIControlStateSelected];
        [likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [likeBarView addSubview:likeButton];
        
        [self reloadLikeBar];
        
        UIImageView *separator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)]];
        [separator setFrame:CGRectMake(0.0f, likeBarView.frame.size.height - 2.0f, likeBarView.frame.size.width, 2.0f)];
        [likeBarView addSubview:separator];
    
        UIButton *moreActionButton = [[UIButton alloc] initWithFrame:CGRectMake(281.0f, self.likeBarView.frame.origin.y + 5.0f , 30.0f, 30.0f)];
    
        [moreActionButton setImage:[UIImage imageNamed:@"button-more.png"] forState:UIControlStateNormal];
        [moreActionButton addTarget:self action:@selector(moreActionButton_action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreActionButton];
    
        [self.hud hide:YES];
    
}

- (void)moreActionButton_action:(id)sender{
    if (delegate && [delegate respondsToSelector:@selector(moreActionButton_inflator:photo:)]) {
        [delegate respondsToSelector:@selector(moreActionButton_inflator:photo:)];
        [delegate moreActionButton_inflator:[self.photo objectForKey:kPAPPhotoUserKey] photo:self.photo];
    }
}

- (void)didTapLikePhotoButtonAction:(UIButton *)button {
    BOOL liked = !button.selected;
    [button removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setLikeButtonState:liked];

    NSArray *originalLikeUsersArray = [NSArray arrayWithArray:self.likeUsers];
    NSMutableSet *newLikeUsersSet = [NSMutableSet setWithCapacity:[self.likeUsers count]];
    
    for (PFUser *likeUser in self.likeUsers) {
        // add all current likeUsers BUT currentUser
        if (![[likeUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [newLikeUsersSet addObject:likeUser];
        }
    }
    
    if (liked) {
        
        
        // get post type
        NSString *postType = [self.photo objectForKey:@"type"] != nil ? [self.photo objectForKey:@"type"] : @"";
        
        // analytics
        [PAPUtility captureEventGA:@"Engagement" action:@"Like" label:@"Photo"];
        
        // mixpanel analytics
        [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Liked Post", @"Source": @"Details", @"Post Type": postType}];
        
        // intercome analytics
        [Intercom logEventWithName:@"liked-post" optionalMetaData:@{@"source": @"details"}
                        completion:^(NSError *error) {}];

        
        // increment user like count by one
        [[Mixpanel sharedInstance].people increment:@"Like Count" by:[NSNumber numberWithInt:1]];
        
        
        [[PAPCache sharedCache] incrementLikerCountForPhoto:self.photo];
        [newLikeUsersSet addObject:[PFUser currentUser]];
    } else {
        [[PAPCache sharedCache] decrementLikerCountForPhoto:self.photo];
    }
    
    [[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:self.photo liked:liked];

    [self setLikeUsers:[newLikeUsersSet allObjects]];

    if (liked) {
        [PAPUtility likePhotoInBackground:self.photo block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:NO];
            }
        }];
    } else {
        [PAPUtility unlikePhotoInBackground:self.photo block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:YES];
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:self.photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:liked] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
}

- (void)didTapLikerButtonAction:(UIButton *)button {
    PFUser *user = [self.likeUsers objectAtIndex:button.tag];
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate photoDetailsHeaderView:self didTapUserButton:button user:user];
    }
}

- (void)didTapUserNameButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(photoDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate photoDetailsHeaderView:self didTapUserButton:button user:self.photographer];
    }    
}

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 407.0f);
}

- (void)openUrl:(id)sender {
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Passive", @"Action": @"Viewed Link"}];
    
    // intercome analytics
    [Intercom logEventWithName:@"viewed-link" optionalMetaData:nil
                    completion:^(NSError *error) {}];

    
    if ([self.website rangeOfString:@"(?i)http" options:NSRegularExpressionSearch].location == NSNotFound) {
        NSString *http = @"http://";
        self.website = [NSString stringWithFormat:@"%@%@", http, self.website];
    }
    
    //self.website = [self.website stringWithFormat:@"%@/%@/%@", ];
    PAPwebviewViewController *webViewController = [[PAPwebviewViewController alloc] initWithWebsite:self.website];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:webViewController animated:YES];
    
}

-(void)linkPostButtonAction:(UITapGestureRecognizer *)gr {
    PAPwebviewViewController *webViewController = [[PAPwebviewViewController alloc] initWithWebsite:[self.photo objectForKey:@"link"]];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:webViewController animated:YES];
}


@end
