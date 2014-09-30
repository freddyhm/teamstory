//
//  PAPMessagingCell.m
//  Teamstory
//
//  Created by Tobok Lee on 9/9/14.
//
//

#import "PAPMessagingCell.h"

#define messageHorizontalSpacing 60.0f
#define defaultMessageCellHeight 40.0f
#define messageTextSize 16.0f
#define arrowSpacerWidth 20.0f

@implementation PAPMessagingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.RECEIVEDMessageView = [[UIView alloc] initWithFrame:CGRectMake(arrowSpacerWidth, 0.0f, [UIScreen mainScreen].bounds.size.width - messageHorizontalSpacing, 40.0f)];
        self.RECEIVEDMessageView.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:237.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        self.RECEIVEDMessageView.layer.cornerRadius = 5.0f;
        self.RECEIVEDMessageView.clipsToBounds = YES;
        [self addSubview:self.RECEIVEDMessageView];
        
        self.SENTMessageView = [[UIView alloc] initWithFrame:CGRectMake(messageHorizontalSpacing, 0.0f, [UIScreen mainScreen].bounds.size.width - messageHorizontalSpacing - arrowSpacerWidth, 40.0f)];
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
        
        self.timeStampLabel = [[UILabel alloc] init];
        [self.timeStampLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
        [self.timeStampLabel setFont:[UIFont systemFontOfSize:11.0f]];
        self.timeStampLabel.textAlignment = NSTextAlignmentCenter;
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
    
    CGRect textViewSize = [self.RECEIVEDMessageLabel.text boundingRectWithSize:CGSizeMake(self.RECEIVEDMessageLabel.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    self.RECEIVEDMessageView.frame = CGRectMake(arrowSpacerWidth, 0.0f, [UIScreen mainScreen].bounds.size.width - messageHorizontalSpacing - arrowSpacerWidth, textViewSize.size.height + 10.0f);
    self.SENTMessageView.frame = CGRectMake(messageHorizontalSpacing, 0.0f, [UIScreen mainScreen].bounds.size.width - messageHorizontalSpacing - arrowSpacerWidth, textViewSize.size.height + 10.0f);
    
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
