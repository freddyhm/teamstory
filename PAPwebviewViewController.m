//
//  PAPwebviewViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/19/14.
//
//

#import "PAPwebviewViewController.h"
#import "OpenInChromeController.h"
#import "Mixpanel.h"

@interface PAPwebviewViewController ()
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UIButton *refresh_browse;
@property (nonatomic, strong) UIView *browserBar;
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityIndicatorView;
@property (nonatomic, strong) UIButton *backward_browse;
@property (nonatomic, strong) UIButton *forward_browse;
@property (nonatomic, strong) NSString *currentWebsite;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) OpenInChromeController *openInChrome;


@end

@implementation PAPwebviewViewController

@synthesize webview;
@synthesize refresh_browse;
@synthesize browserBar;
@synthesize loadingActivityIndicatorView;
@synthesize backward_browse;
@synthesize forward_browse;
@synthesize currentWebsite;
@synthesize actionSheet;

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
    
    UIButton *inflatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inflatorButton setFrame:CGRectMake(0, 0, 19.0f, 25.0f)];
    [inflatorButton addTarget:self action:@selector(inflatorButotnAction:) forControlEvents:UIControlEventTouchUpInside];
    [inflatorButton setBackgroundImage:[UIImage imageNamed:@"btn_webview_options.png"] forState:UIControlStateNormal];
    //[inflatorButton setBackgroundImage:[UIImage imageNamed:@"button_back_selected.png"] forState:UIControlStateHighlighted];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:inflatorButton];
    
    // google class
    self.openInChrome =  [[OpenInChromeController alloc] init];
    
    self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, mainView.bounds.size.width, mainView.bounds.size.height - 45.0f)];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentWebsite]]];
    self.webview.scalesPageToFit = YES;
    self.webview.userInteractionEnabled = YES;
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

-(void)inflatorButotnAction:(id)sender {
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Link Share Options" properties:@{}];
    
    actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    // add chrome option if installed
    if ([self.openInChrome isChromeInstalled]) {
        [actionSheet addButtonWithTitle:@"Open in Chrome"];
    }
    
    [actionSheet addButtonWithTitle:@"Open in Safari"];
    [actionSheet addButtonWithTitle:@"Copy Link"];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0) {
        // check if chrome is installed (menu change to 1. chrome 2. safari 3. copy)
        if (![self.openInChrome isChromeInstalled]) {
            
            // mixpanel analytics - safari
            [[Mixpanel sharedInstance] track:@"Selected Link Share Option" properties:@{@"Link option":@"Safari"}];
            
            //Open in Safari Button.
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentWebsite]];
        }else{
            
            // mixpanel analytics - chrome
            [[Mixpanel sharedInstance] track:@"Selected Link Share Option" properties:@{@"Link option":@"Chrome"}];
            
            [self.openInChrome openInChrome:[NSURL URLWithString:currentWebsite]];
        }
    } else if (buttonIndex == 1) {
        if (![self.openInChrome isChromeInstalled]) {
            
            // mixpanel analytics - copy
            [[Mixpanel sharedInstance] track:@"Selected Link Share Option" properties:@{@"Link option":@"Copy"}];
            
            //Copy Link Button.
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            pasteBoard.persistent = YES;
            [pasteBoard setString:currentWebsite];
        }else{
            
            // mixpanel analytics - safari
            [[Mixpanel sharedInstance] track:@"Selected Link Share Option" properties:@{@"Link option":@"Safari"}];
            
            //Open in Safari Button.
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentWebsite]];
        }
        
    }else if (buttonIndex == 2){
        
        // mixpanel analytics - copy
        [[Mixpanel sharedInstance] track:@"Selected Link Share Option" properties:@{@"Link option":@"Copy"}];
        
        //Copy Link Button.
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.persistent = YES;
        [pasteBoard setString:currentWebsite];
    }
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
    if (![PFUser currentUser] || [PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.navigationController.navigationBarHidden = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
