//
//  KeyboardViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-10-08.
//
//

#import "CustomKeyboardViewController.h"

#define messageTextViewHeight 45.0f
#define textSize 15.0f
#define sendButtonWidth 50.0f
#define sendButtonHeight 45.0f
#define navBarHeight 64.0f

@interface CustomKeyboardViewController ()

@end

@implementation CustomKeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the view frame
    [self.view setFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (64.0f + messageTextViewHeight), [UIScreen mainScreen].bounds.size.width, messageTextViewHeight)];
    
    // set text view
    [self.messageTextView setFrame:CGRectMake(5.0f, 5.0f, self.view.bounds.size.width - 10.0f, self.view.bounds.size.height - 10.0f)];
    
    // set send button
    [self.sendButton setFrame:CGRectMake(self.view.bounds.size.width - sendButtonWidth, 0.0f, sendButtonWidth, sendButtonHeight)];
    self.sendButton.hidden = YES;
    [self.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeSendButtonState:(BOOL)state {
    if (state) {
        self.sendButton.alpha = 1.0f;
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.alpha = 0.7f;
        self.sendButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCustomKeyboardHeight:(CGFloat)kbHeight{
    self.keyboardHeight = kbHeight;
}

#pragma mark - Delegate Methods
- (void)sendButtonAction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendButtonAction:)]) {
        [self.delegate sendButtonAction:sender];
    }
}

- (void)changeTableViewHeight{
    if (self.delegate && [self.delegate respondsToSelector:@selector(setTableViewHeight)]) {
        [self.delegate setTableViewHeight];
    }
}

#pragma mark - TextView Methods

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.2f animations:^{
        self.messageTextView.frame = CGRectMake(5.0f, 5.0f, self.view.bounds.size.width - (10.0f + sendButtonWidth), self.view.bounds.size.height - 10.0f);
        self.sendButton.hidden = NO;
    }];
}

-(void)textViewDidChange:(UITextView *)textView {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:textSize]};
    CGRect textViewSize = [textView.text boundingRectWithSize:CGSizeMake(self.messageTextView.bounds.size.width - 10.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    if (textViewSize.size.height > 20.0f) {
        self.view.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (64.0f + textViewSize.size.height + self.keyboardHeight + 30.0f), [UIScreen mainScreen].bounds.size.width, textViewSize.size.height + 30.0f);
        
    } else {
        
        self.view.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (64.0f + messageTextViewHeight + self.keyboardHeight), [UIScreen mainScreen].bounds.size.width, messageTextViewHeight);
    }
    
    self.messageTextView.frame = CGRectMake(5.0f, 5.0f, self.view.bounds.size.width - 10.0f - sendButtonWidth, self.view.bounds.size.height - 10.0f);
    
    [self changeTableViewHeight];
    if ([textView.text length] > 0) {
        [self changeSendButtonState:YES];
    } else {
        [self changeSendButtonState:NO];
    }
}


@end
