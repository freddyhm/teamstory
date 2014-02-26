//
//  PAPperksView.h
//  Teamstory
//
//  Created by Tobok Lee on 1/16/14.
//
//

#import <UIKit/UIKit.h>

@interface PAPperksView : UIView
@property (nonatomic, strong) UIView *content_overlay;
@property (nonatomic, strong) UIView *dimBackground;
@property (nonatomic, strong) UIButton *content_cancel_button;
@property (nonatomic, strong) UIButton *content_button;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) NSString *website;

- (id)initWithNavigationController:(UINavigationController *)navigationController;

@end
