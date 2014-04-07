//
//  PAPPhotoCell.m
//  Teamstory
//
//

#import "PAPPhotoCell.h"
#import "PAPUtility.h"
#import "PAPwebviewViewController.h"
#import "PAPPhotoDetailsViewController.h"

@implementation PAPPhotoCell
@synthesize photoButton;
@synthesize captionLabel;
@synthesize caption;
@synthesize backgroundView;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 
    if (self) {
        // Initialization code.
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;

        // removing shadow.
        /*
        UIView *dropshadowView = [[UIView alloc] init];
        dropshadowView.backgroundColor = [UIColor whiteColor];
        dropshadowView.frame = CGRectMake( 7.5f, -44.0f, 305.0f, 322.0f);
        [self.contentView addSubview:dropshadowView];
        
        CALayer *layer = dropshadowView.layer;
        layer.masksToBounds = NO;
        layer.shadowRadius = 3.0f;
        layer.shadowOpacity = 0.5f;
        layer.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        layer.shouldRasterize = YES;
         */
        
        self.backgroundView = [[UIView alloc] init];
        [self.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.backgroundView];
        
        self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.5f, 0.0f, 305.0f, 44.0f)];
        [self.captionLabel setBackgroundColor:[UIColor clearColor]];
        [self.captionLabel setText:self.caption];
        [self.captionLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.captionLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
        [self.contentView addSubview:self.captionLabel];
        
        self.imageView.frame = CGRectMake( 7.5f, 0.0f, 305.0f, 305.0f);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 7.5f, 0.0f, 305.0f, 305.0f);
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
        
        [self.contentView bringSubviewToFront:self.imageView];
        

    }

    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.caption length] > 0) {
        CGSize maximumLabelSize = CGSizeMake(295.0f, 9999.0f);
        CGSize expectedSize = [self.caption sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:maximumLabelSize];
        
        if (expectedSize.height > 46.527f) {
            expectedSize.height = 46.527f;
        }
        
        self.backgroundView.frame = CGRectMake(7.5f, 0.0f, 305.0f, expectedSize.height + 25.0f);
        self.captionLabel.frame = CGRectMake(12.5f, 10.0f, 295.0f, expectedSize.height);
        self.imageView.frame = CGRectMake( 7.5f, expectedSize.height + 25.0f, 305.0f, 305.0f);
        self.photoButton.frame = CGRectMake( 7.5f, 0.0, 305.0f, 330.0f + expectedSize.height);
        
        NSRange range = [self.caption rangeOfString:@"(?i)(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+" options:NSRegularExpressionSearch];
        
        NSMutableAttributedString *captionText = [[NSMutableAttributedString alloc] initWithString:self.caption];
        [captionText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:86.0f/255.0f green:130.0f/255.0f blue:164.0f/255.0f alpha:1.0f] range:range];
        
        [self.captionLabel setBackgroundColor:[UIColor clearColor]];
        [self.captionLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.captionLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
        [self.captionLabel setAttributedText:captionText];
        [self.captionLabel setUserInteractionEnabled:YES];
        self.captionLabel.numberOfLines = 3;
        self.captionLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    } else {
        self.captionLabel.frame = CGRectMake(7.5f, 0.0f, 305.0f, 44.0f);
        self.imageView.frame = CGRectMake( 7.5f, 0.0f, 305.0f, 305.0f);
        self.photoButton.frame = CGRectMake( 7.5f, 0.0f, 305.0f, 305.0f);
    }
}

@end
