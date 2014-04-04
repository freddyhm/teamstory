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


@end
