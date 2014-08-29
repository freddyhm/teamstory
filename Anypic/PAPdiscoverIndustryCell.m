//
//  PAPdiscoverIndustryCellTableViewCell.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-08-28.
//
//

#import "PAPdiscoverIndustryCell.h"

@interface PAPdiscoverIndustryCell ()

@end

@implementation PAPdiscoverIndustryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 44.0f)];
        self.cellButton.backgroundColor = [UIColor clearColor];
        [self.cellButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.cellButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.cellButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        [self addSubview:self.cellButton];
    }
    return self;
}

@end
