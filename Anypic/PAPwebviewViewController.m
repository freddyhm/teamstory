//
//  PAPwebviewViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/19/14.
//
//

#import "PAPwebviewViewController.h"

@interface PAPwebviewViewController ()
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UIButton *refresh_browse;
@property (nonatomic, strong) UIView *browserBar;
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityIndicatorView;
@property (nonatomic, strong) UIButton *backward_browse;
@property (nonatomic, strong) UIButton *forward_browse;
@property (nonatomic, strong) NSString *currentWebsite;


@end

@implementation PAPwebviewViewController

@synthesize webview;
@synthesize refresh_browse;
@synthesize browserBar;
@synthesize loadingActivityIndicatorView;
@synthesize backward_browse;
@synthesize forward_browse;
@synthesize currentWebsite;

- (id)initWithWebsite:(NSString *)website{
    self = [super init];
    if (self) {
        currentWebsite = website;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, 320.0f, [UIScreen mainScreen].bounds.size.height - 64.0f)];
    [mainView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:mainView];
    
    browserBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, mainView.bounds.size.height - 45.0f, 320.0f, 45.0f)];
    [browserBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-browser-bar.png"]]];
    [mainView addSubview:browserBar];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, mainView.bounds.size.width, mainView.bounds.size.height - 45.0f)];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentWebsite]]];
    [self.webview setDelegate:self];
    [mainView addSubview:self.webview];
    
    backward_browse = [UIButton buttonWithType:UIButtonTypeCustom];
    [backward_browse setFrame:CGRectMake(20.0f, 11.5f, 22.0f, 22.0f)];
    [backward_browse addTarget:self action:@selector(backward_browseAction:) forControlEvents:UIControlEventTouchUpInside];
    [backward_browse setImage:[UIImage imageNamed:@"browser-button-normal.png"] forState:UIControlStateNormal];
    [backward_browse setImage:[UIImage imageNamed:@"browser-button-no.png"] forState:UIControlStateDisabled];
    backward_browse.enabled = NO;
    [browserBar addSubview:backward_browse];

    forward_browse = [UIButton buttonWithType:UIButtonTypeCustom];
    [forward_browse setFrame:CGRectMake(browserBar.bounds.size.width - 42.0f, 11.5f, 22.0f, 22.0f)];
    [forward_browse addTarget:self action:@selector(forward_browseAction:) forControlEvents:UIControlEventTouchUpInside];
    [forward_browse setImage:[UIImage imageNamed:@"browser-button-forward-normal.png"] forState:UIControlStateNormal];
    [forward_browse setImage:[UIImage imageNamed:@"browser-button-forward-no.png"] forState:UIControlStateDisabled];
    forward_browse.enabled = NO;
    [browserBar addSubview:forward_browse];
    
    [self createFreshIcon];
    
    
}


- (void)createFreshIcon{
    refresh_browse = [UIButton buttonWithType:UIButtonTypeCustom];
    [refresh_browse setFrame:CGRectMake((browserBar.bounds.size.width / 2) - 11.0f, 11.5f, 22.0f, 22.0f)];
    [refresh_browse addTarget:self action:@selector(refresh_browseAction:) forControlEvents:UIControlEventTouchUpInside];
    [refresh_browse setImage:[UIImage imageNamed:@"browser-refresh.png"] forState:UIControlStateNormal];
    [browserBar addSubview:refresh_browse];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [refresh_browse removeFromSuperview];
    [loadingActivityIndicatorView removeFromSuperview];
    [self createFreshIcon];
    
    if ([self.webview canGoBack]) {
        backward_browse.enabled = YES;
    } else {
        backward_browse.enabled = NO;
    }
    if ([self.webview canGoForward]) {
        forward_browse.enabled = YES;
    } else {
        forward_browse.enabled = NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [refresh_browse removeFromSuperview];
    [loadingActivityIndicatorView removeFromSuperview];
    
    loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    [loadingActivityIndicatorView setFrame:CGRectMake((browserBar.bounds.size.width / 2) - 11.0f, 11.5f, 22.0f, 22.0f)];
    [browserBar addSubview:loadingActivityIndicatorView];
    
    if ([self.webview canGoBack]) {
        backward_browse.enabled = YES;
    } else {
        backward_browse.enabled = NO;
    }
    if ([self.webview canGoForward]) {
        forward_browse.enabled = YES;
    } else {
        forward_browse.enabled = NO;
    }
}

- (void)backward_browseAction:(id)sender{
    [self.webview goBack];
}

- (void)forward_browseAction:(id)sender{
    [self.webview goForward];
}

- (void)refresh_browseAction:(id)sender{
    [self.webview stopLoading];
    [loadingActivityIndicatorView removeFromSuperview];
    [self.webview reload];
}

- (void)backButtonAction:(id)sender {
    if (![PFUser currentUser]) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
