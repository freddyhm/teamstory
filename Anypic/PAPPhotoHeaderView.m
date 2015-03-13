//
//  PAPPhotoHeaderView.m
//  Teamstory
//
//

#import "PAPPhotoHeaderView.h"
#import "PAPProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPUtility.h"

@interface PAPPhotoHeaderView () {
    float notificationBarOffset;
    float headerNameLengthOffset;
}

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) PAPProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIImageView *clockIcon;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UILabel *userInfoLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) UIImage *followButtonImage;

@end


@implementation PAPPhotoHeaderView
@synthesize containerView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize timestampLabel;
@synthesize timeIntervalFormatter;
@synthesize photo;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame buttons:(PAPPhotoHeaderButtons)otherButtons {
    self = [super initWithFrame:frame];
    if (self) {
        [PAPPhotoHeaderView validateButtons:otherButtons];
        buttons = otherButtons;

        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
        [self.containerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.containerView];
        
        
        self.avatarImageView = [[PAPProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 4.0f, 4.0f, 35.0f, 35.0f);
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.avatarImageView];
        
        if (self.buttons & PAPPhotoHeaderButtonsUser) {
            // This is the user's display name, on a button so that we can tap on it
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.userButton];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [[self.userButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
            [self.userButton setTitleColor:[UIColor colorWithRed:79.0f/255.0f green:182.0f/255.0f blue:154.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [[self.userButton titleLabel] setTextAlignment:NSTextAlignmentRight];
            [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        }
        
        self.userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 20.0f, containerView.bounds.size.width - 50.0f - 72.0f, 18.0f)];
        [self.userInfoLabel setTextColor:[UIColor colorWithRed:157.0f/255.0f green:157.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
        [self.userInfoLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.userInfoLabel setBackgroundColor:[UIColor clearColor]];
        [self.userInfoLabel setAdjustsFontSizeToFitWidth:YES];
        [containerView addSubview:self.userInfoLabel];
        
        // Add timestamp
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        self.timestampLabel = [[UILabel alloc] init];
        [self.timestampLabel setTextColor:[UIColor colorWithRed:160.0f/255.0f green:157.0f/255.0f blue:157.0f/255.0f alpha:0.7f]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
        self.timestampLabel.textAlignment = NSTextAlignmentRight;
        self.timestampLabel.hidden = YES;
        [containerView addSubview:self.timestampLabel];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.followButtonImage = [UIImage imageNamed:@"btn_no_follow_user.png"];
        
        [self.followButton setImage:self.followButtonImage forState:UIControlStateNormal];
        [self.followButton setFrame:CGRectMake( 261.0f, 10.0f, self.followButtonImage.size.width, self.followButtonImage.size.height)];
        [self.followButton setImage:[UIImage imageNamed:@"btn_following_user.png"] forState:UIControlStateSelected];
        [self.followButton addTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.followButton.hidden = YES;
        [containerView addSubview:self.followButton];
        
        self.activityCount = [[UILabel alloc] initWithFrame:self.followButton.frame];
        self.activityCount.backgroundColor = [UIColor orangeColor];
        self.activityCount.textColor = [UIColor whiteColor];
        self.activityCount.layer.cornerRadius = 13.0f;
        self.activityCount.clipsToBounds = YES;
        self.activityCount.hidden = YES;
        self.activityCount.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:self.activityCount];
        
    }

    return self;
}


#pragma mark - PAPPhotoHeaderView

- (void)setPhoto:(PFObject *)aPhoto {
    photo = aPhoto;
    self.user = [self.photo objectForKey:kPAPPhotoUserKey];
    self.timestampLabel.hidden = NO;
    self.activityCount.hidden = YES;
    
    headerNameLengthOffset = 35.0f;
    
    [self populateDetails];

}

- (void)setUserForHeaderView:(PFUser *)aUser {
    self.user = aUser;
    self.followButton.hidden = NO;
    self.timestampLabel.hidden = YES;
    self.activityCount.hidden = YES;
    
    headerNameLengthOffset = 60.0f;
    [self populateDetails];
}

- (void)setForActivityPointView:(PFUser *)aUser {
    self.user = aUser;
    self.followButton.hidden = YES;
    self.timestampLabel.hidden = YES;
    self.activityCount.hidden = NO;
    
    headerNameLengthOffset = 60.0f;
    [self populateDetails];
}


-(void) populateDetails {
    // user's avatar
    PFFile *profilePictureSmall = [self.user objectForKey:kPAPUserProfilePicSmallKey];
    [self.avatarImageView setFile:profilePictureSmall];
    
    NSString *authorName = [self.user objectForKey:kPAPUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    CGFloat constrainWidth = containerView.bounds.size.width;
    
    if (self.buttons & PAPPhotoHeaderButtonsUser) {
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    // we resize the button to fit the user's name to avoid having a huge touch area
    CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
    constrainWidth -= userButtonPoint.x + headerNameLengthOffset;
    CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGSize userButtonSize = ([self.userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{NSFontAttributeName:self.userButton.titleLabel.font, NSParagraphStyleAttributeName: paragraphStyle.copy}
                                                                           context:nil]).size;
    
    
    
    
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
    [self.userButton setFrame:userButtonFrame];
    
    // Get time interval
    NSTimeInterval timeInterval = [[self.photo createdAt] timeIntervalSinceNow];
    [self.timeIntervalFormatter setUsesAbbreviatedCalendarUnits:YES];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    
    // Set timestamp
    [self.timestampLabel setText:timestamp];
    [self.timestampLabel setFont:[UIFont boldSystemFontOfSize:10.0f]];
    
    // Update timestamp frame
    [self.timestampLabel setFrame:CGRectMake(282.0f, 12.0f, 23.0f, 18.0f)];
    
    [self.timestampLabel adjustsFontSizeToFitWidth];
    
    [self setNeedsDisplay];
    
    NSString *industry = [self.user objectForKey:@"industry"];
    NSString *location = [self.user objectForKey:@"location"];
    NSString *separator = @" • ";
    NSString *allInfo = @"";
    
    if(industry.length > 0 && location.length > 0){
        allInfo = [[industry stringByAppendingString:separator] stringByAppendingString:location];
    }else if(industry.length == 0 && location.length > 0){
        allInfo = location;
    }else if(industry.length > 0 && location.length == 0){
        allInfo = industry;
    }
    
    [self.userInfoLabel setText:allInfo];
    [self.activityCount setText:[(NSNumber *)[self.user objectForKey:@"activityPoints"] stringValue]];
}


#pragma mark - ()


+ (void)validateButtons:(PAPPhotoHeaderButtons)buttons {
    if (buttons == PAPPhotoHeaderButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing PAPPhotoHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapUserButton:user:)]) {
        [delegate photoHeaderView:self didTapUserButton:sender user:self.user];
    }
}

/* Inform delegate that the follow button was tapped */
- (void)didTapFollowButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapFollowButtonForDiscover:user:)]) {
        [delegate photoHeaderView:self didTapFollowButtonForDiscover:sender user:self.user];
    }
}

@end
