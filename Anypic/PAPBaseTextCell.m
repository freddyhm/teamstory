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
#import "PAPPhotoDetailsViewController.h"
#import "SVProgressHUD.h"
#import "Mixpanel.h"


#define unlikeButtonDimHeight 15.0f
#define unlikeButtonDimWidth 50.0f
#define likeCounterAndHeartButtonDim 10.0f

enum ActionSheetTags {
    withUrl = 0,
    withOutUrl = 1,
    confirmation = 2
};


static TTTTimeIntervalFormatter *timeFormatter;

@interface PAPBaseTextCell () {
    BOOL hideSeparator; // True if the separator shouldn't be shown
}

@property (nonatomic, strong) UIButton *editButton;
@property (strong, nonatomic) VSWordDetector *wordDetector;
@property (strong, nonatomic) NSDictionary *mentionNamesWithRanges;

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
@synthesize parentView;
@synthesize ih_object;
@synthesize ih_photo;
@synthesize editButton;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        //self.navController = anavController;
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
        
        if ([reuseIdentifier isEqualToString:@"CommentCell"] || [reuseIdentifier isEqualToString:@"CommentCellCurrentUser"]) {
            self.editButton = [[UIButton alloc] init];
            [self.editButton setBackgroundColor:[UIColor clearColor]];
        }
        
        if ([reuseIdentifier isEqualToString:@"atmentionCell"]) {
            [mainView setBackgroundColor:[UIColor colorWithRed:241.0f/255.0f green:242.0f/255.0f blue:246.0f/255.0f alpha:1.0f]];
            [self.nameButton setTitleColor:[UIColor colorWithWhite:0.5f alpha:0.95f] forState:UIControlStateNormal];
            [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
            self.separatorImage.frame = CGRectMake(50.0f, 0.0f, 255.0f, 1.0f);
            
        }else{
            [mainView setBackgroundColor:[UIColor whiteColor]];
        
            [self.nameButton setTitleColor:[UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
            [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentLabel setTextColor:[UIColor colorWithRed:119.0f/255.0f green:119.0f/255.0f blue:119.0f/255.0f alpha:1.0f]];
            self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];

        }
        
        [mainView addSubview:self.editButton];
        
        if ([reuseIdentifier isEqualToString:@"CommentCell"] || [reuseIdentifier isEqualToString:@"CommentCellCurrentUser"]) {
            
            // Create the like button
            self.likeCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
           // self. likeCommentButton.layer.borderColor = [[UIColor blackColor] CGColor];
           // self.likeCommentButton.layer.borderWidth=1.0f;
            [self.likeCommentButton setTitle:@"• Like •" forState:UIControlStateNormal];
            [self.likeCommentButton setTitle:@"• Unlike •" forState:UIControlStateSelected];
            [self.likeCommentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [[self.likeCommentButton titleLabel] setFont:[UIFont systemFontOfSize:10.0f]];
            [self.likeCommentButton addTarget:self action:@selector(didTapLikeCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            // Create the counter heart shape (disabled button)
            self.likeCommentHeart = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.likeCommentHeart setBackgroundColor:[UIColor clearColor]];
            [self.likeCommentHeart setBackgroundImage:[UIImage imageNamed:@"ButtonLikeCommentSelected.png"] forState:UIControlStateSelected];
            [self.likeCommentHeart setBackgroundImage:[UIImage imageNamed:@"ButtonLikeComment.png"] forState:UIControlStateNormal];
            
            // Create the counter label next to heart
            self.likeCommentCount = [[UILabel alloc] init];
            [self.likeCommentCount setFont:[UIFont systemFontOfSize:9.0f]];
            self.likeCommentCount.textColor = [UIColor grayColor];
                        
            // add to mainview 
            [mainView addSubview:self.likeCommentButton];
            [mainView addSubview:self.likeCommentHeart];
            [mainView addSubview:self.likeCommentCount];
        }
        
        [mainView addSubview:self.avatarImageView];
        [mainView addSubview:self.contentLabel];
        [mainView addSubview:self.timeLabel];
        [mainView addSubview:self.nameButton];
        [mainView addSubview:separatorImage];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        [mainView addSubview:self.avatarImageButton];
        
        [self.contentView addSubview:mainView];
        
        self.mentionNames = [[NSArray alloc]init];
    }
    
    return self;
}


#pragma mark - ()

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //[mainView setFrame:CGRectMake(cellInsetWidth, self.contentView.frame.origin.y, 305.0f, self.contentView.frame.size.height)];
    [mainView setFrame:CGRectMake(0.0f, self.contentView.frame.origin.y, 320, self.contentView.frame.size.height)];
    
    // Layout avatar image
    [self.avatarImageView setFrame:CGRectMake(avatarX, avatarY, avatarDim, avatarDim)];
    [self.avatarImageButton setFrame:CGRectMake(avatarX, avatarY, avatarDim, avatarDim)];
    
    NSInteger fontSize = 0;
    NSInteger name_height_origin = 0;
    
    if ([self.cellType isEqualToString:@"atmentionCell"]) {
        fontSize = 15;
        name_height_origin = nameY + 3;
    }else{
        fontSize = 13;
        name_height_origin = nameY;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    // Layout the name button
    CGSize nameSize = ([self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize], NSParagraphStyleAttributeName: paragraphStyle.copy} context:nil]).size;

    if ([self.cellType isEqualToString:@"atmentionCell"]) {
        [self.nameButton setFrame:CGRectMake(nameX, 0.0f, nameMaxWidth, 44.0f)];
        self.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }else {
        [self.nameButton setFrame:CGRectMake(nameX, name_height_origin, nameSize.width, nameSize.height)];
        
        // Layout separator
        [self.separatorImage setFrame:CGRectMake(0, self.frame.size.height-2, self.frame.size.width, 2)];
        [self.separatorImage setHidden:hideSeparator];
    }
    
    // Layout the content
    CGSize maximumLabelSize = CGSizeMake(horizontalTextSpace, 9999.0f);
    CGSize contentSize = [self.contentLabel sizeThatFits:maximumLabelSize];
    self.contentLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.contentLabel setFrame:CGRectMake(nameX, vertTextBorderSpacing, contentSize.width, contentSize.height)];
    self.editButton.frame = CGRectMake(0.0f, 0.0f, mainView.bounds.size.width, mainView.bounds.size.height);
    
    // Layout the timestamp label
    CGSize timeSize = ([self.timeLabel.text boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11], NSParagraphStyleAttributeName: paragraphStyle.copy} context:nil]).size;

    
    
    [self.timeLabel setFrame:CGRectMake(timeX, contentLabel.frame.origin.y + contentLabel.frame.size.height + vertElemSpacing, timeSize.width, timeSize.height)];
    
    if ([self.cellType isEqualToString:@"CommentCell"] || [self.cellType isEqualToString:@"CommentCellCurrentUser"]) {
        // Layout the like button (default)
        self.likeCommentButton.frame = CGRectMake((self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width), self.timeLabel.frame.origin.y, unlikeButtonDimWidth, unlikeButtonDimHeight);
        
        // layout the heart
        self.likeCommentHeart.frame = CGRectMake((self.likeCommentButton.frame.origin.x + self.likeCommentButton.frame.size.width) - 1, timeLabel.frame.origin.y + 2, likeCounterAndHeartButtonDim, likeCounterAndHeartButtonDim);
        
        // layout the counter
        [self.likeCommentCount setFrame:CGRectMake((self.likeCommentHeart.frame.origin.x + self.likeCommentHeart.frame.size.width), timeLabel.frame.origin.y + 2, likeCounterAndHeartButtonDim, likeCounterAndHeartButtonDim)];
        
    }
}

