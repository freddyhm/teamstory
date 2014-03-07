//
//  FilterCell.m
//  Teamstory
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
        
        //create filter preview placeholder
        self.placeholder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
        self.placeholder.backgroundColor = [UIColor whiteColor];
        
        //create label, set parameters
        self.filter = [[UILabel alloc]initWithFrame:CGRectMake(self.placeholder.frame.origin.x, self.placeholder.frame.size.height - 33,self.placeholder.frame.size.width, self.placeholder.frame.size.height)];
        self.filter.textColor = [UIColor colorWithRed:(154/255.0) green:(154/255.0) blue:(154/255.0) alpha:1];
        [self.filter setFont:[UIFont systemFontOfSize:11]];
        [self.filter setTextAlignment:NSTextAlignmentCenter];
        
        [self.placeholder addSubview:self.filter];

        //add to view
        [self addSubview:self.placeholder];
    }
    
    return self;
}

@end
