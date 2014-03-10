//
//  FilterCell.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2/6/2014.
//
//

#import <UIKit/UIKit.h>

@interface FilterCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *filter;
@property (strong, nonatomic) UIImageView *placeholder;
@property (strong, nonatomic) UIColor *selectedStateColor;
@property (strong, nonatomic) UIColor *defaultStateColor;
@property (strong, nonatomic) UIColor *defaultTopBorderColor;
@property (nonatomic, strong) CALayer *selectedFilterBorder;

-(void)setState:(NSString *)state;

@end
