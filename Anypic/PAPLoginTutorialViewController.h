//
//  PAPLoginTutorialViewController.h
//  Teamstory
//
//  Created by Tobok Lee on 3/18/14.
//
//

#import <UIKit/UIKit.h>

@interface PAPLoginTutorialViewController : UIViewController <UIScrollViewDelegate, PFLogInViewControllerDelegate>

@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UILabel *text;

@end
