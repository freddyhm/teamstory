//
//  PAPActivityCell.m
//  Teamstory
//
//

#import "PAPActivityCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPProfileImageView.h"
#import "PAPActivityFeedViewController.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface PAPActivityCell ()

/*! Private view components */
@property (nonatomic, strong) PAPProfileImageView *activityImageView;
@property (nonatomic, strong) UIButton *activityImageButton;

/*! Flag to remove the right-hand side image if not necessary */
@property (nonatomic) BOOL hasActivityImage;

/*! Private setter for the right-hand side image */
- (void)setActivityImageFile:(PFFile *)image;

/*! Button touch handler for activity image button overlay */
- (void)didTapActivityButton:(id)sender;

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end

@implementation PAPActivityCell


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        horizontalTextSpace = [PAPActivityCell horizontalTextSpaceForInsetWidth:0];
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }

        // Create subviews and set cell properties
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.hasActivityImage = NO; //No until one is set
        
        self.activityImageView = [[PAPProfileImageView alloc] init];
        [self.activityImageView setBackgroundColor:[UIColor clearColor]];
        [self.activityImageView setOpaque:YES];
        [self.mainView addSubview:self.activityImageView];
        
        self.activityImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.activityImageButton setBackgroundColor:[UIColor clearColor]];
        [self.activityImageButton addTarget:self action:@selector(didTapActivityButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.activityImageButton];
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
       
    // Layout the activity image and show it if it is not nil (no image for the follow activity).
    // Note that the image view is still allocated and ready to be dispalyed since these cells
    // will be reused for all types of activity.
    [self.activityImageView setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 8.0f, 33.0f, 33.0f)];
    [self.activityImageButton setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 8.0f, 33.0f, 33.0f)];

    // Add activity image if one was set
    if (self.hasActivityImage) {
        [self.activityImageView setHidden:NO];
        [self.activityImageButton setHidden:NO];
    } else {
        [self.activityImageView setHidden:YES];
        [self.activityImageButton setHidden:YES];
    }


    NSMutableParagraphStyle *paragraphStyleWordWrapping = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleWordWrapping.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize contentSize = ([self.contentLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f], NSParagraphStyleAttributeName: paragraphStyleWordWrapping.copy} context:nil]).size;
    
    
    [self.contentLabel setFrame:CGRectMake( 46.0f, 10.0f, contentSize.width, contentSize.height)];
    
    // Layout the timestamp label given new vertical
    CGSize timeSize = ([self.timeLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f], NSParagraphStyleAttributeName: paragraphStyleWordWrapping.copy} context:nil]).size;
    

    [self.timeLabel setFrame:CGRectMake( 46.0f, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + 2.0f, timeSize.width, timeSize.height)];
}


#pragma mark - PAPActivityCell

- (void)setIsNew:(BOOL)isNew {
    if (isNew) {
        //[self.mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundNewActivity.png"]]];
        [self.mainView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    } else {
        //[self.mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
        //[self.mainView setBackgroundColor:[UIColor colorWithWhite:255.0f/255.0f alpha:0.7f]];
        [self.mainView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.4]];
    }
}


- (void)setActivity:(PFObject *)activity isSubscription:(BOOL)isSubscription{
    // Set the activity property
    _activity = activity;
    
    NSString *activityType = [activity objectForKey:kPAPActivityTypeKey];
    NSString *activityString;
    
    if ([activityType isEqualToString:kPAPActivityTypeFollow] || [activityType isEqualToString:kPAPActivityTypeJoined]) {
        [self setActivityImageFile:nil];
    } else {
        [self setActivityImageFile:(PFFile*)[[activity objectForKey:kPAPActivityPhotoKey] objectForKey:kPAPPhotoThumbnailKey]];
    }
    
    // check if subscription is of type post or comment (followers push or comments)
    if(isSubscription && ![activityType isEqualToString:@"post"]){
        activityString = @"commented on a followed post";
    }else{
        activityString = [PAPActivityFeedViewController stringForActivityType:(NSString*)activityType object:activity];
    }
    
    if ([[activity objectForKey:@"atmention"] count] > 0) {
        for (int i = 0; i < [[activity objectForKey:@"atmention"] count]; i++) {
            if ([[[[activity objectForKey:@"atmention"] objectAtIndex:i] objectId] isEqualToString:[PFUser currentUser].objectId]) {
                activityString = NSLocalizedString(@"mentioned you in a post", nil);
                break;
            }
        }
    }
    
    if ([activityType isEqualToString:@"like comment"]) {
        activityString = NSLocalizedString(@"liked your comment", nil);
    }
    
    self.user = [activity objectForKey:kPAPActivityFromUserKey];
    
    // Set name button properties and avatar image
    [self.avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    
    NSString *nameString = NSLocalizedString(@"Someone", nil);
    if (self.user && [self.user objectForKey:kPAPUserDisplayNameKey] && [[self.user objectForKey:kPAPUserDisplayNameKey] length] > 0) {
        nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
    }
    
    [self.nameButton setTitle:nameString forState:UIControlStateNormal];
    [self.nameButton setTitle:nameString forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }

    if (self.user) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        CGSize nameSize = ([self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f], NSParagraphStyleAttributeName: paragraphStyle.copy} context:nil]).size;
        
        NSString *paddedString = [PAPBaseTextCell padString:activityString withFont:[UIFont systemFontOfSize:13.0f] toWidth:nameSize.width];    
        [self.contentLabel setText:paddedString];
    } else { // Otherwise we ignore the padding and we'll add it after we set the user
        [self.contentLabel setText:activityString];
    }

    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[activity createdAt] type:@"activity"]];

    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    [super setCellInsetWidth:insetWidth];
    horizontalTextSpace = [PAPActivityCell horizontalTextSpaceForInsetWidth:insetWidth];
}

// Since we remove the compile-time check for the delegate conforming to the protocol
// in order to allow inheritance, we add run-time checks.
- (id<PAPActivityCellDelegate>)delegate {
    return (id<PAPActivityCellDelegate>)_delegate;
}

- (void)setDelegate:(id<PAPActivityCellDelegate>)delegate {
    if(_delegate != delegate) {
        _delegate = delegate;
    }
}


#pragma mark - ()

+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return ([UIScreen mainScreen].bounds.size.width - (insetWidth * 2.0f)) - 72.0f - 46.0f;
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [self heightForCellWithName:name contentString:content cellInsetWidth:0.0f];
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGSize nameSize = ([name boundingRectWithSize:CGSizeMake(200.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f], NSParagraphStyleAttributeName: paragraphStyle.copy} context:nil]).size;
    
    NSString *paddedString = [PAPBaseTextCell padString:content withFont:[UIFont systemFontOfSize:13.0f] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [PAPActivityCell horizontalTextSpaceForInsetWidth:cellInset];
    
    NSMutableParagraphStyle *paragraphStyleWordWrap = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleWordWrap.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize contentSize = ([paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f], NSParagraphStyleAttributeName: paragraphStyleWordWrap.copy} context:nil]).size;
    
    CGFloat singleLineHeight = [@"Test" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}].height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = contentSize.height - singleLineHeight;

    return 48.0f + fmax(0.0f, multilineHeightAddition);
}

- (void)setActivityImageFile:(PFFile *)imageFile {
    if (imageFile) {
        [self.activityImageView setFile:imageFile];
        [self setHasActivityImage:YES];
    } else {
        [self setHasActivityImage:NO];
    }
}

- (void)didTapActivityButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapActivityButton:)]) {
        [self.delegate cell:self didTapActivityButton:self.activity];
    }    
}

- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}


@end
