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
#import "PAPwebviewViewController.h"

@implementation PAPperksView
@synthesize content_overlay;
@synthesize dimBackground;
@synthesize content_cancel_button;
@synthesize navController;
@synthesize website;

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        navController = navigationController;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //PAPperksoverlay *perksOverlay = [[PAPperksoverlay alloc] init];
        //[self addSubview:perksOverlay];
        
        float screenWidth = [UIScreen mainScreen].bounds.size.width;
        float content_gap = 220.0f;
        // giving padding to the cells that only have the color scheme.
        float color_cell_padding = 20.0f;
        
        UIScrollView *perksScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth, [UIScreen mainScreen].bounds.size.height - 146.0f)];
        [perksScrollView setContentSize:CGSizeMake(screenWidth, 1700.0f)];
        
        
        // ------------------------>   content 1  <--------------------------
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
        
        
        // ------------------------>   content 2  <--------------------------
        UIView *content2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, content1.frame.origin.y + content_gap, screenWidth, 200.0f + color_cell_padding)];
        [content2 setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:0.8f]];
        [perksScrollView addSubview:content2];
        
        UILabel *content2_label_title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 70.0f, 320.0f, 30.0f)];
        [content2_label_title setTextColor:[UIColor colorWithRed:79.0f/255.0f green:182.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        [content2_label_title setText:@"Clarity - Advice for Entrepreneurs"];
        [content2_label_title setFont:[UIFont boldSystemFontOfSize:15.0f]];
        content2_label_title.textAlignment = NSTextAlignmentCenter;
        [content2 addSubview:content2_label_title];
        
        UILabel *content2_label_body = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 90.0f, 320.0f, 40.0f)];
        [content2_label_body setTextColor:[UIColor colorWithRed:141.0f/255.0f green:141.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
        [content2_label_body setFont:[UIFont systemFontOfSize:12.0f]];
        [content2_label_body setText:@"A marketplace that connects entrepreneurs with top advisors & industry experts."];
        content2_label_body.textAlignment = NSTextAlignmentCenter;
        content2_label_body.numberOfLines = 0;
        [content2 addSubview:content2_label_body];
        
        UIImageView *content2_logo = [[UIImageView alloc] initWithFrame:CGRectMake(95.0f, 20.0f, 130.0f, 50.0f)];
        [content2_logo setImage:[UIImage imageNamed:@"clarity-logo.png"]];
        [content2 addSubview:content2_logo];
        
        UIButton *content2_button = [[UIButton alloc] initWithFrame:CGRectMake(93.0f, 144.0f, 134.0f, 43.0f)];
        [content2_button setBackgroundImage:[UIImage imageNamed:@"discover-content-button.png"] forState:UIControlStateNormal];
        [content2_button setTitle:@"Find Out More" forState:UIControlStateNormal];
        content2_button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [content2_button setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [content2_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [content2_button addTarget:self action:@selector(content2_button_action:) forControlEvents:UIControlEventTouchUpInside];
        [content2 addSubview:content2_button];
        
        
        // ------------------------>   content 3  <--------------------------
        UIView *content3 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, content2.frame.origin.y + content_gap, screenWidth, 200.0f)];
        [content3 setBackgroundColor:[UIColor clearColor]];
        [perksScrollView addSubview:content3];
        
        UILabel *content3_label_title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 70.0f, 320.0f, 30.0f)];
        [content3_label_title setTextColor:[UIColor colorWithRed:79.0f/255.0f green:182.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        [content3_label_title setText:@"Slingbot - Grow Your Social Following"];
        [content3_label_title setFont:[UIFont boldSystemFontOfSize:15.0f]];
        content3_label_title.textAlignment = NSTextAlignmentCenter;
        [content3 addSubview:content3_label_title];
        
        UILabel *content3_label_body = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 90.0f, 310.0f, 40.0f)];
        [content3_label_body setTextColor:[UIColor colorWithRed:141.0f/255.0f green:141.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
        [content3_label_body setFont:[UIFont systemFontOfSize:12.0f]];
        [content3_label_body setText:@"Turn your followers into customers. $50 One-Time Credit!"];
        content3_label_body.textAlignment = NSTextAlignmentCenter;
        content3_label_body.numberOfLines = 0;
        [content3 addSubview:content3_label_body];
        
        UIImageView *content3_logo = [[UIImageView alloc] initWithFrame:CGRectMake(95.0f, 20.0f, 130.0f, 50.0f)];
        [content3_logo setImage:[UIImage imageNamed:@"slingbot-logo.png"]];
        [content3 addSubview:content3_logo];
        
        UIButton *content3_button = [[UIButton alloc] initWithFrame:CGRectMake(93.0f, 144.0f, 134.0f, 43.0f)];
        [content3_button setBackgroundImage:[UIImage imageNamed:@"discover-content-button.png"] forState:UIControlStateNormal];
        [content3_button setTitle:@"Find Out More" forState:UIControlStateNormal];
        content3_button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [content3_button setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [content3_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [content3_button addTarget:self action:@selector(content3_button_action:) forControlEvents:UIControlEventTouchUpInside];
        [content3 addSubview:content3_button];
        
        // ------------------------>   content 4  <--------------------------
        UIView *content4 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, content3.frame.origin.y + content_gap, screenWidth, 200.0f + color_cell_padding)];
        [content4 setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:0.8f]];
        [perksScrollView addSubview:content4];
        
        UILabel *content4_label_title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 70.0f, 320.0f, 30.0f)];
        [content4_label_title setTextColor:[UIColor colorWithRed:79.0f/255.0f green:182.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        [content4_label_title setText:@"Konotor - Talk To Your App Users"];
        [content4_label_title setFont:[UIFont boldSystemFontOfSize:15.0f]];
        content4_label_title.textAlignment = NSTextAlignmentCenter;
        [content4 addSubview:content4_label_title];
        
        UILabel *content4_label_body = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 90.0f, 310.0f, 40.0f)];
        [content4_label_body setTextColor:[UIColor colorWithRed:141.0f/255.0f green:141.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
        [content4_label_body setFont:[UIFont systemFontOfSize:12.0f]];
        [content4_label_body setText:@"A 2-way communication to connect with your users. 1 Month Free!"];
        content4_label_body.textAlignment = NSTextAlignmentCenter;
        content4_label_body.numberOfLines = 0;
        [content4 addSubview:content4_label_body];
        
        UIImageView *content4_logo = [[UIImageView alloc] initWithFrame:CGRectMake(95.0f, 20.0f, 130.0f, 50.0f)];
        [content4_logo setImage:[UIImage imageNamed:@"konotor-logo.png"]];
        [content4 addSubview:content4_logo];
        
        UIButton *content4_button = [[UIButton alloc] initWithFrame:CGRectMake(93.0f, 144.0f, 134.0f, 43.0f)];
        [content4_button setBackgroundImage:[UIImage imageNamed:@"discover-content-button.png"] forState:UIControlStateNormal];
        [content4_button setTitle:@"Find Out More" forState:UIControlStateNormal];
        content4_button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [content4_button setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [content4_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [content4_button addTarget:self action:@selector(content4_button_action:) forControlEvents:UIControlEventTouchUpInside];
        [content4 addSubview:content4_button];
        
        // ------------------------>   content 5  <--------------------------
        UIView *content5 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, content4.frame.origin.y + content_gap, screenWidth, 200.0f)];
        [content5 setBackgroundColor:[UIColor clearColor]];
        [perksScrollView addSubview:content5];
        
        UILabel *content5_label_title = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 70.0f, 310.0f, 30.0f)];
        [content5_label_title setTextColor:[UIColor colorWithRed:79.0f/255.0f green:182.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        [content5_label_title setText:@"Positionly - SEO Software and Tools"];
        [content5_label_title setFont:[UIFont boldSystemFontOfSize:15.0f]];
        content5_label_title.textAlignment = NSTextAlignmentCenter;
        [content5 addSubview:content5_label_title];
        
        UILabel *content5_label_body = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 90.0f, 320.0f, 40.0f)];
        [content5_label_body setTextColor:[UIColor colorWithRed:141.0f/255.0f green:141.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
        [content5_label_body setFont:[UIFont systemFontOfSize:12.0f]];
        [content5_label_body setText:@"The simplest SEO Software for startups . 20% Discount On Any Plan!"];
        content5_label_body.textAlignment = NSTextAlignmentCenter;
        content5_label_body.numberOfLines = 0;
        [content5 addSubview:content5_label_body];
        
        UIImageView *content5_logo = [[UIImageView alloc] initWithFrame:CGRectMake(95.0f, 20.0f, 130.0f, 50.0f)];
        [content5_logo setImage:[UIImage imageNamed:@"positionly-logo.png"]];
        [content5 addSubview:content5_logo];
        
        UIButton *content5_button = [[UIButton alloc] initWithFrame:CGRectMake(93.0f, 144.0f, 134.0f, 43.0f)];
        [content5_button setBackgroundImage:[UIImage imageNamed:@"discover-content-button.png"] forState:UIControlStateNormal];
        [content5_button setTitle:@"Find Out More" forState:UIControlStateNormal];
        content5_button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [content5_button setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [content5_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [content5_button addTarget:self action:@selector(content5_button_action:) forControlEvents:UIControlEventTouchUpInside];
        [content5 addSubview:content5_button];
        
        // ------------------------>   content 6  <--------------------------
        UIView *content6 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, content5.frame.origin.y + content_gap, screenWidth, 200.0f + color_cell_padding)];
        [content6 setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:0.8f]];
        [perksScrollView addSubview:content6];
        
        UILabel *content6_label_title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 70.0f, 320.0f, 30.0f)];
        [content6_label_title setTextColor:[UIColor colorWithRed:79.0f/255.0f green:182.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        [content6_label_title setText:@"Foundersuite - Tools For Entrepreneurs"];
        [content6_label_title setFont:[UIFont boldSystemFontOfSize:15.0f]];
        content6_label_title.textAlignment = NSTextAlignmentCenter;
        [content6 addSubview:content6_label_title];
        
        UILabel *content6_label_body = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 90.0f, 320.0f, 40.0f)];
        [content6_label_body setTextColor:[UIColor colorWithRed:141.0f/255.0f green:141.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
        [content6_label_body setFont:[UIFont systemFontOfSize:12.0f]];
        [content6_label_body setText:@"Collection of productivity tools for entrepreneurs. Get 25% Off!"];
        content6_label_body.textAlignment = NSTextAlignmentCenter;
        content6_label_body.numberOfLines = 0;
        [content6 addSubview:content6_label_body];
        
        UIImageView *content6_logo = [[UIImageView alloc] initWithFrame:CGRectMake(95.0f, 20.0f, 130.0f, 50.0f)];
        [content6_logo setImage:[UIImage imageNamed:@"foundersuite-logo.png"]];
        [content6 addSubview:content6_logo];
        
        UIButton *content6_button = [[UIButton alloc] initWithFrame:CGRectMake(93.0f, 144.0f, 134.0f, 43.0f)];
        [content6_button setBackgroundImage:[UIImage imageNamed:@"discover-content-button.png"] forState:UIControlStateNormal];
        [content6_button setTitle:@"Find Out More" forState:UIControlStateNormal];
        content6_button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [content6_button setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [content6_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [content6_button addTarget:self action:@selector(content6_button_action:) forControlEvents:UIControlEventTouchUpInside];
        [content6 addSubview:content6_button];
        
        // ------------------------>   content 7  <--------------------------
        UIView *content7 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, content6.frame.origin.y + content_gap, screenWidth, 200.0f)];
        [content7 setBackgroundColor:[UIColor clearColor]];
        [perksScrollView addSubview:content7];
        
        UILabel *content7_label_title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 70.0f, 320.0f, 30.0f)];
        [content7_label_title setTextColor:[UIColor colorWithRed:79.0f/255.0f green:182.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        [content7_label_title setText:@"Asana - Teamwork Without Email"];
        [content7_label_title setFont:[UIFont boldSystemFontOfSize:15.0f]];
        content7_label_title.textAlignment = NSTextAlignmentCenter;
        [content7 addSubview:content7_label_title];
        
        UILabel *content7_label_body = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 90.0f, 320.0f, 40.0f)];
        [content7_label_body setTextColor:[UIColor colorWithRed:141.0f/255.0f green:141.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
        [content7_label_body setFont:[UIFont systemFontOfSize:12.0f]];
        [content7_label_body setText:@"Asana puts conversations & tasks together, so you can get more done with less effort."];
        content7_label_body.textAlignment = NSTextAlignmentCenter;
        content7_label_body.numberOfLines = 0;
        [content7 addSubview:content7_label_body];
        
        UIImageView *content7_logo = [[UIImageView alloc] initWithFrame:CGRectMake(95.0f, 20.0f, 130.0f, 50.0f)];
        [content7_logo setImage:[UIImage imageNamed:@"asana.png"]];
        [content7 addSubview:content7_logo];
        
        UIButton *content7_button = [[UIButton alloc] initWithFrame:CGRectMake(93.0f, 144.0f, 134.0f, 43.0f)];
        [content7_button setBackgroundImage:[UIImage imageNamed:@"discover-content-button.png"] forState:UIControlStateNormal];
        [content7_button setTitle:@"Find Out More" forState:UIControlStateNormal];
        content7_button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [content7_button setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [content7_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [content7_button addTarget:self action:@selector(content7_button_action:) forControlEvents:UIControlEventTouchUpInside];
        [content7 addSubview:content7_button];

        
        
        
        [perksScrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:perksScrollView];
        
    }
    return self;
}

- (void)content1_button_action:(id) sender{
    self.website = @"http://deezer.com";
    [self create_popup:@"deezer-popup.png"];
}

- (void)content2_button_action:(id) sender{
    self.website = @"https://itunes.apple.com/ca/app/clarity-business-advice/id518385879?mt=8";
    [self create_popup:@"clarity-popup.png"];
}

- (void)content3_button_action:(id) sender{
    self.website = @"http://teamstoryapp.com/perks/sb";
    [self create_popup:@"slingbot-popup.png"];
}

- (void)content4_button_action:(id) sender{
    self.website = @"http://konotor.com/";
    [self create_popup:@"konotor-popup.png"];
}

- (void)content5_button_action:(id) sender{
    self.website = @"http://teamstoryapp.com/perks/ps";
    [self create_popup:@"positionly-popup.png"];
}

- (void)content6_button_action:(id) sender{
    self.website = @"http://teamstoryapp.com/perks/fs";
    [self create_popup:@"foundersuite-popup.png"];
}

- (void)content7_button_action:(id) sender{
    self.website = @"http://asana.com";
    [self create_popup:@"asana-popup.png"];
}

- (void) create_popup:(NSString *) imageName {
    [self dimbackground];
    
    self.content_overlay = [[UIView alloc] initWithFrame:CGRectMake(16.5f, 80.0f, 287.0f, 375.0f)];
    [self.content_overlay setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:imageName]]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.content_overlay];
    
    self.content_cancel_button = [[UIButton alloc] initWithFrame:CGRectMake(content_overlay.bounds.size.width - 30.0f, 5.0f, 22.0f, 22.0f)];
    [self.content_cancel_button setImage:[UIImage imageNamed:@"button_cancel_selected.png"] forState:UIControlStateNormal];
    [self.content_cancel_button addTarget:self action:@selector(content1_button_cancel_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.content_overlay addSubview:self.content_cancel_button];
    
    self.content_button = [[UIButton alloc] initWithFrame:CGRectMake(76.0f, 313.0f, 134.0f, 43.0f)];
    [self.content_button addTarget:self action:@selector(content_button_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.content_overlay addSubview:self.content_button];
}

- (void) content_button_action:(id)sender {
    [self.content_overlay removeFromSuperview];
    [self.dimBackground removeFromSuperview];
    
    if (!self.navController) {
        NSLog(@"navController cannot be nil");
    } else {
        PAPwebviewViewController *webviewController = [[PAPwebviewViewController alloc] initWithWebsite:self.website];
        webviewController.hidesBottomBarWhenPushed = YES;
        [self.navController pushViewController:webviewController animated:YES];
    }
}

- (void) dimbackground {
    self.dimBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.dimBackground setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.dimBackground];
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
