//
//  PAPMessageListCell.h
//  Teamstory
//
//  Created by Tobok Lee on 9/10/14.
//
//

#import <UIKit/UIKit.h>

@interface PAPMessageListCell : UITableViewCell {
    id _delegate;
}

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) PFUser *messageUser;
@property (nonatomic, strong) UIButton *cellButton;
@property (nonatomic, strong) UILabel *lastMessageLabel;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) PFImageView *profileImageView;
@property (nonatomic, strong) UILabel *badgeLabel;

-(void)setUser:(PFUser *)user;

@end

@protocol PAPMessageListCellDelegate <NSObject>
@optional

@end
