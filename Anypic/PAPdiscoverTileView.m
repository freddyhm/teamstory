//
//  PAPdicoverTileView.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-08-24.
//
//

#import "PAPdiscoverTileView.h"

@interface PAPdiscoverTileView() {

}
@property (nonatomic, strong) UIView *mainMenuView;
@property (nonatomic, strong) UIButton *momentsMenu;
@property (nonatomic, strong) UIButton *thoughtsMenu;
@property (nonatomic, strong) UIView *highlightBar;
@property (nonatomic, strong) UIColor *teamstoryColor;

@end

@implementation PAPdiscoverTileView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.teamstoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        
        // ----------------- initiate menues
        self.mainMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 44.0f)];
        self.mainMenuView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        [self addSubview:self.mainMenuView];
        
        self.momentsMenu = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width / 2, 44.0f)];
        [self.momentsMenu setTitle:@"Moments" forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.momentsMenu addTarget:self action:@selector(momentsMenuAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainMenuView addSubview:self.momentsMenu];
        
        self.thoughtsMenu = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 0.0f, [UIScreen mainScreen].bounds.size.width / 2, 44.0f)];
        [self.thoughtsMenu setTitle:@"Thoughts" forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.thoughtsMenu addTarget:self action:@selector(thoughtsMenuAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainMenuView addSubview:self.thoughtsMenu];
        
        self.highlightBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.0f, [UIScreen mainScreen].bounds.size.width / 2, 3.0f)];
        [self.highlightBar setBackgroundColor:self.teamstoryColor];
        [self.mainMenuView addSubview:self.highlightBar];
        
        [self labelSetting:@"Moments"];
        
        
    }
    return self;
}


- (void) momentsMenuAction:(id)sender {
    [self labelSetting:@"Moments"];
}

- (void) thoughtsMenuAction:(id)sender {
    [self labelSetting:@"Thoughts"];
}

-(void) labelSetting:(NSString *)selected {
    if ([selected isEqualToString:@"Moments"]) {
        [self.momentsMenu setTitleColor:self.teamstoryColor forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.thoughtsMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [UIView animateWithDuration:0.1f animations:^{
            self.highlightBar.frame = CGRectMake(0.0f, 41.0f, [UIScreen mainScreen].bounds.size.width / 2, 3.0f);
        }];
    } else {
        [self.thoughtsMenu setTitleColor:self.teamstoryColor forState:UIControlStateNormal];
        self.thoughtsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.momentsMenu setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        self.momentsMenu.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [UIView animateWithDuration:0.1f animations:^{
            self.highlightBar.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 41.0f, [UIScreen mainScreen].bounds.size.width / 2, 3.0f);
        }];
    }
    
}

@end