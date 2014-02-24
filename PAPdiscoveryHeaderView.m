//
//  PAPdiscoveryHeaderView.m
//  Teamstory
//
//  Created by Tobok Lee on 1/16/14.
//
//

#import "PAPdiscoveryHeaderView.h"

@implementation PAPdiscoveryHeaderView

@synthesize content_overlay;
@synthesize dimBackground;
@synthesize content1_button;
@synthesize content1_cancel_button;
@synthesize update_text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *headerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 100.0f)];
        [headerScrollView setContentSize:CGSizeMake(525.0f, 36.0f)];
        
        UIButton *newsButton_1 = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 125.0f, 90.0f)];
        [newsButton_1 setImage:[UIImage imageNamed:@"news1.png"] forState:UIControlStateNormal];
        [newsButton_1 addTarget:self action:@selector(newsButton_1_action:) forControlEvents:UIControlEventTouchUpInside];
        [headerScrollView addSubview:newsButton_1];
        
        UIButton *newsButton_2 = [[UIButton alloc] initWithFrame:CGRectMake(135.0f, 5.0f, 125.0f, 90.0f)];
        [newsButton_2 setImage:[UIImage imageNamed:@"news2.png"] forState:UIControlStateNormal];
        [newsButton_2 addTarget:self action:@selector(newsButton_2_action:) forControlEvents:UIControlEventTouchUpInside];
        [headerScrollView addSubview:newsButton_2];
        
        UIButton *newsButton_3 = [[UIButton alloc] initWithFrame:CGRectMake(265.0f, 5.0f, 125.0f, 90.0f)];
        [newsButton_3 setImage:[UIImage imageNamed:@"news3.png"] forState:UIControlStateNormal];
        [newsButton_3 addTarget:self action:@selector(newsButton_3_action:) forControlEvents:UIControlEventTouchUpInside];
        [headerScrollView addSubview:newsButton_3];
        
        UIButton *newsButton_4 = [[UIButton alloc] initWithFrame:CGRectMake(395.0f, 5.0f, 125.0f, 90.0f)];
        [newsButton_4 setImage:[UIImage imageNamed:@"news4.png"] forState:UIControlStateNormal];
        [newsButton_4 addTarget:self action:@selector(newsButton_4_action:) forControlEvents:UIControlEventTouchUpInside];
        [headerScrollView addSubview:newsButton_4];
        
        [headerScrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:headerScrollView];
    }
    return self;
}

- (void) dimbackground {
    self.dimBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.dimBackground setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.dimBackground];
}

- (void) newsButton_3_action:(id)sender {
    [self dimbackground];
    
    self.content_overlay = [[UIView alloc] initWithFrame:CGRectMake(16.5f, 80.0f, 287.0f, 375.0f)];
    [self.content_overlay setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"partner.png"]]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.content_overlay];
    
    [self cancelButton:self.content_overlay];
}

- (void) newsButton_4_action:(id)sender {
    [self dimbackground];
    
    self.content_overlay = [[UIView alloc] initWithFrame:CGRectMake(16.5f, 80.0f, 287.0f, 375.0f)];
    [self.content_overlay setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"hipchat.png"]]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.content_overlay];
    
    [self cancelButton:self.content_overlay];
}

- (void) cancelButton:(UIView *) target_view{
    self.content1_cancel_button = [[UIButton alloc] initWithFrame:CGRectMake(target_view.bounds.size.width - 30.0f, 5.0f, 22.0f, 22.0f)];
    [self.content1_cancel_button setImage:[UIImage imageNamed:@"button_cancel_selected.png"] forState:UIControlStateNormal];
    [self.content1_cancel_button addTarget:self action:@selector(content_button_cancel_action:) forControlEvents:UIControlEventTouchUpInside];
    [target_view addSubview:self.content1_cancel_button];
}

- (void)newsButton_2_action:(id)sender {
    [self dimbackground];
    
    self.content_overlay = [[UIView alloc] initWithFrame:CGRectMake(16.5f, 80.0f, 287.0f, 375.0f)];
    [self.content_overlay setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"jolt.png"]]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.content_overlay];
    
    [self cancelButton:self.content_overlay];
}

-(void)newsButton_1_action:(id)sender{
    /*
    UIImage *backgroundImage = [UIImage imageNamed:@"news1.png"];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(200.0f, 200.0f, 125.0f, 90.0f)];
    [view setImage:backgroundImage];
    [self addSubview:view];
    
    //[[[[UIApplication sharedApplication] delegate] window] addSubview:self.content1_overlay];
     */
    float padding_x = 15.0f;
    
    update_text = @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\n\n It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
    [self dimbackground];
    
    self.content_overlay = [[UIView alloc] initWithFrame:CGRectMake(padding_x, 80.0f, [UIScreen mainScreen].bounds.size.width - padding_x * 2, 370.0f)];
    [self.content_overlay setBackgroundColor:[UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.content_overlay];
    //[self addSubview:self.content1_overlay];
    
    [self cancelButton:self.content_overlay];
    
    UIImageView *title_image = [[UIImageView alloc] initWithFrame:CGRectMake(80.0f, 20.0f, 130.0f, 50.0f)];
    [title_image setImage:[UIImage imageNamed:@"update.png"]];
    [self.content_overlay addSubview:title_image];
    
    UILabel *update_textLabel = [[UILabel alloc] init];
    update_textLabel.numberOfLines = 0;
    [update_textLabel setText:update_text];
    [update_textLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [update_textLabel setTextColor:[UIColor colorWithRed:141.0f/255.0f green:141.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
    
    CGSize maximumLabelSize = CGSizeMake(self.content_overlay.bounds.size.width - 40.0f, 300.0f);
    CGSize expectedSize = [update_textLabel sizeThatFits:maximumLabelSize];
    
    UIScrollView *content_scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(20.0f, 80.0f, self.content_overlay.bounds.size.width - 40.0f, 240.0f)];
    [content_scrollview setContentSize:expectedSize];
    
    [update_textLabel setFrame:CGRectMake(0.0f, 0.0f, expectedSize.width, expectedSize.height)];
    [content_scrollview addSubview:update_textLabel];
    
    [self.content_overlay addSubview:content_scrollview];
    
    UIImageView *crew_logo = [[UIImageView alloc] initWithFrame:CGRectMake(95.0f, 330.0f, 100.0f, 30.0f)];
    [crew_logo setImage:[UIImage imageNamed:@"teamstorycrew.png"]];
    [self.content_overlay addSubview:crew_logo];

    
    
}

-(void)content_button_cancel_action:(id)sender{
    [self.content_overlay removeFromSuperview];
    [self.dimBackground removeFromSuperview];
}



@end