#pragma mark - VSWordDetector Methods & Delegate

- (void)detectWordTaps{
    self.wordDetector = [[VSWordDetector alloc] initWithDelegate:self];
    [self.wordDetector addOnView:self.contentLabel];
}

-(void)wordDetector:(VSWordDetector *)wordDetector detectWord:(NSString *)word
{
    if(![self foundMentionName:word]){
        [self foundURL:word];
    }
}

- (void)foundURL:(NSString *)word{
    
    NSLog(@"%@", word);
    
    // get range for url and mentions
    NSRange urlRange = [word rangeOfString:@"(?i)(http\\S+([^.]($|\\s))?|www\\.\\S+([^.]($|\\s))?|\\w+\\.(com|ca|\\w{2,3})(\\S+[^.]($|\\s))?)" options:NSRegularExpressionSearch];
    
    // check if user matches current user
    BOOL isAuthor = [[[PFUser currentUser] objectId] isEqualToString:[[self.ih_object objectForKey:@"fromUser"] objectId]];
    BOOL selectedWordIsUrl = urlRange.location != NSNotFound;
    
    if(isAuthor && selectedWordIsUrl){
        // edit/delete menu with url option if current user is author of comment
        [self commentInflatorActionWithUrl:word];
    }else if(!isAuthor && selectedWordIsUrl){
        // open url right away if not author
        [self openUrl:word];
    }else if(isAuthor){
        // open edit/delete menu
        [self commentInflatorAction];
    }
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
        [self.likeCommentButton addTarget:self action:@selector(didTapLikeCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeCommentButton removeTarget:self action:@selector(didTapLikeCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/* Static helper to get the height for a cell if it had the given name and content */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [PAPBaseTextCell heightForCellWithName:name contentString:content cellInsetWidth:0];
}

/* Static helper to get the height for a cell if it had the given name, content and horizontal inset */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;

    CGSize nameSize = ([name boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSParagraphStyleAttributeName: paragraphStyle.copy} context:nil]).size;
    
    NSString *paddedString = [PAPBaseTextCell padString:content withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];    
    CGFloat horizontalTextSpace = [PAPBaseTextCell horizontalTextSpaceForInsetWidth:cellInset];
   
    NSMutableParagraphStyle *paragraphStyleWordWrap = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleWordWrap.lineBreakMode = NSLineBreakByWordWrapping;   
    
    CGSize contentSize = ([paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSParagraphStyleAttributeName: paragraphStyleWordWrap.copy} context:nil]).size;
    
    CGFloat singleLineHeight = [@"test" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}].height;
                                
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
    
        if ([paddedString sizeWithAttributes:@{NSFontAttributeName:font}].width >= width) {
            break;
        }
    }
    
    // Add final spaces to be ready for first word
    [paddedString appendString:[NSString stringWithFormat:@" %@",string]];
    return paddedString;
}

