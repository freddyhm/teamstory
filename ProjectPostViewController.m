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

@end

@implementation ProjectPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postType = @"project";
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





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
