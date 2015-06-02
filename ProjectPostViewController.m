//
//  ProjectPostViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-05-22.
//
//

#import "ProjectPostViewController.h"

#define MAX_TITLE_LENGTH 30
#define MAX_GOAL_LENGTH 50
#define MAX_DUE_DATE_LENGTH 30

#define TITLE_TAG_NUM 1
#define DUEDATE_TAG_NUM 3


@interface ThoughtPostViewController ()

- (void)saveEdit:(id)sender;
- (void)showSaveButtonOnStart;

@property int prevBkgdIndex;

@end


@interface ProjectPostViewController ()

// input fields
@property (weak, nonatomic) IBOutlet UITextView *projectGoal;

// input labels
@property (weak, nonatomic) IBOutlet UILabel *projectGoalLabel;

@property (weak, nonatomic) NSString *postType;
@property (weak, nonatomic) PFUser *user;
@property (strong, nonatomic) UIColor *placeholderColor;

// textfield placeholders
@property (weak, nonatomic) IBOutlet UILabel *projectGoalPlaceholder;

@end

@implementation ProjectPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.postType = @"project";
    self.user = [PFUser currentUser];
    
    [self.projectGoalPlaceholder setText:@"It'll make the world a better place"];
    
    [super showSaveButtonOnStart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Placeholder Methods

- (void)hidePlaceholderIfPresent:(UITextField *)textField{
    
    NSUInteger fieldNum = textField.tag;
    
    if(fieldNum == TITLE_TAG_NUM){
        [self.projectGoalPlaceholder setHidden:YES];
    }
}

- (void)changeInputColor:(UIColor *)color{
    self.projectGoal.textColor = color;
}

- (void)changePlaceholderColor:(UIColor *)color{
    [self.projectGoalPlaceholder setTextColor:color];
}

- (void)changeLabelColor:(UIColor *)color{
    self.projectGoalLabel.textColor = color;
}


- (void)updateTextColor{
    
    self.placeholderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.6];
    
    // chck if current background is white
    if(super.prevBkgdIndex == 0){
        [self changeLabelColor:[UIColor blackColor]];
        [self changeInputColor:[UIColor blackColor]];
        [self changePlaceholderColor:[UIColor grayColor]];
        
        [self updateNavControlColors:@"dark"];

    }else{
        [self changeLabelColor:[UIColor whiteColor]];
        //[self changeInputColor:[UIColor whiteColor]];
        [self changePlaceholderColor:self.placeholderColor];

        [self updateNavControlColors:@"light"];
    }
}



- (void)updateNavControlColors:(NSString *)type{
    if([type isEqualToString:@"light"]){
        [self.leftNavSelector setImage:[UIImage imageNamed:@"arrows_left_white.png"] forState:UIControlStateNormal];
        [self.rightNavSelector setImage:[UIImage imageNamed:@"arrows_right_white.png"] forState:UIControlStateNormal];
    }else if([type isEqualToString:@"dark"]){
        [self.leftNavSelector setImage:[UIImage imageNamed:@"arrows_left.png"] forState:UIControlStateNormal];
        [self.rightNavSelector setImage:[UIImage imageNamed:@"arrows_right.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - Textfield and Textview Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self hidePlaceholderIfPresent:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self checkInputTextIsLessThanMaxLength:textField.text type:@"title"];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    // set default writing color
    textView.textColor = [UIColor blackColor];
    
    if(!self.projectGoalPlaceholder.hidden){
        [self.projectGoalPlaceholder setHidden:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self checkInputTextIsLessThanMaxLength:textView.text type:@"goal"];
}

#pragma mark - Error Checking Methods

- (BOOL)isInputTypeValid:(NSString *)type{
    return [type isEqualToString:@"goal"];
    
}

- (BOOL)checkInputTextIsLessThanMaxLength:(NSString *)text type:(NSString *)type{
    
    BOOL isUnderMax = YES;
    
    if([self isInputTypeValid:type]){
        if([type isEqualToString:@"goal"] && [text length] > MAX_GOAL_LENGTH){
            isUnderMax = NO;
            [self showOverMaxLengthAlert:type maxLength:MAX_GOAL_LENGTH];
        }
    }
    
    return isUnderMax;
}

- (BOOL)validateBeforeSaving{
    
    BOOL areInputsNotEmpty = [self checkInputTextIsNotEmpty:self.projectGoal.text];
    
    if(!areInputsNotEmpty){
        [self showEmptyInputAlert];
    }
    
    BOOL areInputsLessThanMax = [self checkInputTextIsLessThanMaxLength:self.projectGoal.text type:@"goal"];
    
    return areInputsNotEmpty && areInputsLessThanMax;
}

- (BOOL)checkInputTextIsNotEmpty:(NSString *)text{

    return [text length] > 0;
}


#pragma mark - Saving Methods

- (UIImageView *)buildImageWithSubviews:(UIImageView *)backgroundView{
    
    [backgroundView addSubview:self.projectGoalLabel];
    [backgroundView addSubview:self.projectGoal];
    
    return backgroundView;
}

- (void)addExtraValueToPost:(PFObject *)post{
    [self createProject:post];
}

- (void)createProject:(PFObject *)post{
    
    // update member active project
    [self updateMemberActiveProject:self.projectGoal.text];
    
    // create post with project goal as identifier for project
    [post setObject:self.projectGoal.text forKey:@"projectGoal"];
}

- (void)updateMemberActiveProject:(NSString *)projectGoal{
    // update member's active project
    PFUser *user = [PFUser currentUser];
    [user setValue:self.projectGoal.text forKey:@"projectGoal"];
    [user saveEventually];
}

- (void)saveEdit:(id)sender {
    [super saveEdit:sender];

}

#pragma Alert Methods

- (void)showExistingProjectWarning:(BOOL)hasProject{
    if(hasProject){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                        message:@"Creating a new project post will not delete your current one. It will only replace your 'working on...' status"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)showEmptyInputAlert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"Pease fill in all fields"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showOverMaxLengthAlert:(NSString *)type maxLength:(NSUInteger)maxLength{
    
    if(maxLength > 0){
        NSString *maxLengthStr = [[NSNumber numberWithInteger:maxLength] stringValue];
        NSString *msg = [[[@"Max characters for project " stringByAppendingString:type] stringByAppendingString:@" is "] stringByAppendingString:maxLengthStr];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}



@end
