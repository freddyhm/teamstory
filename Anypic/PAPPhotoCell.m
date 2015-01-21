//
//  PAPPhotoCell.m
//  Teamstory
//
//

#import "PAPPhotoCell.h"
#import "PAPUtility.h"
#import "PAPwebviewViewController.h"
#import "PAPPhotoDetailsViewController.h"

#define youtubeFrame 200.0f

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
@synthesize delegate;

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
        
        self.youtubeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, youtubeFrame)];
        self.youtubeWebView.scrollView.scrollEnabled = NO;
        self.youtubeWebView.scrollView.bounces = NO;
        [self.contentView addSubview:self.youtubeWebView];
        
        self.backgroundView = [[UIView alloc] init];
        [self.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.backgroundView];
        
        self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.5f, 0.0f, 310.0f, 44.0f)];
        [self.captionLabel setBackgroundColor:[UIColor clearColor]];
        [self.captionLabel setText:self.caption];
        [self.captionLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.captionLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
        [self.contentView addSubview:self.captionLabel];
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"]; //first pic
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 7.5f, 0.0f, 320.0f, 320.0f);
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
        
        self.captionButton = [[UIButton alloc] init];
        [self.captionButton setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.captionButton];
        
        
        self.footerView = [[PostFooterView alloc] initWithFrame:CGRectMake(0.0f, self.imageView.frame.origin.y + self.imageView.frame.size.height, self.bounds.size.width, 44.0f) buttons:PAPPhotoHeaderButtonsDefault2];
        [self.contentView addSubview:self.footerView];
    }
    
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView sendSubviewToBack:self.youtubeWebView];
    
    if ([self.caption length] > 0) {
        CGSize maximumLabelSize = CGSizeMake(295.0f, 9999.0f);
        
        CGSize expectedSize = ([self.caption boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil]).size;
        
        if (expectedSize.height > 46.527f) {
            expectedSize.height = 46.527f;
        }
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f , 320.0f, 320.0f);
        self.captionLabel.frame = CGRectMake(12.0f, self.imageView.frame.size.height + 15.0f, 295.0f, expectedSize.height + 15.0f);
        
        self.captionButton.frame = self.captionLabel.frame;
        
        self.photoButton.frame = CGRectMake( 7.5f, notificationBarOffSet, 320.0f, self.imageView.frame.size.height);
        self.backgroundView.frame = CGRectMake(0.0f, 0.0f, 320.0f, self.imageView.frame.size.height + self.captionLabel.frame.size.height + 20.0f);
        
        NSRange range = [self.caption rangeOfString:@"(?i)(http\\S+|www\\.\\S+|\\w+\\.(com|ca|\\w{2,3})(\\S+)?)" options:NSRegularExpressionSearch];
        
        if (range.location != NSNotFound) {
            NSString *lowerCaseString = [[self.caption substringWithRange:range] lowercaseString];
            self.caption = [self.caption stringByReplacingCharactersInRange:range withString:lowerCaseString];
        }
        
        if ([[self.ih_object objectForKey:@"type"] isEqualToString:@"link"] && ([[self.ih_object objectForKey:@"link"] rangeOfString:@"youtube.com"].location != NSNotFound || [[self.ih_object objectForKey:@"link"] rangeOfString:@"youtu.be"].location != NSNotFound)) {
            // When post is a youtube link
            [self.imageView removeFromSuperview];
            [self.photoButton removeFromSuperview];
            
            [self.youtubeWebView loadHTMLString:[self setiFrameURLforYouTube:[self.ih_object objectForKey:@"link"]] baseURL:[[NSURL alloc] initWithString:[self.ih_object objectForKey:@"link"]]];
            self.captionLabel.frame = CGRectMake(12.0f, youtubeFrame + 10.0f, 295.0f, expectedSize.height + 15.0f);
            self.backgroundView.frame = CGRectMake(0.0f, 0.0f, 320.0f, youtubeFrame + self.captionLabel.frame.size.height + 20.0f);
        } else {
            [self.youtubeWebView removeFromSuperview];
            [self.contentView bringSubviewToFront:self.imageView];
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
        
        [self.footerView setFrame:CGRectMake(0.0f, self.captionLabel.frame.origin.y + self.captionLabel.frame.size.height, self.bounds.size.width, 44.0f)];
        self.captionButton.frame = self.captionLabel.frame;
        
    } else {
        [self.captionButton removeFromSuperview];
        
        self.captionLabel.text = @"";
        self.captionLabel.frame = CGRectMake(12.5f, 0.0f, 295.0f, 44.0f);
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.photoButton.frame = CGRectMake( 7.5f, 0.0f, 320.0f, 320.0f);
        
        if ([[self.ih_object objectForKey:@"type"] isEqualToString:@"link"] && ([[self.ih_object objectForKey:@"link"] rangeOfString:@"youtube.com"].location != NSNotFound || [[self.ih_object objectForKey:@"link"] rangeOfString:@"youtu.be"].location != NSNotFound)) {
            // When post is a youtube link
            [self.imageView removeFromSuperview];
            [self.photoButton removeFromSuperview];
            
            self.backgroundView.frame = CGRectMake(0.0f, 0.0f, 320.0f, self.youtubeWebView.frame.size.height + 10.0f);
            [self.youtubeWebView loadHTMLString:[self setiFrameURLforYouTube:[self.ih_object objectForKey:@"link"]] baseURL:[[NSURL alloc] initWithString:[self.ih_object objectForKey:@"link"]]];
            [self.footerView setFrame:CGRectMake(0.0f, 205.0f, self.bounds.size.width, 44.0f)];
            
            [self.footerView setFrame:CGRectMake(0.0f, 205.0f, self.bounds.size.width, 44.0f)];;
        } else {
            [self.footerView setFrame:CGRectMake(0.0f, self.imageView.frame.origin.y + self.imageView.frame.size.height, self.bounds.size.width, 44.0f)];
            self.backgroundView.frame = CGRectMake(0.0f, 0.0f, 320.0f, self.imageView.frame.size.height + 10.0f);
            [self.youtubeWebView removeFromSuperview];
            [self.contentView bringSubviewToFront:self.imageView];
        }
    }
    
    [self.contentView bringSubviewToFront:self.footerView];
    
    if ([[self.ih_object objectForKey:@"type"] isEqualToString:@"link"]) {
        if ([[self.ih_object objectForKey:@"link"] rangeOfString:@"youtube.com"].location != NSNotFound || [[self.ih_object objectForKey:@"link"] rangeOfString:@"youtu.be"].location != NSNotFound) {
            [self.contentView bringSubviewToFront:self.youtubeWebView];
        }
    }
}

