//
//  FilterCell.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2/6/2014.
//
//

#import "FilterCell.h"

@implementation FilterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //color for selection and default
        self.selectedStateColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        self.defaultStateColor = [UIColor colorWithRed:(154/255.0) green:(154/255.0) blue:(154/255.0) alpha:1];
        self.defaultTopBorderColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1];
        
        // set background and top border
        self.backgroundColor = [UIColor colorWithRed:0.122 green:0.122 blue:0.122 alpha:1];
        CALayer *TopBorder = [CALayer layer];
        TopBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 3.0f);
        TopBorder.backgroundColor = self.defaultTopBorderColor.CGColor;
        [self.layer insertSublayer:TopBorder atIndex:0];
        [self.layer setValue:TopBorder forKey:@"topBorder"];
        
        //create filter preview placeholder
        self.placeholder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        self.placeholder.backgroundColor = [UIColor whiteColor];
        [self.placeholder setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2 - 5)];
        
        //create label, set parameters
        self.filter = [[UILabel alloc]initWithFrame:CGRectMake(self.placeholder.frame.origin.x, self.placeholder.frame.size.height,self.placeholder.frame.size.width, self.placeholder.frame.size.height)];
        self.filter.textColor = [UIColor colorWithRed:(154/255.0) green:(154/255.0) blue:(154/255.0) alpha:1];
        [self.filter setFont:[UIFont systemFontOfSize:11]];
        [self.filter setFont:[UIFont boldSystemFontOfSize:11.0]];
        [self.filter setTextAlignment:NSTextAlignmentCenter];
        
        //add as subviews
        [self addSubview:self.filter];
        [self addSubview:self.placeholder];
    }
    
    return self;
}

-(void)setState:(NSString *)state{

    // retrieve top border, text, and change color based on state
    self.filter.textColor = [state isEqualToString:@"selected"] ? self.selectedStateColor : self.defaultStateColor;
    CALayer *topBorder = [self.layer valueForKey:@"topBorder"];
    topBorder.backgroundColor = [state isEqualToString:@"selected"] ? self.selectedStateColor.CGColor : self.defaultTopBorderColor.CGColor;;
}


@end
