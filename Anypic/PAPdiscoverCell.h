//
//  PAPdiscoverCell.h
//  Teamstory
//
//  Created by Tobok Lee on 2014-08-24.
//
//

#import <UIKit/UIKit.h>

@interface PAPdiscoverCell : UITableViewCell

@property (nonatomic, strong) UIButton *imageViewButton1;
@property (nonatomic, strong) UIButton *imageViewButton2;
@property (nonatomic, strong) UIButton *imageViewButton3;

- (void)setImage1:(PFFile *)image1 setImage2:(PFFile *)image2 setImage3:(PFFile *)image3;

@end
