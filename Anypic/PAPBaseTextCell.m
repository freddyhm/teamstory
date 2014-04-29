//
//  PAPBaseTextCell.m
//  Teamstory
//
//

#import "PAPBaseTextCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPProfileImageView.h"
#import "PAPUtility.h"
#import "PAPwebviewViewController.h"

#define likeButtonDim 28.0f

static TTTTimeIntervalFormatter *timeFormatter;

@interface PAPBaseTextCell () {
    BOOL hideSeparator; // True if the separator shouldn't be shown
}

/* Private static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;
@end

@implementation PAPBaseTextCell

@synthesize mainView;
@synthesize cellInsetWidth;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize contentLabel;
@synthesize timeLabel;
@synthesize separatorImage;
@synthesize delegate;
@synthesize user;
@synthesize website;
@synthesize navController;
@synthesize cellType;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier navigationController:(UINavigationController *) anavController
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        self.navController = anavController;
        self.cellType = reuseIdentifier;
        
        cellInsetWidth = 0.0f;
        hideSeparator = NO;
        self.clipsToBounds = YES;
        horizontalTextSpace =  [PAPBaseTextCell horizontalTextSpaceForInsetWidth:cellInsetWidth];
        
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        
        self.avatarImageView = [[PAPProfileImageView alloc] init];
        [self.avatarImageView setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageView setOpaque:YES];
        
        self.contentLabel = [[UILabel alloc] init];
        [self.contentLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.contentLabel setNumberOfLines:0];
        [self.contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.contentLabel setBackgroundColor:[UIColor clearColor]];
        
        self.timeLabel = [[UILabel alloc] init];
        [self.timeLabel setFont:[UIFont systemFontOfSize:11]];
        [self.timeLabel setTextColor:[UIColor grayColor]];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.nameButton setBackgroundColor:[UIColor clearColor]];
        
        
        // Create the like button
        self.likeCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.likeCommentButton setTitle:@"Like" forState:UIControlStateNormal];
        [self.likeCommentButton setTitle:@"Unlike" forState:UIControlStateSelected];
        [self.likeCommentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.likeCommentButton setTitleEdgeInsets:UIEdgeInsetsMake(50.0f, 0.0f, 50.0f, 0.0f)];
        [[self.likeCommentButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [[self.likeCommentButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
        [self.likeCommentButton addTarget:self action:@selector(didTapLikeCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Create the counter heart shape (disabled button)
        self.likeCommentCounter = [UIButton buttonWithType:UIButtonTypeCustom];

        [self.likeCommentCounter setBackgroundColor:[UIColor clearColor]];
     //   [self.likeCounter setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
     //   [self.likeCounter setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
       // [self.likeCounter setTitleEdgeInsets:UIEdgeInsetsMake(50.0f, 0.0f, 50.0f, 0.0f)];
   //     [[self.likeCounter titleLabel] setFont:[UIFont systemFontOfSize:9.0f]];
        
     //   [[self.likeCounter titleLabel] setAdjustsFontSizeToFitWidth:YES];
     //   [self.likeCounter setAdjustsImageWhenDisabled:NO];
      //  [self.likeCounter setAdjustsImageWhenHighlighted:NO];
        [self.likeCommentCounter setBackgroundImage:[UIImage imageNamed:@"ButtonLikeComment.png"] forState:UIControlStateNormal];
        [self.likeCommentCounter setBackgroundImage:[UIImage imageNamed:@"ButtonLikeCommentSelected.png"] forState:UIControlStateSelected];
        
        if ([reuseIdentifier isEqualToString:@"atmentionCell"]) {
            [mainView setBackgroundColor:[UIColor colorWithRed:241.0f/255.0f green:242.0f/255.0f blue:246.0f/255.0f alpha:1.0f]];
            [self.nameButton setTitleColor:[UIColor colorWithWhite:0.5f alpha:0.95f] forState:UIControlStateNormal];
            [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
            self.separatorImage.frame = CGRectMake(50.0f, 0.0f, 255.0f, 1.0f);
        } else {
            [mainView setBackgroundColor:[UIColor whiteColor]];
        
            [self.nameButton setTitleColor:[UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
            [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentLabel setTextColor:[UIColor colorWithRed:119.0f/255.0f green:119.0f/255.0f blue:119.0f/255.0f alpha:1.0f]];
            self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];

        }
        
        [mainView addSubview:self.avatarImageView];
        [mainView addSubview:self.nameButton];
        [mainView addSubview:self.contentLabel];
        [mainView addSubview:self.timeLabel];
        [mainView addSubview:self.likeCommentButton];
        [mainView addSubview:self.likeCommentCounter];
        [mainView addSubview:separatorImage];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        [mainView addSubview:self.avatarImageButton];
        

        
        [self.contentView addSubview:mainView];
    }
    
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //[mainView setFrame:CGRectMake(cellInsetWidth, self.contentView.frame.origin.y, 305.0f, self.contentView.frame.size.height)];
    [mainView setFrame:CGRectMake(cellInsetWidth, self.contentView.frame.origin.y, self.contentView.frame.size.width-2*cellInsetWidth, self.contentView.frame.size.height)];
    
    // Layout avatar image
    [self.avatarImageView setFrame:CGRectMake(avatarX, avatarY, avatarDim, avatarDim)];
    [self.avatarImageButton setFrame:CGRectMake(avatarX, avatarY, avatarDim, avatarDim)];
    
    NSInteger fontSize = 0;
    NSInteger name_height_origin = 0;
    
    if ([self.cellType isEqualToString:@"atmentionCell"]) {
        fontSize = 15;
        name_height_origin = nameY + 3;
    } else {
        fontSize = 13;
        name_height_origin = nameY;
    }
    // Layout the name button
    CGSize nameSize = [self.nameButton.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:fontSize] forWidth:nameMaxWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    if ([self.cellType isEqualToString:@"atmentionCell"]) {
        [self.nameButton setFrame:CGRectMake(nameX, 0.0f, nameMaxWidth, 44.0f)];
        self.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    } else {
        [self.nameButton setFrame:CGRectMake(nameX, name_height_origin, nameSize.width, nameSize.height)];
        
        // Layour separator
        [self.separatorImage setFrame:CGRectMake(0, self.frame.size.height-2, self.frame.size.width-cellInsetWidth*2, 2)];
        [self.separatorImage setHidden:hideSeparator];
    }
    
    // Layout the content
    CGSize maximumLabelSize = CGSizeMake(horizontalTextSpace, 9999.0f);
    CGSize contentSize = [self.contentLabel sizeThatFits:maximumLabelSize];
    self.contentLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.contentLabel setFrame:CGRectMake(nameX, vertTextBorderSpacing, contentSize.width, contentSize.height)];
    
    // Layout the timestamp label
    CGSize timeSize = [self.timeLabel.text sizeWithFont:[UIFont systemFontOfSize:11] forWidth:horizontalTextSpace lineBreakMode:NSLineBreakByTruncatingTail];
    [self.timeLabel setFrame:CGRectMake(timeX, contentLabel.frame.origin.y + contentLabel.frame.size.height + vertElemSpacing, timeSize.width, timeSize.height)];
    
    // Layout the like button label
    
    [self.likeCommentButton setFrame:CGRectMake((self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width), self.timeLabel.frame.origin.y, likeButtonDim, likeButtonDim)];

    [self.likeCommentCounter setFrame:CGRectMake((self.likeCommentButton.frame.origin.x + self.likeCommentButton.frame.size.width), timeLabel.frame.origin.y, likeButtonDim, likeButtonDim)];
    
    
}


#pragma mark - Delegate methods

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:cellType:)]) {
        [self.delegate cell:self didTapUserButton:self.user cellType:self.cellType];
    }    
}

/* Inform delegate that a like for a comment has been tapped */
- (void)didTapLikeCommentButtonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapCommentLikeButton:)]) {
        [self.delegate didTapCommentLikeButton:self];
    }
}

