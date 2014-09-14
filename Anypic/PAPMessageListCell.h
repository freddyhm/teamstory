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

@end

@protocol PAPMessageListCellDelegate <NSObject>
@optional

@end
