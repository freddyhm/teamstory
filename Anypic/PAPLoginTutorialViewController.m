//
//  PAPLoginTutorialViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 3/18/14.
//
//

#import "PAPLoginTutorialViewController.h"
#import "PAPLoginSelectionViewController.h"

@interface PAPLoginTutorialViewController ()

@end

@implementation PAPLoginTutorialViewController

@synthesize pageControl;
@synthesize text;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-intro.png"]]];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(65.0f, 30.0f, 190.0f, 65.0f)];
    [logoView setImage:[UIImage imageNamed:@"tutlogo.png"]];
    [self.view addSubview:logoView];
    
    UIView *footerBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 200.0f, 320.0f, 200.0f)];
    [footerBackground setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    [self.view addSubview:footerBackground];
    
    UIScrollView *mainSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 460.0f, 320.0f, 260.0f)];
    [mainSV setContentSize:CGSizeMake(960.0f, 260.0f)];
    mainSV.delegate = self;
    [mainSV setPagingEnabled:YES];
    [self.view addSubview:mainSV];
    
    UIImageView *content1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 260.0f)];
    [content1 setImage:[UIImage imageNamed:@"tut1.png"]];
    [mainSV addSubview:content1];
    
    UIImageView *content2 = [[UIImageView alloc] initWithFrame:CGRectMake(320.0f, 0.0f, 320.0f, 260.0f)];
    [content2 setImage:[UIImage imageNamed:@"tut2.png"]];
    [mainSV addSubview:content2];
    
    UIImageView *content3 = [[UIImageView alloc] initWithFrame:CGRectMake(640.0f, 0.0f, 320.0f, 260.0f)];
    [content3 setImage:[UIImage imageNamed:@"tut3.png"]];
    [mainSV addSubview:content3];
    
    UIPageControl *pageControl_bar = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 180.0f, mainSV.bounds.size.width, 20)];
    [self setPageControl:pageControl_bar];
    [pageControl_bar setPageIndicatorTintColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
    [pageControl_bar setCurrentPageIndicatorTintColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
    [self.pageControl setNumberOfPages:3];
    [mainSV setContentSize:CGSizeMake(mainSV.bounds.size.width * 3, mainSV.bounds.size.height)];
    [self.view addSubview:pageControl_bar];
    
    self.text = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 150.0f, 320.0f, 50.0f)];
    [self.text setText:@"Teamstory is an Invitation-only community\nfor startups and entrepreneurs to capture\nand share their unique startup moments."];
    [self.text setTextAlignment:NSTextAlignmentCenter];
    [self.text setTextColor:[UIColor colorWithWhite:0.4f alpha:1.0f]];
    [self.text setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    self.text.numberOfLines = 0;
    [self.view addSubview:self.text];
    
    UIButton *continue_button = [[UIButton alloc] initWithFrame:CGRectMake(35.0f, [UIScreen mainScreen].bounds.size.height - 70.0f, 250.0f, 45.0f)];
    [continue_button setBackgroundColor:[UIColor colorWithRed:91.0f/255.0f green:194.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
    [continue_button setTitle:@"Continue" forState:UIControlStateNormal];
    continue_button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [continue_button addTarget:self action:@selector(continue_button_Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continue_button];
}


- (void)continue_button_Action:(id)sender{
    PAPLoginSelectionViewController *loginSelectionViewController = [[PAPLoginSelectionViewController alloc] init];
    [self.navigationController pushViewController:loginSelectionViewController animated:YES];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[self.pageControl setCurrentPage:page];
    
    if (page == 0) {
        [self.text setText:@"Teamstory is an Invitation-only community\nfor startups and entrepreneurs to capture\nand share their unique startup moments."];
    } else if (page == 1) {
        [self.text setText:@"Capture moments along your journey,\nshare them with like-minded people and\nmake your story more meaningful."];
    } else {
        [self.text setText:@"Discover and connect with entrepreneuers,\nstartups, events and products around the\nworld. We're all in this together"];
    }
}


@end
