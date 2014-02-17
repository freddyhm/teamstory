//
//  FilterCell.m
//  Anypic
//
//  Created by Freddy Hidalgo-Monchez on 2/6/2014.
//
//

#import "FilterCell.h"

@implementation FilterCell
@synthesize filter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //create label, set parameters
        self.filter = [[UILabel alloc]initWithFrame:CGRectMake(-15, 12, 68, 21)];
        self.filter.textColor = [UIColor colorWithRed:(154/255.0) green:(154/255.0) blue:(154/255.0) alpha:1];
        [self.filter setFont:[UIFont systemFontOfSize:11]];
        [self.filter setTextAlignment:NSTextAlignmentCenter];
        
        //add to view
        [self addSubview:self.filter]; //the only place we want to do this addSubview: is here!
        
    }
    
    return self;
}

@end
