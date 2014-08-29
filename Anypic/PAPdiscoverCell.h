//
//  PAPdiscoverCell.h
//  Teamstory
//
//  Created by Tobok Lee on 2014-08-24.
//
//

#import <UIKit/UIKit.h>

@interface PAPdiscoverCell : UITableViewCell {
    id _delegate;
}

@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) UIButton *imageViewButton1;
@property (nonatomic, strong) UIButton *imageViewButton2;
@property (nonatomic, strong) UIButton *imageViewButton3;

@property (nonatomic, strong) PFImageView *PFimageViewForButton1;
@property (nonatomic, strong) PFImageView *PFimageViewForButton2;
@property (nonatomic, strong) PFImageView *PFimageViewForButton3;

- (void)setImage1:(PFFile *)image1 setImage2:(PFFile *)image2 setImage3:(PFFile *)image3;

@end

@protocol PAPdiscoverCellDelegate <NSObject>
@optional

@end
