//
//  PAPMessagingCell.m
//  Teamstory
//
//  Created by Tobok Lee on 9/9/14.
//
//

#import "PAPMessagingCell.h"

#define messageHorizontalSpacing 60.0f
#define defaultMessageCellHeight 50.0f
#define messageTextSize 16.0f
#define arrowSpacerWidth 20.0f
#define MAXMessageViewWidth 250.0f
#define MAXMessageLabelWidth 215.0f

@implementation PAPMessagingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImage *RECEIVEDTriangleImage = [UIImage imageNamed:@"bubble_triangle_left.png"];
        self.RECEIVEDTriangle = [[UIImageView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, RECEIVEDTriangleImage.size.width, RECEIVEDTriangleImage.size.height)];
        [self.RECEIVEDTriangle setImage:RECEIVEDTriangleImage];
        [self addSubview:self.RECEIVEDTriangle];
        
        UIImage *SENTTriangleImage = [UIImage imageNamed:@"bubble_triangle_right.png"];
        self.SENTTriangle = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 20.0f, 17.0f, SENTTriangleImage.size.width, SENTTriangleImage.size.height)];
        [self.SENTTriangle setImage:SENTTriangleImage];
        [self addSubview:self.SENTTriangle];
        
        self.RECEIVEDMessageView = [[UIView alloc] initWithFrame:CGRectMake(arrowSpacerWidth, 10.0f, MAXMessageViewWidth, 40.0f)];
        self.RECEIVEDMessageView.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:237.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        self.RECEIVEDMessageView.layer.cornerRadius = 5.0f;
        self.RECEIVEDMessageView.clipsToBounds = YES;
        [self addSubview:self.RECEIVEDMessageView];
        
        self.SENTMessageView = [[UIView alloc] initWithFrame:CGRectMake(messageHorizontalSpacing, 10.0f, MAXMessageViewWidth, 40.0f)];
        self.SENTMessageView.backgroundColor = [UIColor colorWithRed:0 green:158.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        self.SENTMessageView.layer.cornerRadius = 5.0f;
        self.SENTMessageView.clipsToBounds = YES;
        [self addSubview:self.SENTMessageView];
        
        self.RECEIVEDMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, self.RECEIVEDMessageView.bounds.size.width - 20.0f, 30.0f)];
        self.RECEIVEDMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:messageTextSize];
        [self.RECEIVEDMessageView addSubview:self.RECEIVEDMessageLabel];
        
        self.SENTMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, self.SENTMessageView.bounds.size.width - 20.0f, 30.0f)];
        self.SENTMessageLabel.textColor = [UIColor whiteColor];
        self.SENTMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:messageTextSize];
        [self.SENTMessageView addSubview:self.SENTMessageLabel];
        
        self.timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 50.0f, 15.0f)];
        [self.timeStampLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
        [self.timeStampLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self addSubview:self.timeStampLabel];
        
    }
    return self;
}

-(void)setType:(NSString *)type {
    self.messageType = type;
}


- (void)setText:(NSString *)text {
    self.RECEIVEDMessageLabel.text = text;
    self.SENTMessageLabel.text = text;
    self.RECEIVEDMessageLabel.numberOfLines = 0;
    self.SENTMessageLabel.numberOfLines = 0;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:messageTextSize]};
    
    CGRect textViewSize = [self.RECEIVEDMessageLabel.text boundingRectWithSize:CGSizeMake(MAXMessageLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    self.RECEIVEDMessageView.frame = CGRectMake(arrowSpacerWidth, 10.0f, textViewSize.size.width + 20.0f, textViewSize.size.height + 10.0f);
    self.SENTMessageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - textViewSize.size.width - 20.0f - arrowSpacerWidth, 10.0f, textViewSize.size.width + 20.0f, textViewSize.size.height + 10.0f);
    
    [self resizeTextView];
    
}

-(void) resizeTextView {
    self.RECEIVEDMessageLabel.frame = CGRectMake(10.0f, 5.0f, self.RECEIVEDMessageView.bounds.size.width - 20.0f, self.RECEIVEDMessageView.bounds.size.height - 10.0f);
    self.SENTMessageLabel.frame = CGRectMake(10.0f, 5.0f, self.SENTMessageView.bounds.size.width - 20.0f, self.SENTMessageView.bounds.size.height - 10.0f);
}

+(CGFloat)heightForCell {
    return defaultMessageCellHeight;
}

@end
