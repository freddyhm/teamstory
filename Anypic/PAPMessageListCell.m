//
//  PAPMessageListCell.m
//  Teamstory
//
//  Created by Tobok Lee on 9/10/14.
//
//

#import "PAPMessageListCell.h"

@implementation PAPMessageListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 80.0f)];
        textView.backgroundColor = [UIColor blueColor];
        [self addSubview:textView];
         
    }
    return self;
}

@end
