//
//  PAPdiscoveryHeaderView.m
//  Anypic
//
//  Created by Tobok Lee on 1/16/14.
//
//

#import "PAPdiscoveryHeaderView.h"

@implementation PAPdiscoveryHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *headerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 100.0f)];
        [headerScrollView setContentSize:CGSizeMake(395.0f, 36.0f)];
        
        UIButton *newsButton_1 = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 125.0f, 90.0f)];
        [newsButton_1 setImage:[UIImage imageNamed:@"news1.png"] forState:UIControlStateNormal];
        [newsButton_1 addTarget:self action:@selector(newsButton_1_action:) forControlEvents:UIControlEventTouchUpInside];
        [headerScrollView addSubview:newsButton_1];
        
        UIButton *newsButton_2 = [[UIButton alloc] initWithFrame:CGRectMake(135.0f, 5.0f, 125.0f, 90.0f)];
        [newsButton_2 setImage:[UIImage imageNamed:@"news2.png"] forState:UIControlStateNormal];
        [headerScrollView addSubview:newsButton_2];
        
        UIButton *newsButton_3 = [[UIButton alloc] initWithFrame:CGRectMake(265.0f, 5.0f, 125.0f, 90.0f)];
        [newsButton_3 setImage:[UIImage imageNamed:@"news3.png"] forState:UIControlStateNormal];
        [headerScrollView addSubview:newsButton_3];
        
        [headerScrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:headerScrollView];
    }
    return self;
}

-(void)newsButton_1_action:(id)sender{
    UIImage *backgroundImage = [UIImage imageNamed:@"news1.png"];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(200.0f, 200.0f, 125.0f, 90.0f)];
    [view setImage:backgroundImage];
    [self addSubview:view];
    
    
}


@end
