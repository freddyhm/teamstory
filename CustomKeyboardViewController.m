//
//  KeyboardViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-10-08.
//
//

#import "CustomKeyboardViewController.h"
#import "PAPBaseTextCell.h"
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

/*
- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser cellType:(NSString *)acellType{
    if ([acellType isEqualToString:@"atmentionCell"]) {
        self.cellType = acellType;
        self.text_location = 0;
        
        if (self.atmentionRange.location != NSNotFound) {
            [self textView:commentTextView shouldChangeTextInRange:atmentionRange replacementText:[aUser objectForKey:@"displayName"]];
        }
        
        self.autocompleteTableView.hidden = YES;
        self.dimView.hidden = YES;
        self.postDetails.scrollEnabled = YES;
        
        [self.atmentionUserArray addObject:aUser];
    } else {
        [self shouldPresentAccountViewForUser:aUser];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([cellType isEqualToString:@"atmentionCell"]) {
        text = [text stringByAppendingString:@" "];
        
        if (range.location != NSNotFound) {
            textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length + 1) withString:text];
        }
        
        cellType = nil;
        return YES;
    }
    
    if ([text isEqualToString:@"@"]){
        [SVProgressHUD show];
        
        if ([self.userArray count] < 1) {
            userQuery = [PFUser query];
            userQuery.limit = MAXFLOAT;
            [userQuery whereKeyExists:@"displayName"];
            [userQuery orderByAscending:@"displayName"];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [SVProgressHUD dismiss];
                if (!error) {
                    self.userArray = [[NSMutableArray alloc] initWithArray:objects];
                    self.atmentionUserArray = [[NSMutableArray alloc] init];
                    self.filteredArray = objects;
                    self.autocompleteTableView.backgroundColor = [UIColor clearColor];
                } else {
                    NSLog(@"%@", error);
                }
            }]; } else {
                [SVProgressHUD dismiss];
            }
        
    } else if ([text isEqualToString:@"\n"]) {
        NSString *trimmedComment = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (trimmedComment.length != 0 && [self.photo objectForKey:kPAPPhotoUserKey]) {
            PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
            [comment setObject:trimmedComment forKey:kPAPActivityContentKey]; // Set comment text
            [comment setObject:[self.photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey]; // Set toUser
            [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
            [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
            [comment setObject:self.photo forKey:kPAPActivityPhotoKey];
            
            // storing atmention user list to the array (only filtered cases).
            if ([self.atmentionUserArray count] > 0) {
                NSArray *mod_atmentionUserArray = [self.atmentionUserArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName IN %@", textView.text]];
                [comment setObject:mod_atmentionUserArray forKey:@"atmention"];
            }
            
            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [ACL setPublicReadAccess:YES];
            [ACL setWriteAccess:YES forUser:[self.photo objectForKey:kPAPPhotoUserKey]];
            comment.ACL = ACL;
            
            [[PAPCache sharedCache] incrementCommentCountForPhoto:self.photo];
            
            // get post type
            NSString *postType = [self.photo objectForKey:@"type"] != nil ? [self.photo objectForKey:@"type"] : @"";
            
            // mixpanel analytics
            [[Mixpanel sharedInstance] track:@"Engaged" properties:@{@"Type":@"Core", @"Action": @"Commented", @"Post Type" : postType}];
            
            // Show HUD view
            [SVProgressHUD show];
            
            // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": comment} repeats:NO];
            
            [comment saveEventually:^(BOOL succeeded, NSError *error) {
                [timer invalidate];
                
                if (error && error.code == kPFErrorObjectNotFound) {
                    [[PAPCache sharedCache] decrementCommentCountForPhoto:self.photo];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not post comment", nil) message:NSLocalizedString(@"This photo is no longer available", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:self.photo userInfo:@{@"comments": @(self.objects.count + 1)}];
                
                self.atmentionUserArray = nil;
                self.atmentionUserArray = [[NSMutableArray alloc] init];
                [SVProgressHUD dismiss];
                [self loadObjects];
                
                // suscribe to post if commenter is not photo owner
                if(![[[self.photo objectForKey:kPAPPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]){
                    [PAPUtility updateSubscriptionToPost:self.photo forState:@"Subscribe"];
                }
                
            }];
        }
        
        [textView setText:@""];
        [textView resignFirstResponder];
        return NO;
    }
    
    if ([self.userArray count] > 0) {
        NSMutableString *updatedText = [[NSMutableString alloc] initWithString:textView.text];
        if (range.location == 0 || range.location == text_location) {
            self.autocompleteTableView.hidden = YES;
            self.dimView.hidden = YES;
            self.postDetails.scrollEnabled = YES;
            text_location = 0;
        } else if (range.location > 0 && [[updatedText substringWithRange:NSMakeRange(range.location - 1, 1)] isEqualToString:@"@"]) {
            text_location = range.location;
        }
        
        if ([text isEqualToString:@""] && text_location > 1) {
            range.location -=1;
            
            if (text_location > range.location) {
                text_location -= 1;
            }
        }
        
        if (text_location > 0) {
            if (range.location == NSNotFound) {
                NSLog(@"range location not found");
            } else {
                atmentionRange = NSMakeRange(text_location, range.location - text_location);
                atmentionSearchString = [updatedText substringWithRange:atmentionRange];
                atmentionSearchString = [atmentionSearchString stringByAppendingString:text];
            }
            
            self.filteredArray = [self.userArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName contains[c] %@", atmentionSearchString]];
            
            // frames should be handled differently for iphone 4 and 5.
            if ([UIScreen mainScreen].bounds.size.height == 480) {
                self.dimView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 9999.0f);
                self.autocompleteTableView.frame = CGRectMake(7.5f, self.postDetails.contentSize.height - 212.0f + text_offset, 305.0f, 143.0f - text_offset);
            } else {
                self.dimView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 9999.0f);
                self.autocompleteTableView.frame = CGRectMake(7.5f, self.postDetails.contentSize.height - 302.0f + text_offset, 305.0f, 232.0f - text_offset);
            }
            
            if ([self.filteredArray count] < 1) {
                self.dimView.hidden = YES;
            } else {
                self.dimView.hidden = NO;
            }
            
            self.autocompleteTableView.hidden = NO;
            self.postDetails.scrollEnabled = NO;
            [self.autocompleteTableView reloadData];
        }
    }
    
    return YES;

}
 */

#pragma mark - UIKeyboard

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve) {
    return (UIViewAnimationOptions)curve << 16;
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
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
