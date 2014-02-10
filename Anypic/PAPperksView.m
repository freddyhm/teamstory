//
//  PAPperksView.m
//  Anypic
//
//  Created by Tobok Lee on 1/16/14.
//
//

#import "PAPperksView.h"

@implementation PAPperksView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"Perks view has been created");
        UIImageView *test = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
        [test setImage:[UIImage imageNamed:@"IconHome.png"]];
        [self addSubview:test];
        
    }
    return self;
}

@end
