//
//  PAPpostFooterView2.h
//  Teamstory
//
//

typedef enum {
    PAPPhotoHeaderButtonsNone2 = 0,
    PAPPhotoHeaderButtonsLike2 = 1 << 0,
    PAPPhotoHeaderButtonsComment2 = 1 << 1,
    PAPPhotoHeaderButtonsUser2 = 1 << 2,
    
    PAPPhotoHeaderButtonsDefault2 = PAPPhotoHeaderButtonsLike2 | PAPPhotoHeaderButtonsComment2 | PAPPhotoHeaderButtonsUser2
} PAPPhotoHeaderButtons2;

@protocol PostFooterViewDelegate;

@interface PostFooterView : UIView

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (id)initWithFrame:(CGRect)frame buttons:(PAPPhotoHeaderButtons2)otherButtons;

/// The photo associated with this view
@property (nonatomic,strong) PFObject *photo;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) PAPPhotoHeaderButtons2 buttons;

/*! @name Accessing Interaction Elements */

/// The Like Photo button
@property (nonatomic,readonly) UIButton *likeButton;

/// The Comment On Photo button
@property (nonatomic,readonly) UIButton *commentButton;

/*! @name Delegate */
@property (nonatomic,weak) id <PostFooterViewDelegate> delegate;

/*! @name Modifying Interaction Elements Status */

/*!
 Configures the Like Button to match the given like status.
 @param liked a BOOL indicating if the associated photo is liked by the user
 */
- (void)setLikeStatus:(BOOL)liked;

/*!
 Enable the like button to start receiving actions.
 @param enable a BOOL indicating if the like button should be enabled.
 */
- (void)shouldEnableLikeButton:(BOOL)enable;

@end


/*!
 The protocol defines methods a delegate of a PostFooterViewDelegate should implement.
 All methods of the protocol are optional.
 */
@protocol PostFooterViewDelegate <NSObject>
@optional


/*!
 Sent to the delegate when the like photo button is tapped
 @param photo the PFObject for the photo that is being liked or disliked
 */
- (void)postFooterView:(PostFooterView *)postFooterView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo;

/*!
 Sent to the delegate when the comment on photo button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
- (void)postFooterView:(PostFooterView *)postFooterView didTapCommentOnPhotoButton:(UIButton *)button photo:(PFObject *)photo;

- (void) moreActionButton_inflator:(PFUser *)user photo:(PFObject *)photo;
@end