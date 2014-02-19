//
//  PAPperksoverlay.m
//  Anypic
//
//  Created by Tobok Lee on 2/16/14.
//
//

#import "PAPperksoverlay.h"

@implementation PAPperksoverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *test = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
        [test setImage:[UIImage imageNamed:@"IconHome.png"]];
        [self addSubview:test];
        
        //UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
        //[cancelButton ]
    }
    return self;
}


@end
