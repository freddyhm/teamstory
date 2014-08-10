//
//  PAPPhotoHeaderView2.m
//  Teamstory
//
//

#import "PostFooterView.h"
#import "PAPProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPUtility.h"

@interface PostFooterView () {
    float notificationBarOffset;
}

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) PAPProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) UIButton *moreActionButton;

@end


@implementation PostFooterView
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
@synthesize moreActionButton;


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame buttons:(PAPPhotoHeaderButtons2)otherButtons {
    self = [super initWithFrame:frame];
    if (self) {
        [PostFooterView validateButtons:otherButtons];
        buttons = otherButtons;

        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
        [self.containerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.containerView];
        
        if (self.buttons & PAPPhotoHeaderButtonsComment2) {
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.commentButton];
            [self.commentButton setFrame:CGRectMake(39.0f, 8.0f, 30.0f, 30.0f)];
            [self.commentButton setBackgroundColor:[UIColor clearColor]];
            [self.commentButton setTitle:@"" forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor colorWithRed:113.0f/255.0f green:189.0f/255.0f blue:168.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            //[self.commentButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
            [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake( -2.0f, 2.0f, 0.0f, 0.0f)];
            //[[self.commentButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
            [[self.commentButton titleLabel] setFont:[UIFont systemFontOfSize:9.0f]];
            //[[self.commentButton titleLabel] setMinimumFontSize:11.0f];
            [[self.commentButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.commentButton setBackgroundImage:[UIImage imageNamed:@"IconComment.png"] forState:UIControlStateNormal];
            [self.commentButton setSelected:NO];
        }
        
        if (self.buttons & PAPPhotoHeaderButtonsLike2) {
            // like button
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.likeButton];
            [self.likeButton setFrame:CGRectMake(4.0f, 8.0f, 30.0f, 30.0f)];
            [self.likeButton setBackgroundColor:[UIColor clearColor]];
            [self.likeButton setTitle:@"" forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor colorWithRed:245.0f/255.0f green:137.0f/255.0f blue:137.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            //[self.likeButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
            //[self.likeButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.750f] forState:UIControlStateSelected];
            [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
            //[[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
            [[self.likeButton titleLabel] setFont:[UIFont systemFontOfSize:9.0f]];
            //[[self.likeButton titleLabel] setMinimumFontSize:11.0f];
            [[self.likeButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.likeButton setAdjustsImageWhenHighlighted:NO];
            [self.likeButton setAdjustsImageWhenDisabled:NO];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"ButtonLike.png"] forState:UIControlStateNormal];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"ButtonLikeSelected.png"] forState:UIControlStateSelected];
            [self.likeButton setSelected:NO];
        }
                
        self.moreActionButton = [[UIButton alloc] initWithFrame:CGRectMake(270.0f, 8.0f, 30.0f, 30.0f)];
        [self.moreActionButton setImage:[UIImage imageNamed:@"button-more.png"] forState:UIControlStateNormal];
        [self.moreActionButton addTarget:self action:@selector(moreActionButton_action:) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:self.moreActionButton];
        
        
        
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        // timestamp
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 20.0f, containerView.bounds.size.width - 50.0f - 72.0f, 18.0f)];
        [containerView addSubview:self.timestampLabel];
        [self.timestampLabel setTextColor:[UIColor colorWithRed:157.0f/255.0f green:157.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
        //[self.timestampLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
        //[self.timestampLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.timestampLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
        /*
        CALayer *layer = [containerView layer];
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        layer.masksToBounds = NO;
        layer.shadowRadius = 0.5f;
        layer.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        layer.shadowOpacity = 0.3f;
        layer.shouldRasterize = YES;
        layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, containerView.frame.size.height - 4.0f, containerView.frame.size.width, 4.0f)].CGPath;
         */
        
    }

    return self;
}


#pragma mark - PAPPhotoHeaderView2

- (void)setPhoto:(PFObject *)aPhoto {
    photo = aPhoto;
    
    CGFloat constrainWidth = containerView.bounds.size.width;

    if (self.buttons & PAPPhotoHeaderButtonsComment2) {
        constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & PAPPhotoHeaderButtonsLike2) {
        constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSTimeInterval timeInterval = [[self.photo createdAt] timeIntervalSinceNow];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    [self.timestampLabel setText:timestamp];

    [self setNeedsDisplay];
}

- (void)setLikeStatus:(BOOL)liked {
    [self.likeButton setSelected:liked];
    
    if (liked) {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(1.0f, 0.5f, -1.0f, -0.5f)];
        //[[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, -1.0f)];
    } else {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(1.0f, 0.5f, -1.0f, -0.5f)];
        //[[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    }
}

- (void)shouldEnableLikeButton:(BOOL)enable {
    if (enable) {
        [self.likeButton removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - ()

- (void) moreActionButton_action:(id)sender{
    if (delegate && [delegate respondsToSelector:@selector(moreActionButton_inflator:photo:)]) {
        [delegate respondsToSelector:@selector(moreActionButton_inflator:photo:)];
        [delegate moreActionButton_inflator:[self.photo objectForKey:kPAPPhotoUserKey] photo:self.photo];
    }
}

+ (void)validateButtons:(PAPPhotoHeaderButtons2)buttons {
    if (buttons == PAPPhotoHeaderButtonsNone2) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing PAPPhotoHeaderView2."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapUserButton:user:)]) {
        [delegate photoHeaderView:self didTapUserButton:sender user:[self.photo objectForKey:kPAPPhotoUserKey]];
    }
}

- (void)didTapLikePhotoButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapLikePhotoButton:photo:)]) {
        [delegate photoHeaderView:self didTapLikePhotoButton:button photo:self.photo];
    }
}

- (void)didTapCommentOnPhotoButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapCommentOnPhotoButton:photo:)]) {
        [delegate photoHeaderView:self didTapCommentOnPhotoButton:sender photo:self.photo];
    }
}

@end