#pragma mark - PAPBaseTextCell

- (void)shouldEnableLikeCommentButton:(BOOL)enable{
    
    if (enable) {
        [self.likeCommentButton removeTarget:self action:@selector(didTapLikeCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeCommentButton addTarget:self action:@selector(didTapLikeCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/* Static helper to get the height for a cell if it had the given name and content */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [PAPBaseTextCell heightForCellWithName:name contentString:content cellInsetWidth:0];
}

/* Static helper to get the height for a cell if it had the given name, content and horizontal inset */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name sizeWithFont:[UIFont boldSystemFontOfSize:13] forWidth:nameMaxWidth lineBreakMode:NSLineBreakByTruncatingTail];
    
    NSString *paddedString = [PAPBaseTextCell padString:content withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];    
    CGFloat horizontalTextSpace = [PAPBaseTextCell horizontalTextSpaceForInsetWidth:cellInset];
   
    CGSize contentSize = [paddedString sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat singleLineHeight = [@"test" sizeWithFont:[UIFont systemFontOfSize:13.0f]].height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = (contentSize.height - singleLineHeight) > 0 ? (contentSize.height - singleLineHeight) : 0;
    
    return horiBorderSpacing + avatarDim + horiBorderSpacingBottom + multilineHeightAddition;
}

/* Static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return (320-(insetWidth*2)) - (horiBorderSpacing+avatarDim+horiElemSpacing+horiBorderSpacing);
}

/* Static helper to pad a string with spaces to a given beginning offset */
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width {
    // Find number of spaces to pad
    NSMutableString *paddedString = [[NSMutableString alloc] init];
    while (true) {
        [paddedString appendString:@" "];
        if ([paddedString sizeWithFont:font].width >= width) {
            break;
        }
    }
    
    // Add final spaces to be ready for first word
    [paddedString appendString:[NSString stringWithFormat:@" %@",string]];
    return paddedString;
}

- (void)setLikeCommentButtonState:(BOOL)selected {
    
    if (selected) {
        [self.likeCommentButton setTitleEdgeInsets:UIEdgeInsetsMake(1.0f, 0.5f, -1.0f, -0.5f)];
    }
    [self.likeCommentCounter setSelected:selected];
    [self.likeCommentButton setSelected:selected];
}

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Set name button properties and avatar image
    [self.avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    [self.nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateNormal];
    [self.nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }
    [self setNeedsDisplay];
}

- (void)atMentionedUsers:(NSArray *)userArray {
    /*
    if ([userArray count] > 0) {
        NSLog(@"%@", [[userArray objectAtIndex:0] objectId]);
    }*/
}

- (void)setContentText:(NSString *)contentString {
    // If we have a user we pad the content with spaces to make room for the name
        if (self.user) {
            CGSize nameSize = [self.nameButton.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13] forWidth:nameMaxWidth lineBreakMode:NSLineBreakByTruncatingTail];
            NSString *paddedString = [PAPBaseTextCell padString:contentString withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
            NSRange range = [paddedString rangeOfString:@"(?i)(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+" options:NSRegularExpressionSearch];
            
            NSMutableAttributedString *commentText = [[NSMutableAttributedString alloc] initWithString:paddedString];
            [commentText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:86.0f/255.0f green:130.0f/255.0f blue:164.0f/255.0f alpha:1.0f] range:range];
            
            if (range.length > 0) {
                self.website = [paddedString substringWithRange:range];
            }

            [self.contentLabel setAttributedText:commentText];
            [self.contentLabel setUserInteractionEnabled:YES];
            
            if (range.length > 0) {
                UITapGestureRecognizer *gestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUrl:)];
                gestureRec.numberOfTouchesRequired = 1;
                gestureRec.numberOfTapsRequired = 1;
                [self.contentLabel addGestureRecognizer:gestureRec];
            }
        } else { // Otherwise we ignore the padding and we'll add it after we set the user
            [self.contentLabel setText:contentString];
        }
    
    [self setNeedsDisplay];

}

