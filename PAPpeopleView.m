//
//  PAPpeopleView.m
//  Anypic
//
//  Created by Tobok Lee on 1/16/14.
//
//

#import "PAPpeopleView.h"

@implementation PAPpeopleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *comingsoon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 190.0f, 70.0f)];
        [comingsoon setImage:[UIImage imageNamed:@"comingsoon.png"]];
        [self addSubview:comingsoon];
    }
    return self;
}

@end
