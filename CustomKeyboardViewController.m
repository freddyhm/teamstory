//
//  KeyboardViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-10-08.
//
//

#import "CustomKeyboardViewController.h"
#import "PAPBaseTextCell.h"
#import "PAPLoginSelectionViewController.h"
#import "SVProgressHUD.h"

#define messageTextViewHeight 45.0f
#define textSize 15.0f
#define sendButtonWidth 50.0f
#define sendButtonHeight 45.0f
#define navBarHeight 64.0f

@interface CustomKeyboardViewController ()

@property (nonatomic, strong) NSString *cellType;
@property NSInteger text_location;
@property NSInteger atmentionLength;
@property NSRange atmentionRange;
@property NSInteger text_offset;
@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, strong) NSString *atmentionSearchString;
@property (nonatomic, strong) UITableView *autocompleteTableView;
@property (nonatomic, strong) NSMutableArray *atmentionUserArray;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *screenLocation;

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
    [self.messageTextView setFrame:CGRectMake(5.0f, 5.0f, self.view.bounds.size.width - (10.0f + sendButtonWidth), self.view.bounds.size.height - 10.0f)];
    
    // set send button
    self.sendButton.hidden = NO;
    [self.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.postType = @"";
    self.objCount = 0;
}

- (void)setLocation:(NSString *)screenLocation {
    self.screenLocation = screenLocation;
}

- (void)changeSendButtonState:(BOOL)state {
    if (state) {
        UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        self.sendButton.alpha = 1.0f;
        self.sendButton.enabled = YES;
        [self.sendButton setTitleColor:teamStoryColor forState:UIControlStateNormal];
    } else {
        self.sendButton.alpha = 0.7f;
        self.sendButton.enabled = NO;
        [self.sendButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCustomKeyboardHeight:(CGFloat)kbHeight{
    self.keyboardHeight = kbHeight;
}

- (void)setTextViewPosition:(CGFloat)textViewPos{
    // set the view frame
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + textViewPos, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)setBackgroundTable:(UITableView *)tableView{
    self.tableView = tableView;
}

- (void)resetTextViewHeight{
    // set the view frame
    [self.view setFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (64.0f + messageTextViewHeight), [UIScreen mainScreen].bounds.size.width, messageTextViewHeight)];
    
    // set text view
    [self.messageTextView setFrame:CGRectMake(5.0f, 5.0f, self.view.bounds.size.width - (10.0f + sendButtonWidth), self.view.bounds.size.height - 10.0f)];
}

#pragma mark - Delegate Methods
- (void)sendButtonAction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendButtonAction:)]) {
        [self changeSendButtonState:NO];
        [self.delegate sendButtonAction:sender];
    }
}

- (void)changeTableViewHeight{
    if (self.delegate && [self.delegate respondsToSelector:@selector(setTableViewHeight)]) {
        [self.delegate setTableViewHeight];
    }
}

#pragma mark - TextView Methods

-(void)textViewDidChange:(UITextView *)textView {
    if ([self.screenLocation isEqualToString:@"messaging"]) {
        if (self.view.frame.origin.y < 300) {
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:textSize]};
            CGRect textViewSize = [textView.text boundingRectWithSize:CGSizeMake(self.messageTextView.bounds.size.width - 10.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
            
            if (textViewSize.size.height > 20.0f) {
                self.view.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (64.0f + textViewSize.size.height + self.keyboardHeight + 30.0f), [UIScreen mainScreen].bounds.size.width, textViewSize.size.height + 30.0f);
            } else {
                self.view.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (64.0f + messageTextViewHeight + self.keyboardHeight), [UIScreen mainScreen].bounds.size.width, messageTextViewHeight);
            }
            
            self.messageTextView.frame = CGRectMake(5.0f, 5.0f, self.view.bounds.size.width - 10.0f - sendButtonWidth, self.view.bounds.size.height - 10.0f);
        } else {
            [self.view setFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (64.0f + messageTextViewHeight), [UIScreen mainScreen].bounds.size.width, messageTextViewHeight)];
            self.messageTextView.frame = CGRectMake(5.0f, 5.0f, self.view.bounds.size.width - 10.0f - sendButtonWidth, self.view.bounds.size.height - 10.0f);
        }
    } else {
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:textSize]};
        CGRect textViewSize = [textView.text boundingRectWithSize:CGSizeMake(self.messageTextView.bounds.size.width - 10.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        
        if (textViewSize.size.height > 20.0f) {
            self.view.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (64.0f + textViewSize.size.height + self.keyboardHeight + 30.0f), [UIScreen mainScreen].bounds.size.width, textViewSize.size.height + 30.0f);
        } else {
            self.view.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - (64.0f + messageTextViewHeight + self.keyboardHeight), [UIScreen mainScreen].bounds.size.width, messageTextViewHeight);
        }
        
        self.messageTextView.frame = CGRectMake(5.0f, 5.0f, self.view.bounds.size.width - 10.0f - sendButtonWidth, self.view.bounds.size.height - 10.0f);
    }
    
    [self changeTableViewHeight];
    
    if ([textView.text length] > 0) {
        [self changeSendButtonState:YES];
    } else {
        [self changeSendButtonState:NO];
    }
}

