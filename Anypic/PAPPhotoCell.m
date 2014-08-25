//
//  PAPPhotoCell.m
//  Teamstory
//
//

#import "PAPPhotoCell.h"
#import "PAPUtility.h"
#import "PAPwebviewViewController.h"
#import "PAPPhotoDetailsViewController.h"


@interface PAPPhotoCell () {
    float notificationBarOffSet;
}

@end
@implementation PAPPhotoCell
@synthesize photoButton;
@synthesize captionLabel;
@synthesize caption;
@synthesize backgroundView;
@synthesize linkTitleLabel;
@synthesize linkUrlLabel;
@synthesize linkDescription;

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
        
        self.linkBackgroundView = [[UIView alloc] init];
        [self.contentView addSubview:self.linkBackgroundView];
        
        self.linkBackgroundView_gray = [[UIView alloc] init];
        [self.contentView addSubview:self.linkBackgroundView_gray];
        
        self.linkTitleLabel = [[UILabel alloc] init];
        self.linkTitleLabel.numberOfLines = 2;
        self.linkTitleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [self.linkTitleLabel setTextColor:[UIColor colorWithWhite:0.3f alpha:1.0]];
        [self.contentView addSubview:self.linkTitleLabel];
        
        self.linkDescription = [[UILabel alloc] init];
        self.linkDescription.numberOfLines = 2;
        self.linkDescription.font = [UIFont systemFontOfSize:12.0f];
        [self.linkDescription setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0]];
        [self.contentView addSubview:self.linkDescription];
        
        self.linkUrlLabel = [[UILabel alloc] init];
        self.linkUrlLabel.numberOfLines = 1;
        self.linkUrlLabel.font = [UIFont systemFontOfSize:11.0f];
        [self.linkUrlLabel setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0]];
        [self.contentView addSubview:self.linkUrlLabel];
    
        self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.5f, 0.0f, 310.0f, 44.0f)];
        [self.captionLabel setBackgroundColor:[UIColor clearColor]];
        [self.captionLabel setText:self.caption];
        [self.captionLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.captionLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
        [self.contentView addSubview:self.captionLabel];
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 7.5f, 0.0f, 320.0f, 320.0f);
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];

        
        self.footerView = [[PostFooterView alloc] initWithFrame:CGRectMake(0.0f, self.imageView.frame.origin.y + self.imageView.frame.size.height, self.bounds.size.width, 44.0f) buttons:PAPPhotoHeaderButtonsDefault2];
        [self.contentView addSubview:self.footerView];
    }

    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.caption length] > 0) {
        CGSize maximumLabelSize = CGSizeMake(295.0f, 9999.0f);

        CGSize expectedSize = ([self.caption boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil]).size;
        
        if (expectedSize.height > 46.527f) {
            expectedSize.height = 46.527f;
        }
        
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f , 320.0f, 320.0f);
        self.captionLabel.frame = CGRectMake(12.0f, self.imageView.frame.size.height + 20.0f, 295.0f, expectedSize.height);
        
        self.photoButton.frame = CGRectMake( 7.5f, notificationBarOffSet, 320.0f, 330.0f + expectedSize.height);
        
        
        self.backgroundView.frame = CGRectMake(0.0f, 0.0f, 320.0f, self.imageView.frame.size.height + self.captionLabel.frame.size.height + 20.0f);
        
        NSRange range = [self.caption rangeOfString:@"(?i)(http\\S+|www\\.\\S+|\\w+\\.(com|ca|\\w{2,3})(\\S+)?)" options:NSRegularExpressionSearch];
        
        if (range.location != NSNotFound) {
            NSString *lowerCaseString = [[self.caption substringWithRange:range] lowercaseString];
            self.caption = [self.caption stringByReplacingCharactersInRange:range withString:lowerCaseString];
        }
        
        
        NSMutableAttributedString *captionText = [[NSMutableAttributedString alloc] initWithString:self.caption];
        [captionText addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:86.0f/255.0f green:130.0f/255.0f blue:164.0f/255.0f alpha:1.0f] range:range];
        
        [self.captionLabel setBackgroundColor:[UIColor clearColor]];
        [self.captionLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.captionLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
        [self.captionLabel setAttributedText:captionText];
        [self.captionLabel setUserInteractionEnabled:YES];
        self.captionLabel.numberOfLines = 3;
        self.captionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        //handling cases of link post
        if ([[self.ih_object objectForKey:@"type"] isEqualToString:@"link"]) {
            [self.linkBackgroundView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f)];
            [self.linkBackgroundView setBackgroundColor:[UIColor whiteColor]];
            [self.contentView addSubview:self.linkBackgroundView];
            [self.contentView sendSubviewToBack:self.linkBackgroundView];
            
            
            [self.linkBackgroundView_gray setFrame:CGRectMake(5.0f, 5.0f , 311.0f, 90.0f)];
            [self.linkBackgroundView_gray setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
            [self.contentView addSubview:self.linkBackgroundView_gray];
            
            [self.linkTitleLabel setFrame:CGRectMake(105.0f,0.0f, 190.0f, 40.0f)];
            self.linkTitleLabel.text = [self.ih_object objectForKey:@"linkTitle"];
            self.linkTitleLabel.numberOfLines = 2;
            
            self.imageView.frame = CGRectMake( 10.5f, 10.0f, 80.0f, 80.0f);
            self.captionLabel.frame = CGRectMake(12.5f, self.imageView.frame.size.height + 25.0f, 295.0f, expectedSize.height);
            self.photoButton.frame = CGRectMake( 7.5f, 0.0f, 320.0f, 25.0f + expectedSize.height + 100.0f);
            self.backgroundView.frame = CGRectMake(0.0f, 0.0f, 320.0f, self.imageView.frame.size.height + self.captionLabel.frame.size.height + 45.0f);
    
            [self.linkTitleLabel setFrame:CGRectMake(99.0f, 10.0f, 190.0f, 30.0f)];
            self.linkTitleLabel.text = [self.ih_object objectForKey:@"linkTitle"];
            
            [self.linkDescription setFrame:CGRectMake(99.0f, 40.0f, 190.0f, 30.0f)];
            self.linkDescription.text = [self.ih_object objectForKey:@"linkDesc"];
            
            [self.linkUrlLabel setFrame:CGRectMake(99.0f, 70.0f, 190.0f, 15.0f)];
            self.linkUrlLabel.text = [self.ih_object objectForKey:@"link"];
            
            [self.contentView bringSubviewToFront:self.linkUrlLabel];
            [self.contentView bringSubviewToFront:self.linkTitleLabel];
            [self.contentView bringSubviewToFront:self.linkDescription];
            [self.contentView bringSubviewToFront:self.imageView];
            [self.contentView bringSubviewToFront:self.photoButton];
        }
        
        [self.footerView setFrame:CGRectMake(0.0f, self.captionLabel.frame.origin.y + self.captionLabel.frame.size.height, self.bounds.size.width, 44.0f)];

    } else {
    
        self.captionLabel.text = @"";
        self.captionLabel.frame = CGRectMake(12.5f, 0.0f, 295.0f, 44.0f);
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.photoButton.frame = CGRectMake( 7.5f, 0.0f, 320.0f, 320.0f);
        
        [self.footerView setFrame:CGRectMake(0.0f, self.imageView.frame.origin.y + self.imageView.frame.size.height, self.bounds.size.width, 44.0f)];
        
        self.backgroundView.frame = CGRectMake(0.0f, 0.0f, 320.0f, self.imageView.frame.size.height + 10.0f);

        if ([[self.ih_object objectForKey:@"type"] isEqualToString:@"link"]) {
            
            [self.linkBackgroundView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f)];
            [self.linkBackgroundView setBackgroundColor:[UIColor whiteColor]];
            [self.contentView addSubview:self.linkBackgroundView];
            [self.contentView sendSubviewToBack:self.linkBackgroundView];
            
            [self.linkBackgroundView_gray setFrame:CGRectMake(5.0f, 5.0f , 311.0f, 90.0f)];
            [self.linkBackgroundView_gray setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
            self.linkBackgroundView_gray.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
            self.linkBackgroundView_gray.layer.borderWidth = 0.5f;
            [self.contentView addSubview:self.linkBackgroundView_gray];
            
            [self.linkTitleLabel setFrame:CGRectMake(99.0f, 10.0f , 190.0f, 30.0f)];
            self.linkTitleLabel.text = [self.ih_object objectForKey:@"linkTitle"];
            
            [self.linkDescription setFrame:CGRectMake(99.0f, 40.0f , 190.0f, 30.0f)];
            self.linkDescription.text = [self.ih_object objectForKey:@"linkDesc"];
            
            [self.linkUrlLabel setFrame:CGRectMake(99.0f, 70.0f , 190.0f, 15.0f)];
            self.linkUrlLabel.text = [self.ih_object objectForKey:@"link"];
            
        
            self.photoButton.frame = CGRectMake( 7.5f, 0.0f, 320.0f, 100.0f);
            self.imageView.frame = CGRectMake( 10.5f, 10.0f , 80.0f, 80.0f);
            
            [self.footerView setFrame:CGRectMake(0.0f, self.linkBackgroundView_gray.frame.origin.y + self.linkBackgroundView_gray.frame.size.height, self.bounds.size.width, 44.0f)];
        
            [self.contentView bringSubviewToFront:self.linkUrlLabel];
            [self.contentView bringSubviewToFront:self.linkTitleLabel];
            [self.contentView bringSubviewToFront:self.linkDescription];
            [self.contentView bringSubviewToFront:self.imageView];
            [self.contentView bringSubviewToFront:self.photoButton];
            
            self.backgroundView.frame = CGRectMake(0.0f, 0.0f, 320.0f, self.linkBackgroundView.frame.size.height + 10.0f);
        }
    }
    
    [self.contentView bringSubviewToFront:self.imageView];
    [self.contentView bringSubviewToFront:self.footerView];
}

#pragma mark - ()
-(void)setObject:(PFObject*)object {
    self.ih_object = object;
}

- (void)prepareForReuse
{
    self.imageView.image = nil;
    self.ih_image = nil;
    self.ih_object = nil;
}


@end
