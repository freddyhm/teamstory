//
//  PAPFindFriendsCell.m
//  Teamstory
//
//

#import "PAPFindFriendsCell.h"
#import "PAPProfileImageView.h"

@interface PAPFindFriendsCell ()
/*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *avatarImageButton;
@property (nonatomic, strong) PAPProfileImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *separatorImage;
@property (nonatomic, strong) UIImage *followButtonImage;

@end


@implementation PAPFindFriendsCell
@synthesize delegate;
@synthesize user;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize photoLabel;
@synthesize followButton;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Layour separator
        self.separatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SeparatorComments.png"]];
        [self.separatorImage setFrame:CGRectMake(0, self.frame.size.height + 22, self.frame.size.width, 2)];

        [self.contentView addSubview:self.separatorImage];
        
        self.avatarImageView = [[PAPProfileImageView alloc] init];
        [self.avatarImageView setFrame:CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f)];
        
        [self.contentView addSubview:self.avatarImageView];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageButton setFrame:CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f)];
        
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.avatarImageButton];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.nameButton setBackgroundColor:[UIColor clearColor]];
        [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameButton setTitleColor:[UIColor colorWithRed:125.0f/255.0f green:125.0f/255.0f blue:125.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor colorWithRed:125.0f/255.0f green:125.0f/255.0f blue:125.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.nameButton];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.followButtonImage = [UIImage imageNamed:@"btn_no_follow_user.png"];
        
        [self.followButton setImage:self.followButtonImage forState:UIControlStateNormal];
        [self.followButton setImage:[UIImage imageNamed:@"btn_following_user.png"] forState:UIControlStateSelected];
        [self.followButton addTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.followButton];
    }
    return self;
}


#pragma mark - PAPFindFriendsCell

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Configure the cell
    [avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    
    // Set name 
    NSString *nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    

    CGSize nameSize = ([nameString boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f], NSParagraphStyleAttributeName: paragraphStyle.copy} context:nil]).size;

    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateNormal];
    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateHighlighted];

    [nameButton setFrame:CGRectMake( 60.0f, 25.0f, nameSize.width, nameSize.height)];
    
    // Set photo number label

    CGSize photoLabelSize = ([@"photos" boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f], NSParagraphStyleAttributeName: paragraphStyle.copy} context:nil]).size;
    
    [photoLabel setFrame:CGRectMake( 60.0f, 17.0f + nameSize.height, 140.0f, photoLabelSize.height)];
    
    // Set follow button
    [followButton setFrame:CGRectMake( 252.0f, 20.0f, self.followButtonImage.size.width, self.followButtonImage.size.height)];
}

#pragma mark - ()

+ (CGFloat)heightForCell {
    return 67.0f;
}

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }    
}

/* Inform delegate that the follow button was tapped */
- (void)didTapFollowButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapFollowButton:)]) {
        [self.delegate cell:self didTapFollowButton:self.user];
    }        
}

@end
