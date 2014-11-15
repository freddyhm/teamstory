//
//  KeyboardViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-10-08.
//
//

#import <UIKit/UIKit.h>

@protocol CustomKeyboardViewControllerDelegate;

@interface CustomKeyboardViewController : UIViewController <UITextViewDelegate, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, weak) id<CustomKeyboardViewControllerDelegate> delegate;
@property (nonatomic, strong) UITableView *ih_tableView;
@property CGFloat keyboardHeight;
- (void)setBackgroundTable:(UITableView *)tableView;

- (void)changeSendButtonState:(BOOL)state;
- (void)setCustomKeyboardHeight:(CGFloat)kbHeight;
- (void)textViewDidChange:(UITextView *)textView;
- (void)setTextViewPosition:(CGFloat)txtViewPos;
- (void)resetTextViewHeight;
- (void)dismissKeyboard;

@end

@protocol CustomKeyboardViewControllerDelegate <NSObject>
@optional
- (void)keyboardDidBeginEditing;
- (BOOL)keyboardShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@required
- (void)sendButtonAction:(id)sender;
- (void)setTableViewHeight;

@end // end of delegate protocol