- (void)setLikeCommentButtonState:(BOOL)selected forCurrentUser:(BOOL)forCurrentUser{
    
    if(forCurrentUser){
        self.likeCommentHeart.selected = selected;
        self.likeCommentButton.selected = selected;
    }
    
    self.likeCommentHeart.hidden = NO;
    self.likeCommentCount.hidden = NO;
}

- (void)removeCommentCountHeart{
    self.likeCommentHeart.hidden = YES;
    self.likeCommentCount.hidden = YES;
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




- (void)setContentText:(NSString *)contentString {
    // If we have a user we pad the content with spaces to make room for the name
        if (self.user) {
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            
            CGSize nameSize = ([self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSParagraphStyleAttributeName: paragraphStyle.copy} context:nil]).size;
            
            NSString *paddedString = [PAPBaseTextCell padString:contentString withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
         
            NSRange urlRange = [paddedString rangeOfString:@"(?i)(http\\S+([^.]($|\\s))?|www\\.\\S+([^.]($|\\s))?|\\w+\\.(com|ca|\\w{2,3})(\\S+[^.]($|\\s))?)" options:NSRegularExpressionSearch];
            
            if (urlRange.location != NSNotFound) {
                NSString *lowerCaseString = [[paddedString substringWithRange:urlRange] lowercaseString];
                paddedString = [paddedString stringByReplacingCharactersInRange:urlRange withString:lowerCaseString];
            }
            
            NSMutableAttributedString *commentText = [[NSMutableAttributedString alloc] initWithString:paddedString];
            
            [commentText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:86.0f/255.0f green:130.0f/255.0f blue:164.0f/255.0f alpha:1.0f] range:urlRange];
            
            if (urlRange.length > 0) {
                self.website = [paddedString substringWithRange:urlRange];
            }
            
            // add links to mention and change color
            [self addLinkToMentionNames:commentText];
            
            [self.contentLabel setAttributedText:commentText];
            [self.contentLabel setUserInteractionEnabled:YES];
            
        } else { // Otherwise we ignore the padding and we'll add it after we set the user
            [self.contentLabel setText:contentString];
        }
    
    [self setNeedsDisplay];

}

