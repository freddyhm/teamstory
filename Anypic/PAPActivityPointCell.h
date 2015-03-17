//
//  PAPActivityPointCell.h
//  Teamstory
//
//  Created by Tobok Lee on 3/13/15.
//
//

#import <UIKit/UIKit.h>
#import "PAPPhotoHeaderView.h"
@protocol PAPActivityPointCellDelegate;

@interface PAPActivityPointCell : UITableViewCell <PAPPhotoHeaderViewDelegate>

@property (nonatomic, weak) id <PAPActivityPointCellDelegate> delegate;
@property (nonatomic, strong) PAPPhotoHeaderView *photoHeaderView;

@end

@protocol PAPActivityPointCellDelegate <NSObject>
@optional
- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end
