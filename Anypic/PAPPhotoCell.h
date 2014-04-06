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
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) NSString *website;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier navigationController:(UINavigationController *)navController;


@end