- (void)addLinkToMentionNames:(NSMutableAttributedString *)commentText{
    
    // go through mention array of user objects
    if(self.mentionNames.count > 0){
        
        // initialize range dictionary
        self.mentionNamesWithRanges = [[NSMutableDictionary alloc]init];
        
        for (PFObject *userObject in self.mentionNames) {
            
            // get range for user name in comment
            NSString *formatedDisplayName = [@"@" stringByAppendingString:[userObject objectForKey:@"displayName"]];
            NSRange range = [[commentText string] rangeOfString:formatedDisplayName];
            
            // add location, length, and object to dict, will need to determine if user selected mention
            NSMutableArray *mentionRange = [[NSMutableArray alloc]initWithObjects:@(range.location),@(range.length), userObject, nil];
            [self.mentionNamesWithRanges setValue:mentionRange forKey:[userObject objectForKey:@"displayName"]];
        
            // change color if present
            if(range.location != NSNotFound){
                [commentText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:86.0f/255.0f green:130.0f/255.0f blue:164.0f/255.0f alpha:1.0f] range:range];
            }
        }
    }
}

- (BOOL)foundMentionName:(NSString *)word
{
    NSRange wordRangeInComment = [[self.contentLabel text] rangeOfString:word];
    
    for (id key in self.mentionNamesWithRanges) {
        
        NSMutableArray *mentionRange = [self.mentionNamesWithRanges objectForKey:key];
        
        int startLocation = (int)[[mentionRange objectAtIndex:0] integerValue];
        int length = (int)[[mentionRange objectAtIndex:1] integerValue];
        int endLocation = (startLocation + length) - 1;
        
        if(wordRangeInComment.location == startLocation || (wordRangeInComment.location > startLocation && wordRangeInComment.location < endLocation)){
            [self.delegate cell:self didTapUserButton:[mentionRange objectAtIndex:2] cellType:self.cellType];
            return YES;
        }
    }
    
    return NO;
}

- (void)commentInflatorActionWithUrl:(id)sender {
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Comment Menu" properties:@{}];
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = withUrl;
    [actionSheet addButtonWithTitle:@"Open Url"];
    [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:@"Edit Comment"]];
    [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:@"Delete Comment"]];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    
    if(self.tabBarController){
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }else{
        [actionSheet showInView:self.parentView];
    }
}

- (void)commentInflatorAction{
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Comment Menu" properties:@{}];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = withOutUrl;
    [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:@"Edit Comment"]];
    [actionSheet setDestructiveButtonIndex:[actionSheet addButtonWithTitle:@"Delete Comment"]];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    
    
    if(self.tabBarController){
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }else{
        [actionSheet showInView:self.parentView];
    }
}

