//
//  PAPdiscoverFollowerCell.h
//  Teamstory
//
//  Created by Tobok Lee on 2/12/15.
//
//

#import <UIKit/UIKit.h>
#import "PAPPhotoHeaderView.h"

@protocol PAPdiscoverFollowerCellDelegate;

@interface PAPdiscoverFollowerCell : UITableViewCell <PAPPhotoHeaderViewDelegate>

@property (nonatomic,weak) id <PAPdiscoverFollowerCellDelegate> delegate;

-(void)setDiscoverFollowerUser:(PFUser *)user;

@property (nonatomic, strong) UIButton *photoButtion1;
@property (nonatomic, strong) UIButton *photoButtion2;
@property (nonatomic, strong) UIButton *photoButtion3;

@end

@protocol PAPdiscoverFollowerCellDelegate <NSObject>
@optional
-(void)setPhotoInDiscover:(PFObject *)photo;
- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;
- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapFollowButtonForDiscover:(UIButton *)button user:(PFUser *)user;
@end