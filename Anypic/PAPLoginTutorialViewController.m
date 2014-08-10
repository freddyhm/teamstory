//
//  PAPLoginTutorialViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 3/18/14.
//
//

#import "PAPLoginTutorialViewController.h"
#import "PAPLogInViewController.h"
#import "AppDelegate.h"

@interface PAPLoginTutorialViewController () {
    float screenOffset;
}

@end

@implementation PAPLoginTutorialViewController

@synthesize pageControl;
@synthesize text;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"intro_bg.png"]]];
    
    UIScrollView *mainSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, [UIScreen mainScreen].bounds.size.height - 75.0f)];
    [mainSV setContentSize:CGSizeMake(1280.0f, 0.0f)];
    mainSV.delegate = self;
    [mainSV setPagingEnabled:YES];
    [mainSV setShowsVerticalScrollIndicator:NO];
    [mainSV setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:mainSV];

    if ([UIScreen mainScreen].bounds.size.height == 480) {
        screenOffset = 0.0f;
    } else {
        screenOffset = 75.0f;
    }
    
    UIImage *logoViewImage = [UIImage imageNamed:@"intro_logo.png"];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((320.0f - logoViewImage.size.width) / 2, 100.0f + screenOffset, logoViewImage.size.width, logoViewImage.size.height)];
    [logoView setImage:logoViewImage];
    [mainSV addSubview:logoView];
    
    UIImage *content1Image = [UIImage imageNamed:@"intro_moment_1.png"];
    UIImageView *content1 = [[UIImageView alloc] initWithFrame:CGRectMake(320.0f + ((320.0f - content1Image.size.width) / 2), 50.0f + screenOffset, content1Image.size.width, content1Image.size.height)];
    [content1 setImage:content1Image];
    [mainSV addSubview:content1];

    UIImage *content2Image = [UIImage imageNamed:@"intro_moment_2.png"];
    UIImageView *content2 = [[UIImageView alloc] initWithFrame:CGRectMake(640.0f + (320.0f - content2Image.size.width) / 2, 50.0f + screenOffset, content2Image.size.width, content2Image.size.height)];
    [content2 setImage:content2Image];
    [mainSV addSubview:content2];
    
    UIImage *content3Image = [UIImage imageNamed:@"intro_moment_3.png"];
    UIImageView *content3 = [[UIImageView alloc] initWithFrame:CGRectMake(960.0f + (320.0f - content3Image.size.width) / 2, 50.0f + screenOffset, content3Image.size.width, content3Image.size.height)];
    [content3 setImage:content3Image];
    [mainSV addSubview:content3];
    
    UIPageControl *pageControl_bar = [[UIPageControl alloc] initWithFrame:CGRectMake(135.0f, [UIScreen mainScreen].bounds.size.height - 95.0f, 50.0f, 20.0f)];
    [self setPageControl:pageControl_bar];
    [pageControl_bar setPageIndicatorTintColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
    [pageControl_bar setCurrentPageIndicatorTintColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
    [self.pageControl setNumberOfPages:4];
    [self.view addSubview:pageControl_bar];
    
    UILabel *firstPageText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 420.0f + screenOffset, 320.0f, 50.0f)];
    firstPageText.text = @"A Community for Startup & Entrepreneurs";
    [firstPageText setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [firstPageText setTextColor:[UIColor whiteColor]];
    [firstPageText setTextAlignment:NSTextAlignmentCenter];
    [mainSV addSubview:firstPageText];
    
    UILabel *secondPageText = [[UILabel alloc] initWithFrame:CGRectMake(320.0f, [UIScreen mainScreen].bounds.size.height - 150.0f - screenOffset, 320.0f, 50.0f)];
    secondPageText.text = @"Share and discover startup moments";
    [secondPageText setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [secondPageText setTextColor:[UIColor whiteColor]];
    [secondPageText setTextAlignment:NSTextAlignmentCenter];
    [mainSV addSubview:secondPageText];
    
    UILabel *thirdPageText = [[UILabel alloc] initWithFrame:CGRectMake(640.0f, [UIScreen mainScreen].bounds.size.height - 150.0f - screenOffset, 320.0f, 50.0f)];
    thirdPageText.text = @"Share thoughts and questions";
    [thirdPageText setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [thirdPageText setTextColor:[UIColor whiteColor]];
    [thirdPageText setTextAlignment:NSTextAlignmentCenter];
    [mainSV addSubview:thirdPageText];
    
    UILabel *fourthPageText = [[UILabel alloc] initWithFrame:CGRectMake(960.0f, [UIScreen mainScreen].bounds.size.height - 150.0f - screenOffset, 320.0f, 50.0f)];
    fourthPageText.text = @"Connect with entrepreneurs around the world";
    [fourthPageText setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [fourthPageText setTextColor:[UIColor whiteColor]];
    [fourthPageText setTextAlignment:NSTextAlignmentCenter];
    [mainSV addSubview:fourthPageText];
    
    
    
    self.text = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - 300.0f + screenOffset, 320.0f, 50.0f)];
    [self.text setTextAlignment:NSTextAlignmentCenter];
    [self.text setTextColor:[UIColor whiteColor]];
    [self.text setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    self.text.numberOfLines = 0;
    [self.view addSubview:self.text];
    
    UIButton *joinButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, [UIScreen mainScreen].bounds.size.height - 60.0f, 145.0f, 50.0f)];
    [joinButton setBackgroundColor:[UIColor colorWithRed:91.0f/255.0f green:194.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
    joinButton.layer.cornerRadius = 2.0f;
    [joinButton setTitle:@"Join now" forState:UIControlStateNormal];
    joinButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [joinButton addTarget:self action:@selector(joinButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinButton];
    
    UIButton *signInButton = [[UIButton alloc] initWithFrame:CGRectMake(165.0f, [UIScreen mainScreen].bounds.size.height - 60.0f, 145.0f, 50.0f)];
    [signInButton setBackgroundColor:[UIColor clearColor]];
    signInButton.layer.borderColor = [UIColor whiteColor].CGColor;
    signInButton.layer.borderWidth = 2.0f;
    signInButton.layer.cornerRadius = 2.0f;
    [signInButton setTitle:@"Sign in" forState:UIControlStateNormal];
    signInButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [signInButton addTarget:self action:@selector(signInButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signInButton];
    
}


- (void)joinButtonAction:(id)sender{
    NSString *userType = @"join";
    
    PAPLogInViewController *loginViewController = [[PAPLogInViewController alloc] initWithLoginType:userType];
    [loginViewController setDelegate:self];
    loginViewController.fields = PFLogInFieldsFacebook | PFLogInFieldsTwitter;
    loginViewController.facebookPermissions = @[ @"user_about_me" ];
    
    [self.navigationController pushViewController:loginViewController animated:YES];
  
    
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] logInViewController:logInController didLogInUser:user];
}

- (void)signInButtonAction:(id)sender {
    NSString *userType = @"signIn";
    
    PAPLogInViewController *loginViewController = [[PAPLogInViewController alloc] initWithLoginType:userType];
    [loginViewController setDelegate:self];
    loginViewController.fields = PFLogInFieldsFacebook | PFLogInFieldsTwitter;
    loginViewController.facebookPermissions = @[ @"user_about_me" ];
    
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[self.pageControl setCurrentPage:page];
}


@end
