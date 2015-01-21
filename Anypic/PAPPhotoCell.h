//
//  PAPPhotoCell.h
//  Teamstory
//
//
#import "PostFooterView.h"

@protocol PAPPhotoCellDelegate;

@class PFImageView;
@interface PAPPhotoCell : PFTableViewCell <UIWebViewDelegate>

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) PFObject *ih_object;
@property (nonatomic, strong) UIImage *ih_image;
@property (nonatomic, strong) UIView *linkBackgroundView;
@property (nonatomic, strong) UIView *linkBackgroundView_gray;
@property (nonatomic, strong) UILabel *linkTitleLabel;
@property (nonatomic, strong) UILabel *linkUrlLabel;
@property (nonatomic, strong) UILabel *linkDescription;
@property (nonatomic, strong) PostFooterView *footerView;
@property (nonatomic, strong) UIWebView *youtubeWebView;
@property (nonatomic, strong) UIButton *captionButton;
@property (nonatomic, strong) UIImageView *youtubePlaceHolderView;

/*! @name Delegate */
@property (nonatomic,weak) id <PAPPhotoCellDelegate> delegate;


-(void)setObject:(PFObject*)object;

@end

@protocol PAPPhotoCellDelegate <NSObject>
@optional



@end
