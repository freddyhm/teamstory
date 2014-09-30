//
//  PAPMessagingCell.h
//  Teamstory
//
//  Created by Tobok Lee on 9/9/14.
//
//

#import <UIKit/UIKit.h>

@interface PAPMessagingCell : UITableViewCell {
    id _delegate;
}

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) UIView *RECEIVEDMessageView;
@property (nonatomic, strong) UILabel *RECEIVEDMessageLabel;
@property (nonatomic, strong) UIView *SENTMessageView;
@property (nonatomic, strong) UILabel *SENTMessageLabel;
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, strong) UILabel *timeStampLabel;

-(void)setType:(NSString *)type;
-(void)setText:(NSString *)text;

+(CGFloat)heightForCell;

@end

@protocol PAPMessagingCellDelegate <NSObject>
@optional

@end
