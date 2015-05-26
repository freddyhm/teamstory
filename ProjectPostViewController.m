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

@end


@interface ProjectPostViewController ()


@property (weak, nonatomic) IBOutlet UITextField *projectTitle;
@property (weak, nonatomic) IBOutlet UITextView *projectGoal;
@property (weak, nonatomic) IBOutlet UITextField *projectDueDate;
@property (weak, nonatomic) NSString *postType;
@property (weak, nonatomic) PFUser *user;

@end

@implementation ProjectPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postType = @"project";
    self.user = [PFUser currentUser];
    
    // warn the member of special condition if they already have a project
    [self checkForActiveProject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self checkInputTextIsLessThanMaxLength:textField.text type:@"title"];
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    [self checkInputTextIsLessThanMaxLength:textView.text type:@"goal"];
}

- (BOOL)isInputTypeValid:(NSString *)type{
    return [type isEqualToString:@"title"] || [type isEqualToString:@"goal"] || [type isEqualToString:@"due date"];
    
}

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

- (BOOL)checkAllInputTextIsValid{
    
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

- (void)saveEdit:(id)sender {
    
    if([self checkAllInputTextIsValid]){
        
        [super saveEdit:sender];
    }
}

- (void)checkForActiveProject{
    [self.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.user = (PFUser *)object;
        BOOL hasProject = [[[self.user objectForKey:@"activeProject"] objectId] length] > 0;
        [self showExistingProjectWarning:hasProject];
    }];
}

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




@end