#pragma mark - UIKeyboard

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve) {
    return (UIViewAnimationOptions)curve << 16;
}

- (void)keyboardWillShow:(NSNotification*)notification {
    // Handling anonymous users.
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        PAPLoginSelectionViewController *LoginSelectionViewController = [[PAPLoginSelectionViewController alloc] initWithNibName:@"PAPLoginSelectionViewController" bundle:nil];
        [self.view.window.rootViewController presentViewController:LoginSelectionViewController animated:YES completion:nil];
        return;
    }
    
    NSDictionary* info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIViewAnimationCurve animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    float keyboardDuration = [number doubleValue];
    
    // ---------- Animation in sync with keyboard moving up
    [UIView animateWithDuration:keyboardDuration delay:0 options:animationOptionsWithCurve(animationCurve) animations:^{
        // update textview position to sit on top of keyboard, update table with keyboard height
        [self setKeyboardHeight:kbSize.height - 64];
        [self setTextViewPosition:-kbSize.height];

        [self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, self.tableView.contentSize.height + (kbSize.height + 10))];
        float newOffset = self.tableView.contentOffset.y + kbSize.height;
        
        BOOL isLink = self.tableView.tableHeaderView.frame.size.height == 187;
        BOOL linkWithComments = isLink && self.tableView.contentSize.height > 500;
        // BOOL linkFewComments = isLink && self.tableView.contentSize.height > 500 && self.tableView.contentSize.height <= 650;
        
        NSLog(@"%f content offset y:", self.tableView.contentOffset.y);
        NSLog(@"%f tableHeaderViewHeight:", self.tableView.tableHeaderView.frame.size.height);
        NSLog(@"%f table content size:", self.tableView.contentSize.height);
        NSLog(@"%f newOffset:", newOffset);
        
        if(!isLink || linkWithComments){
            [self.tableView setContentOffset:CGPointMake(0, newOffset)];
        }

        
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
    self.autocompleteTableView.hidden = YES;
    self.dimView.hidden = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification{
    
    NSDictionary* info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIViewAnimationCurve animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    float keyboardDuration = [number doubleValue];
    
    // ---------- Animation in sync with keyboard moving up
    [UIView animateWithDuration:keyboardDuration delay:0 options:animationOptionsWithCurve(animationCurve) animations:^{
        // update textview position to sit on top of keyboard, update table with keyboard height
        [self setKeyboardHeight:-(kbSize.height - 64)];
        [self setTextViewPosition:kbSize.height];
        [self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, self.tableView.contentSize.height - kbSize.height)];
        
        float newOffset = self.tableView.contentOffset.y - kbSize.height;
        
        //NSLog(@"%f hide:", newOffset);
        
        if(newOffset > -65){
            [self.tableView setContentOffset:CGPointMake(0, newOffset)];
        }
        
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardDidBeginEditing)]) {
        [self.delegate keyboardDidBeginEditing];
    }
}

- (BOOL) textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardShouldChangeTextInRange:replacementText:)]) {
        return [self.delegate keyboardShouldChangeTextInRange:range replacementText:text];
    }
    
    return YES;
}



@end
