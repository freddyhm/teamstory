//
//  PAPBaseTextCell.h
//  Teamstory
//
//

#import "VSWordDetector.h"

@class PAPProfileImageView;
@protocol PAPBaseTextCellDelegate;

@interface PAPBaseTextCell : UITableViewCell <UIActionSheetDelegate, UIAlertViewDelegate, VSWordDetectorDelegate>{
    NSUInteger horizontalTextSpace;
    id _delegate;
}

/*! 
 Unfortunately, objective-c does not allow you to redefine the type of a property,
 so we cannot set the type of the delegate here. Doing so would mean that the subclass
 of would not be able to define new delegate methods (which we do in PAPActivityCell).
 */
@property (nonatomic, strong) id delegate;

/*! The user represented in the cell */
@property (nonatomic, strong) PFUser *user;

/*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *likeCommentButton;
@property (nonatomic, strong) UIButton *likeCommentHeart;
@property (nonatomic, strong) UILabel *likeCommentCount;
@property (nonatomic, strong) UIButton *avatarImageButton;
@property (nonatomic, strong) PAPProfileImageView *avatarImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *separatorImage;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) NSArray *mentionNames;
@property (nonatomic, strong) NSString *cellType;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) PFObject *ih_object;
@property (nonatomic, strong) PFObject *ih_photo;

/*! The horizontal inset of the cell */
@property (nonatomic) CGFloat cellInsetWidth;

/*! Like comment */
- (void)setLikeCommentButtonState:(BOOL)selected forCurrentUser:(BOOL)forCurrentUser;
- (void)shouldEnableLikeCommentButton:(BOOL)enable;
- (void)removeCommentCountHeart;


/*! Setters for the cell's content */
- (void)setContentText:(NSString *)contentString;
- (void)setDate:(NSDate *)date;
- (void)detectWordTaps;

- (void)setCellInsetWidth:(CGFloat)insetWidth;
- (void)hideSeparator:(BOOL)hide;

/*! Static Helper methods */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content;
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset;
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width;

@end

/*! Layout constants */
#define vertBorderSpacing 8.0f
#define vertElemSpacing 0.0f

#define horiBorderSpacing 8.0f
#define horiBorderSpacingBottom 9.0f
#define horiElemSpacing 5.0f

#define vertTextBorderSpacing 10.0f

#define avatarX horiBorderSpacing
#define avatarY vertBorderSpacing
#define avatarDim 33.0f

#define nameX avatarX+avatarDim+horiElemSpacing
#define nameY vertTextBorderSpacing
#define nameMaxWidth 200.0f

#define timeX avatarX+avatarDim+horiElemSpacing

/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol PAPBaseTextCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser cellType:(NSString *)cellType;

/*!
 Sent to the delegate when a like button is tapped
 */
- (void)didTapCommentLikeButton:(PAPBaseTextCell *)cellView;


@end