-(NSString *)setiFrameURLforYouTube:(NSString *)url {
    NSError *error = NULL;
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:@".*\\.be\\/([^&]+)|.*v=([^&]+)"
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSRange group1;
    NSRange group2;
    
    NSArray* matches = [regex matchesInString:url options:0 range:NSMakeRange(0, [url length])];
    for (NSTextCheckingResult* match in matches) {
        group1 = [match rangeAtIndex:1];
        group2 = [match rangeAtIndex:2];
    }
    NSString *substringForFirstMatch;
    if (group1.location != NSNotFound) {
        // group 1 match
        substringForFirstMatch = [url substringWithRange:group1];
    } else {
        // group 2 match
        substringForFirstMatch = [url substringWithRange:group2];
    }
    
    NSString *modifiedString = [NSString stringWithFormat:@"<iframe width='305' height='200' src='//www.youtube.com/embed/%@' frameborder='0' allowfullscreen></iframe>", substringForFirstMatch];
    return modifiedString;
}

#pragma mark - ()
-(void)setObject:(PFObject*)object {
    self.ih_object = object;
}

- (void)prepareForReuse
{
    
    [super prepareForReuse];
    
    self.ih_image = nil;
    self.ih_object = nil;
    self.imageView.file = nil;
    self.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"]; //initial state for all except first
}


@end
