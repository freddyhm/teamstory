//
//  PAPperksView.m
//  Teamstory
//
//  Created by Tobok Lee on 1/16/14.
//
//

#import "PAPperksView.h"
#import "PAPperksoverlay.h"
#import "discoverPageViewController.h"

@implementation PAPperksView
@synthesize content_overlay;
@synthesize dimBackground;
@synthesize content1_cancel_button;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //PAPperksoverlay *perksOverlay = [[PAPperksoverlay alloc] init];
        //[self addSubview:perksOverlay];
        
        float screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        UIScrollView *perksScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth, [UIScreen mainScreen].bounds.size.height - 146.0f)];
        [perksScrollView setContentSize:CGSizeMake(screenWidth, 2000.0f)];
        
        UIView *content1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth, 200.0f)];
        [content1 setBackgroundColor:[UIColor clearColor]];
        [perksScrollView addSubview:content1];
        
        UILabel *content1_label_title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 70.0f, 320.0f, 30.0f)];
        [content1_label_title setTextColor:[UIColor colorWithRed:79.0f/255.0f green:182.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        [content1_label_title setText:@"Deezer - All the music you love"];
        [content1_label_title setFont:[UIFont boldSystemFontOfSize:15.0f]];
        content1_label_title.textAlignment = NSTextAlignmentCenter;
        [content1 addSubview:content1_label_title];
        
        UILabel *content1_label_body = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 90.0f, 320.0f, 40.0f)];
        [content1_label_body setTextColor:[UIColor colorWithRed:141.0f/255.0f green:141.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
        [content1_label_body setFont:[UIFont systemFontOfSize:12.0f]];
        [content1_label_body setText:@"our favourite artists, albums, and tracks, plus\nnew discoveries waiting to be made."];
        content1_label_body.textAlignment = NSTextAlignmentCenter;
        content1_label_body.numberOfLines = 0;
        [content1 addSubview:content1_label_body];
        
        UIImageView *content1_logo = [[UIImageView alloc] initWithFrame:CGRectMake(95.0f, 20.0f, 130.0f, 50.0f)];
        [content1_logo setImage:[UIImage imageNamed:@"deezer-logo.png"]];
        [content1 addSubview:content1_logo];
        
        UIButton *content1_button = [[UIButton alloc] initWithFrame:CGRectMake(93.0f, 144.0f, 134.0f, 43.0f)];
        [content1_button setBackgroundImage:[UIImage imageNamed:@"discover-content-button.png"] forState:UIControlStateNormal];
        [content1_button setTitle:@"Find Out More" forState:UIControlStateNormal];
        content1_button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [content1_button setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [content1_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [content1_button addTarget:self action:@selector(content1_button_action:) forControlEvents:UIControlEventTouchUpInside];
        [content1 addSubview:content1_button];
        
        UIView *content2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 220.0f, screenWidth, 200.0f)];
        [content2 setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:0.8f]];
        [perksScrollView addSubview:content2];
        
        [perksScrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:perksScrollView];
        
    }
    return self;
}

- (void)content1_button_action:(id) sender{
    self.dimBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.dimBackground setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.dimBackground];
    
    self.content_overlay = [[UIView alloc] initWithFrame:CGRectMake(16.5f, 80.0f, 287.0f, 375.0f)];
    [self.content_overlay setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"deezer-popup.png"]]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.content_overlay];
    //[self addSubview:self.content1_overlay];
    
    self.content1_cancel_button = [[UIButton alloc] initWithFrame:CGRectMake(content_overlay.bounds.size.width - 30.0f, 5.0f, 22.0f, 22.0f)];
    [self.content1_cancel_button setImage:[UIImage imageNamed:@"button_cancel_selected.png"] forState:UIControlStateNormal];
    [self.content1_cancel_button addTarget:self action:@selector(content1_button_cancel_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.content_overlay addSubview:self.content1_cancel_button];
    

}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // If one of our subviews wants it, return YES
    for (UIView *subview in self.subviews) {
        CGPoint pointInSubview = [subview convertPoint:point fromView:self];
        if ([subview pointInside:pointInSubview withEvent:event]) {
            return YES;
        }
    }
    // otherwise return NO, as if userInteractionEnabled were NO
    return NO;
}



-(void)content1_button_cancel_action:(id)sender{
    [self.content_overlay removeFromSuperview];
    [self.dimBackground removeFromSuperview];
}

@end
