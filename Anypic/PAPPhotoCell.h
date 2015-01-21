//
//  PAPPhotoCell.h
//  Teamstory
//
//
#import "PostFooterView.h"

@class PFImageView;
@interface PAPPhotoCell : PFTableViewCell

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


-(void)setObject:(PFObject*)object;

@end
