//
//  PAPpostFooterView2.m
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

        self.clipsToBounds =YES;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
        [self.containerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.containerView];
        
        // Default comment and like color
        UIColor *likeCommentColor = [UIColor colorWithRed:157.0f/255.0f green:157.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        
        if (self.buttons & PAPPhotoHeaderButtonsComment2) {
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.commentButton];
            
            [self.commentButton setFrame:CGRectMake(109.0f, 9.0f, 25.0f, 25.0f)];
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
            
            self.commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.commentButton.frame.origin.x + self.commentButton.frame.size.width + 5.0f, self.commentButton.frame.origin.y + 5.0f, 10, 15)];
            [self.commentCountLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [self.commentCountLabel setText:@"0"];
            [self.commentCountLabel setTextColor:likeCommentColor];

             self.commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.commentCountLabel.frame.origin.x + self.commentCountLabel.frame.size.width, self.commentButton.frame.origin.y + 5.0f, 80, 15)];
            
            [self.commentTitle setTextColor:likeCommentColor];
            [self.commentTitle setFont:[UIFont systemFontOfSize:12.0f]];
            [self.commentTitle setText:@" Comments"];
            
            [containerView addSubview:self.commentCountLabel];
            [containerView addSubview:self.commentTitle];
        }
        
        if (self.buttons & PAPPhotoHeaderButtonsLike2) {
            // like button
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.likeButton];
            
            [self.likeButton setFrame:CGRectMake(10.0f, 9.0f, 25.0f, 25.0f)];
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
            
            self.likeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.likeButton.frame.origin.x + self.likeButton.frame.size.width + 5.0f, self.likeButton.frame.origin.y + 5.0f, 10, 15)];
            [self.likeCountLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [self.likeCountLabel setText:@"0"];
            [self.likeCountLabel setTextColor:likeCommentColor];
            
            self.likeTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.likeCountLabel.frame.origin.x + self.likeCountLabel.frame.size.width, self.likeButton.frame.origin.y + 5.0f, 40, 15)];
            [self.likeTitle setText:@" Likes"];
            [self.likeTitle setFont:self.likeCountLabel.font];
            [self.likeTitle setTextColor:likeCommentColor];
            
            [containerView addSubview:self.likeCountLabel];
            [containerView addSubview:self.likeTitle];
            
        }
                
        self.moreActionButton = [[UIButton alloc] initWithFrame:CGRectMake(280.0f, 7.0f, 30.0f, 30.0f)];
        [self.moreActionButton setImage:[UIImage imageNamed:@"button-more.png"] forState:UIControlStateNormal];
        [self.moreActionButton addTarget:self action:@selector(moreActionButton_action:) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:self.moreActionButton];
        
        if (self.buttons & PAPPhotoHeaderButtonsComment2) {
            [self.commentButton addTarget:self action:@selector(didTapCommentOnPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (self.buttons & PAPPhotoHeaderButtonsLike2) {
            [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }

    }

    return self;
}


#pragma mark - PostFooterView

- (void)setPhoto:(PFObject *)aPhoto {
    photo = aPhoto;    
}

- (void)setLikeCount:(NSNumber *)count{
    self.likeCountLabel.text = [count stringValue];
    
    CGSize likeExpectedSize = [self.likeCountLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}];
    
    // Update like count frame to fit new count
    [self.likeCountLabel setFrame:CGRectMake(self.likeButton.frame.origin.x + self.likeButton.frame.size.width + 5.0f, self.likeCountLabel.frame.origin.y, likeExpectedSize.width, 15)];
    
    //[self.likeCountLabel setBackgroundColor:[UIColor redColor]];
    
    // Update like title
    [self.likeTitle setFrame:CGRectMake(self.likeCountLabel.frame.origin.x + likeExpectedSize.width + 1.0f, self.likeTitle.frame.origin.y, 40, 15)];
}

- (void)setCommentCount:(NSNumber *)count{
    
    self.commentCountLabel.text = [count stringValue];
    
    CGSize commentExpectedSize = [self.commentCountLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}];
    
     // Update comment count label frame to fit new count
     [self.commentCountLabel setFrame:CGRectMake(self.commentButton.frame.origin.x + self.commentButton.frame.size.width + 5.0f, self.commentCountLabel.frame.origin.y, commentExpectedSize.width, 15)];
    
    //[self.commentTitle setBackgroundColor:[UIColor redColor]];
    
    // Update comment title
    [self.commentTitle setFrame:CGRectMake(self.commentCountLabel.frame.origin.x + commentExpectedSize.width + 1.0f, self.commentTitle.frame.origin.y, 80, 15)];
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
    if (!enable) {
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
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing PAPpostFooterView2."];
    }
}

- (void)didTapLikePhotoButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(postFooterView:didTapLikePhotoButton:photo:)]) {
        [delegate postFooterView:self didTapLikePhotoButton:button photo:self.photo];
    }
}

- (void)didTapCommentOnPhotoButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(postFooterView:didTapCommentOnPhotoButton:photo:)]) {
        [delegate postFooterView:self didTapCommentOnPhotoButton:sender photo:self.photo];
    }
}

-(void)setFrame:(CGRect)frame{
    self.layer.frame = frame;
}

@end
