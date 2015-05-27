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


@interface ThoughtPostViewController ()

- (void)saveEdit:(id)sender;
@property int prevBkgdIndex;

@end


@interface ProjectPostViewController ()

// input fields
@property (weak, nonatomic) IBOutlet UITextField *projectTitle;
@property (weak, nonatomic) IBOutlet UITextView *projectGoal;
@property (weak, nonatomic) IBOutlet UITextField *projectDueDate;

// input labels
@property (weak, nonatomic) IBOutlet UILabel *projectTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectGoalLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectDueDateLabel;

@property (weak, nonatomic) NSString *postType;
@property (weak, nonatomic) PFUser *user;
@property (weak, nonatomic) IBOutlet UILabel *placeholder;
@property (strong, nonatomic) UIColor *placeholderColor;

// textfield placeholders
@property (strong, nonatomic) NSString *projectTitlePlaceholder;
@property (strong, nonatomic) NSString *projectDueDatePlaceholder;

@end

@implementation ProjectPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.postType = @"project";
    self.user = [PFUser currentUser];
    
    [self.placeholder setText:@"It'll make the world a better place"];

    [self setFieldPlaceholder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Placeholder Methods

- (void)setFieldPlaceholder{
    self.projectTitlePlaceholder = self.projectTitle.text;
    self.projectDueDatePlaceholder = self.projectDueDate.text;
}

- (BOOL)isPlaceholder:(UITextField *)textField{
    
    if(([textField.text isEqualToString:self.projectTitlePlaceholder] || [textField.text isEqualToString:self.projectDueDatePlaceholder])){
        return YES;
    }
    
    return NO;
}

- (void)updateTextColor{
    
    self.placeholderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.6];
    
    // when current background is white
    if(super.prevBkgdIndex == 0){
        
        // input labels
        self.projectTitleLabel.textColor = [UIColor blackColor];
        self.projectGoalLabel.textColor = [UIColor blackColor];
        self.projectDueDateLabel.textColor = [UIColor blackColor];
        
        self.projectTitle.textColor = [UIColor grayColor];
        self.projectDueDate.textColor = [UIColor grayColor];
        
        [self.placeholder setTextColor:[UIColor grayColor]];
        
        [self updateNavControlColors:@"dark"];

    }else{
        
        // input labels
        self.projectTitleLabel.textColor = [UIColor whiteColor];
        self.projectGoalLabel.textColor = [UIColor whiteColor];
        self.projectDueDateLabel.textColor = [UIColor whiteColor];
        
        // input text
        self.projectTitle.textColor = self.placeholderColor;
        self.projectDueDate.textColor = self.placeholderColor;
        
        self.placeholder.textColor = self.placeholderColor;
    
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
    
    if([self isPlaceholder:textField]){
        textField.text = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self checkInputTextIsLessThanMaxLength:textField.text type:@"title"];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if(!self.placeholder.hidden){
        [self.placeholder setHidden:YES];
    }
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    [self checkInputTextIsLessThanMaxLength:textView.text type:@"goal"];
}

- (BOOL)isInputTypeValid:(NSString *)type{
    return [type isEqualToString:@"title"] || [type isEqualToString:@"goal"] || [type isEqualToString:@"due date"];
    
}

#pragma mark - Error Checking Methods

- (BOOL)checkInputTextIsLessThanMaxLength:(NSString *)text type:(NSString *)type{
    
    BOOL isUnderMax = YES;
    
    if([self isInputTypeValid:type]){
        if([type isEqualToString:@"title"] && [text length] > MAX_TITLE_LENGTH){
            isUnderMax = NO;
            [self showOverMaxLengthAlert:type maxLength:MAX_TITLE_LENGTH];
        }else if([type isEqualToString:@"goal"] && [text length] > MAX_GOAL_LENGTH){
            isUnderMax = NO;
            [self showOverMaxLengthAlert:type maxLength:MAX_GOAL_LENGTH];
        }else if([type isEqualToString:@"due date"] && [text length] > MAX_DUE_DATE_LENGTH){
            isUnderMax = NO;
            [self showOverMaxLengthAlert:type maxLength:MAX_DUE_DATE_LENGTH];
        }
    }
    
    return isUnderMax;
}

- (BOOL)validateBeforeSaving{
    
    BOOL areInputsNotEmpty = [self checkInputTextIsNotEmpty:self.projectTitle.text] && [self checkInputTextIsNotEmpty:self.projectGoal.text] &&  [self checkInputTextIsNotEmpty:self.projectDueDate.text];
    
    if(!areInputsNotEmpty){
        [self showEmptyInputAlert];
    }
    
    BOOL areInputsLessThanMax = [self checkInputTextIsLessThanMaxLength:self.projectTitle.text type:@"title"] && [self checkInputTextIsLessThanMaxLength:self.projectGoal.text type:@"goal"] && [self checkInputTextIsLessThanMaxLength:self.projectDueDate.text type:@"due date"];
    
    return areInputsNotEmpty && areInputsLessThanMax;
}

- (BOOL)checkInputTextIsNotEmpty:(NSString *)text{

    return [text length] > 0;
}


#pragma mark - Saving Methods

- (UIImageView *)buildImageWithSubviews:(UIImageView *)backgroundView{
    
    [backgroundView addSubview:self.projectTitleLabel];
    [backgroundView addSubview:self.projectTitle];
    [backgroundView addSubview:self.projectGoalLabel];
    [backgroundView addSubview:self.projectGoal];
    [backgroundView addSubview:self.projectDueDateLabel];
    [backgroundView addSubview:self.projectDueDate];
    
    return backgroundView;
}

- (void)addExtraValueToPost:(PFObject *)post{
    [self createProjectObj:post];
}

- (void)createProjectObj:(PFObject *)post{
    
    // create a project object
    PFObject *project = [PFObject objectWithClassName:@"Project"];
    [project setObject:self.projectTitle.text forKey:@"title"];
    [project setObject:self.projectGoal.text forKey:@"goal"];
    [project setObject:self.projectDueDate.text forKey:@"dueDate"];
    
    // set project object on post
    [post setObject:project forKey:@"project"];
    
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self updateMemberActiveProject:project];
    }];
}

- (void)updateMemberActiveProject:(PFObject *)project{
    // update member's active project
    PFUser *user = [PFUser currentUser];
    [user setValue:project forKey:@"activeProject"];
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
