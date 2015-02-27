//
//  PAPdicoverTileView.h
//  Teamstory
//
//  Created by Tobok Lee on 2014-08-24.
//
//

#import <UIKit/UIKit.h>
#import "PAPdiscoverFollowerCell.h"

@interface PAPdiscoverTileView : UIView <UITableViewDataSource, UITableViewDelegate, PAPdiscoverFollowerCellDelegate>

-(void)setPictureQuery:(NSArray *)pictureQueryResults setThoughtQuery:(NSArray *)thoughtQueryResults;

- (void)setNavigationController:(UINavigationController *)navigationController;
- (void)loadFollowers;

@end