- (void)openUrl:(id)sender {
    if ([self.website rangeOfString:@"(?i)http" options:NSRegularExpressionSearch].location == NSNotFound) {
        NSString *http = @"http://";
        self.website = [NSString stringWithFormat:@"%@%@", http, self.website];
    }
    
    NSLog(@"%@", self.website);
    //self.website = [self.website stringWithFormat:@"%@/%@/%@", ];
    PAPwebviewViewController *webViewController = [[PAPwebviewViewController alloc] initWithWebsite:self.website];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:webViewController animated:YES];

}


- (void)setDate:(NSDate *)date {
    // Set the label with a human readable time
    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date]];
    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    // Change the mainView's frame to be insetted by insetWidth and update the content text space
    cellInsetWidth = insetWidth;
    [mainView setFrame:CGRectMake(insetWidth, mainView.frame.origin.y, mainView.frame.size.width-2*insetWidth, mainView.frame.size.height)];
    horizontalTextSpace = [PAPBaseTextCell horizontalTextSpaceForInsetWidth:insetWidth];
    [self setNeedsDisplay];
}

/* Since we remove the compile-time check for the delegate conforming to the protocol
 in order to allow inheritance, we add run-time checks. */
- (id<PAPBaseTextCellDelegate>)delegate {
    return (id<PAPBaseTextCellDelegate>)delegate;
}

- (void)setDelegate:(id<PAPBaseTextCellDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}

- (void)hideSeparator:(BOOL)hide {
    hideSeparator = hide;
}

@end