- (void)openUrl:(id)sender {
        
    if ([self.website rangeOfString:@"(?i)http" options:NSRegularExpressionSearch].location == NSNotFound) {
        NSString *http = @"http://";
        self.website = [NSString stringWithFormat:@"%@%@", http, self.website];
    }
    
    //self.website = [self.website stringWithFormat:@"%@/%@/%@", ];
    PAPwebviewViewController *webViewController = [[PAPwebviewViewController alloc] initWithWebsite:self.website];
    webViewController.hidesBottomBarWhenPushed = YES;
    
    // get last controller in stack, make sure it's details and dismiss keyboard before pushing webview
    NSArray *controllers = [self.navController childViewControllers];
    id lastController = [controllers objectAtIndex:[controllers count] - 1];

    if([lastController isKindOfClass:[PAPPhotoDetailsViewController class]]){
        PAPPhotoDetailsViewController *detailsController = (PAPPhotoDetailsViewController *)lastController;
        [detailsController dismissKeyboard];
    }
    
    [self.navController pushViewController:webViewController animated:YES];

}


- (void)setDate:(NSDate *)date {
    // Set the label with a human readable time
    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date type:@"comment"]];
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

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == withOutUrl) {
        if(buttonIndex == 0) {
            
            // mixpanel analytics
            [[Mixpanel sharedInstance] track:@"Viewed Comment Menu" properties:@{@"Selected" : @"Edit"}];
            
            //Edit comment button
            NSString *comment = [self.contentLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Edit Comment" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = comment;
            [alertView show];
            
        } else if (buttonIndex == 1) {
            
            // mixpanel analytics
            [[Mixpanel sharedInstance] track:@"Viewed Comment Menu" properties:@{@"Selected" : @"Delete"}];
            
            //Delete comment
            [self shouldDeleteComment];
        }
    } else if (actionSheet.tag == withUrl) {
        if(buttonIndex == 0) {
            //Open Url
            [self openUrl:self];
        } else if (buttonIndex == 1) {
            
            // mixpanel analytics
            [[Mixpanel sharedInstance] track:@"Viewed Comment Menu" properties:@{@"Selected" : @"Edit"}];
            
            //Edit Comment Button
            NSString *comment = [self.contentLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Edit Comment" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = comment;
            [alertView show];
        } else if (buttonIndex == 2) {
            
            // mixpanel analytics
            [[Mixpanel sharedInstance] track:@"Viewed Comment Menu" properties:@{@"Selected" : @"Delete"}];
            
            //Delete comment
            [self shouldDeleteComment];
        }
    }
}

- (void)shouldDeleteComment {
    [SVProgressHUD show];
    // Delete all activites related to this photo
    [self.ih_object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //initially pop view and recreating screen in order to refresh the view.
            [self.navController popViewControllerAnimated:NO];
            
            PAPPhotoDetailsViewController *photoDetailsViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:self.ih_photo source:@"tapPhoto"];
            
            // hides tab bar so we can add custom keyboard
            photoDetailsViewController.hidesBottomBarWhenPushed = YES;
            
            [self.navController pushViewController:photoDetailsViewController animated:NO];
            
        } else {
            NSLog(@"%@", error);
        }
        [SVProgressHUD dismiss];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //Pressed Okay
        [SVProgressHUD show];
        self.ih_object[@"content"] = [alertView textFieldAtIndex:0].text;
        
        [self.ih_object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [SVProgressHUD dismiss];
                
                [self.navController popViewControllerAnimated:NO];
                
                PAPPhotoDetailsViewController *photoDetailsViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:self.ih_photo source:@"tapPhoto"];
                
                // hides tab bar so we can add custom keyboard
                photoDetailsViewController.hidesBottomBarWhenPushed = YES;
                
                [self.navController pushViewController:photoDetailsViewController animated:NO];
            } else {
                NSLog(@"%@", error);
            }
        }];
    }
}


@end
