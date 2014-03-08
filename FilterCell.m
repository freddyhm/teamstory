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
        
        // border set up for selected filter, lazy loading frame
        self.selectedFilterBorder = [CALayer layer];
        [self.selectedFilterBorder setBackgroundColor:[[UIColor clearColor] CGColor]];
        [self.selectedFilterBorder setCornerRadius:2.0];
        [self.selectedFilterBorder setBorderWidth:2.0];
        [self.selectedFilterBorder setBorderColor:[[UIColor redColor] CGColor]];

        
        //color for selection and default
        self.selectedStateColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        self.defaultStateColor = [UIColor colorWithRed:(154/255.0) green:(154/255.0) blue:(154/255.0) alpha:1];
        
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

- (void)select{
    
    self.filter.textColor = self.selectedStateColor;
    
    // add frame to border, add to selected filter
    CGRect borderFrame = CGRectMake(0, 0, (self.placeholder.frame.size.width), (self.placeholder.frame.size.height));
    [self.selectedFilterBorder setFrame:borderFrame];
    
    [self.placeholder.layer insertSublayer:self.selectedFilterBorder atIndex:0];
    [self.placeholder.layer setValue:self.selectedFilterBorder forKey:@"border"];

}

- (void)deselect{
    
    self.filter.textColor = self.defaultStateColor;
    
    // retrieve border from imageview and remove if present
    CALayer *border = [self.placeholder.layer valueForKey:@"border"];
    
    if (border != nil){
        [border removeFromSuperlayer];
        [self.placeholder.layer setValue:nil forKey:@"border"];
    }
}



@end
