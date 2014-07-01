//
//  PAPPhotoCell.h
//  Teamstory
//
//

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


-(void)setObject:(PFObject*)object;

@end
