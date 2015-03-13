//
//  PAPActivityPointCell.m
//  Teamstory
//
//  Created by Tobok Lee on 3/13/15.
//
//

#import "PAPActivityPointCell.h"
#import "PAPPhotoHeaderView.h"

#define photoHeaderViewHeight 44.0f

@implementation PAPActivityPointCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.photoHeaderView = [[PAPPhotoHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, photoHeaderViewHeight) buttons:PAPPhotoHeaderButtonsDefault];
        self.photoHeaderView.delegate = self;
        [self addSubview:self.photoHeaderView];
        
    }
    return self;
}

@end
