//
//  PAPActivityPointCell.h
//  Teamstory
//
//  Created by Tobok Lee on 3/13/15.
//
//

#import <UIKit/UIKit.h>
#import "PAPPhotoHeaderView.h"

@interface PAPActivityPointCell : UITableViewCell <PAPPhotoHeaderViewDelegate>


@property (nonatomic, strong) PAPPhotoHeaderView *photoHeaderView;

@end
