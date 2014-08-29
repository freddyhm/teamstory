//
//  PAPdiscoverIndustryCellTableViewCell.h
//  Teamstory
//
//  Created by Tobok Lee on 2014-08-28.
//
//

#import <UIKit/UIKit.h>

@interface PAPdiscoverIndustryCell : UITableViewCell {
    id _delegate;
}

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) UIButton *cellButton;

@end

@protocol PAPdiscoverIndustryCellDelegate <NSObject>
@optional

@end