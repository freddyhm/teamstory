//
//  PAPMessagingCell.m
//  Teamstory
//
//  Created by Tobok Lee on 9/9/14.
//
//

#import "PAPMessagingCell.h"

#define messageHorizontalSpacing 80.0f
#define defaultMessageCellHeight 40.0f

@implementation PAPMessagingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.RECEIVEDMessageView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width - messageHorizontalSpacing, defaultMessageCellHeight)];
        [self addSubview:self.RECEIVEDMessageView];
        
        self.SENTMessageView = [[UIView alloc] initWithFrame:CGRectMake(messageHorizontalSpacing, 0.0f, [UIScreen mainScreen].bounds.size.width - messageHorizontalSpacing, defaultMessageCellHeight)];
        [self addSubview:self.SENTMessageView];
        
        self.RECEIVEDMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, messageHorizontalSpacing - 10.0f, defaultMessageCellHeight)];
        [self.RECEIVEDMessageView addSubview:self.RECEIVEDMessageLabel];
        
        self.SENTMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, messageHorizontalSpacing - 10.0f, defaultMessageCellHeight)];
        [self.SENTMessageView addSubview:self.SENTMessageLabel];
        
    }
    return self;
}

-(void)setType:(NSString *)type {
    self.messageType = type;
}


- (void)setText:(NSString *)text {
    self.RECEIVEDMessageLabel.text = text;
    self.SENTMessageLabel.text = text;
}


- (void)setTime:(NSDate *)date {
    NSLog(@"%@", date);
}

+(CGFloat)heightForCell {
    return defaultMessageCellHeight;
}

@end
