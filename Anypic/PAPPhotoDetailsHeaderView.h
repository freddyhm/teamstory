//
//  PAPPhotoDetailsHeaderView.h
//  Teamstory
//
//

@protocol PAPPhotoDetailsHeaderViewDelegate;

@interface PAPPhotoDetailsHeaderView : UIView

/*! @name Managing View Properties */

/// The photo displayed in the view
@property (nonatomic, strong, readonly) PFObject *photo;

/// The user that took the photo
@property (nonatomic, strong, readonly) PFUser *photographer;

/// Array of the users that liked the photo
@property (nonatomic, strong) NSArray *likeUsers;

/// Heart-shaped like button
@property (nonatomic, strong, readonly) UIButton *likeButton;

/*! @name Delegate */
@property (nonatomic, strong) id<PAPPhotoDetailsHeaderViewDelegate> delegate;

+ (CGRect)rectForView;

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto description:(NSString *)adescription navigationController:(UINavigationController *)anavController;
- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers;

- (void)setLikeButtonState:(BOOL)selected;
- (void)reloadLikeBar;

@end

/*!
 The protocol defines methods a delegate of a PAPPhotoDetailsHeaderView should implement.
 */
@protocol PAPPhotoDetailsHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the photograper
 */
- (void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;
- (void) moreActionButton_inflator:(PFUser *)user photo:(PFObject *)photo;
- (void) shareButton:(PFUser *)shareUser setPhoto:(PFObject *)photo;

/*!
 Sent to the delegate when the project link on photo is tapped
 @param post the PFObject for the post associated with this link
 */
- (void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)photoHeaderView didTapProjectLink:(PFObject *)post;

@end