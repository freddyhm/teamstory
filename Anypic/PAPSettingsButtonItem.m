//
//  PAPSettingsButtonItem.m
//  Teamstory
//
//

#import "PAPSettingsButtonItem.h"

@implementation PAPSettingsButtonItem

#pragma mark - Initialization

- (id)initWithTarget:(id)target action:(SEL)action {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self = [super initWithCustomView:settingsButton];
    if (self) {
        [settingsButton setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 22.0f)];
        [settingsButton setImage:[UIImage imageNamed:@"button_setting.png"] forState:UIControlStateNormal];
        [settingsButton setImage:[UIImage imageNamed:@"button_setting_selected.png"] forState:UIControlStateHighlighted];
        [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [settingsButton setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    }
    
    return self;
}
@end
