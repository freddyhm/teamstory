//
//  KeyboardViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-10-08.
//
//

#import <UIKit/UIKit.h>

@protocol CustomKeyboardViewControllerDelegate;

@interface CustomKeyboardViewController : UIViewController <UITextViewDelegate>
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, weak) id<CustomKeyboardViewControllerDelegate> delegate;
@property (nonatomic, strong) UITableView *ih_tableView;
@property CGFloat keyboardHeight;

- (void)changeSendButtonState:(BOOL)state;
- (void)setCustomKeyboardHeight:(CGFloat)kbHeight;
- (void)textViewDidChange:(UITextView *)textView;
- (void)setKeyboardPosition:(CGFloat)kbPos;

@end

@protocol CustomKeyboardViewControllerDelegate <NSObject>
@required
- (void)sendButtonAction:(id)sender;
- (void)setTableViewHeight;

@end // end of delegate protocol
