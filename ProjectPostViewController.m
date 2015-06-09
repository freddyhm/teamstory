//
//  ProjectPostViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-05-22.
//
//

#import "ProjectPostViewController.h"

#define MAX_GOAL_LENGTH 35
#define MAX_TITLE_LENGTH 30
#define TITLE_TAG_NUM 1

@interface ThoughtPostViewController ()

- (void)saveEdit:(id)sender;
- (void)showSaveButtonOnStart;
- (void)setBkgIndex:(int)index;

@property int prevBkgdIndex;

@end


@interface ProjectPostViewController ()

// input fields
@property (weak, nonatomic) IBOutlet UITextView *projectGoal;

// input labels
@property (weak, nonatomic) IBOutlet UILabel *projectGoalLabel;
@property (weak, nonatomic) IBOutlet UITextField *projectTitle;
@property (weak, nonatomic) IBOutlet UILabel *projectTitleLabel;

@property (weak, nonatomic) NSString *postType;
@property (weak, nonatomic) PFUser *user;
@property (strong, nonatomic) UIColor *placeholderColor;
@property (strong, nonatomic) NSMutableArray *bkgdImgOptions;

// textfield placeholders
@property (weak, nonatomic) IBOutlet UILabel *projectGoalPlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *projecTitlePlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *projectBkgdImgView;

@end

@implementation ProjectPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.postType = @"project";
    self.user = [PFUser currentUser];
    self.navigationItem.title = @"Create Project";
    
    [self.projectGoalPlaceholder setText:@"It'll make the world a better place"];
    
    [super showSaveButtonOnStart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Background Options Methods

// override thought post so we can add overlay pictures
- (void)setBkgIndex:(int)index{
    [super setBkgIndex:index];
    
    // create our background images when method is called by parent for the first tim
    if(self.bkgdImgOptions == nil){
        [self setBackgroundImgOptions:[self createBackgroundImgOptions]];
    }
    
    self.projectBkgdImgView.image = [self.bkgdImgOptions objectAtIndex:index];
}

- (void)setBackgroundImgOptions:(NSMutableArray *)bkgdOptions{
    self.bkgdImgOptions = bkgdOptions;
}
 

- (NSMutableArray *)createBackgroundImgOptions{
    
    UIImage *imgA = [UIImage imageNamed:@"bg_project_a.png"];
    UIImage *imgB = [UIImage imageNamed:@"bg_project_b.png"];
    UIImage *imgC = [UIImage imageNamed:@"bg_project_c.png"];
    UIImage *imgD = [UIImage imageNamed:@"bg_project_d.png"];
    UIImage *imgE = [UIImage imageNamed:@"bg_project_e.png"];
    UIImage *imgF = [UIImage imageNamed:@"bg_project_f.png"];
    UIImage *imgG = [UIImage imageNamed:@"bg_project_g.png"];
    UIImage *imgH = [UIImage imageNamed:@"bg_project_h.png"];
    UIImage *imgI = [UIImage imageNamed:@"bg_project_i.png"];
    
    // image selection
    NSMutableArray *bckgdImgOptions = [[NSMutableArray alloc]initWithObjects:imgA, imgB, imgC, imgD, imgE, imgF, imgG, imgH, imgI, nil];
    
    return bckgdImgOptions;
}


#pragma mark - Placeholder Methods

- (void)hidePlaceholderIfPresent:(UITextField *)textField{
    
    NSUInteger fieldNum = textField.tag;
    
    if(fieldNum == TITLE_TAG_NUM){
        [self.projecTitlePlaceholder setHidden:YES];
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
    
    BOOL areInputsNotEmpty = [self checkInputTextIsNotEmpty:self.projectTitle.text] && [self checkInputTextIsNotEmpty:self.projectGoal.text];
    
    if(!areInputsNotEmpty){
        [self showEmptyInputAlert];
    }
    
    BOOL areInputsLessThanMax = [self checkInputTextIsLessThanMaxLength:self.projectTitle.text type:@"title"] && [self checkInputTextIsLessThanMaxLength:self.projectGoal.text type:@"goal"];
    
    return areInputsNotEmpty && areInputsLessThanMax;
}

- (BOOL)checkInputTextIsNotEmpty:(NSString *)text{

    return [text length] > 0;
}


#pragma mark - Saving Methods

- (UIImageView *)buildImageWithSubviews:(UIImageView *)backgroundView{
    
    [backgroundView addSubview:self.projectBkgdImgView];
    [backgroundView addSubview:self.projectTitleLabel];
    [backgroundView addSubview:self.projectTitle];
    [backgroundView addSubview:self.projectGoalLabel];
    [backgroundView addSubview:self.projectGoal];
    
    return backgroundView;
}

- (void)addExtraValueToPost:(PFObject *)post{
    [self createProject:post];
}

- (void)createProject:(PFObject *)post{
    
    // update member active project
    [self updateMemberActiveProject:self.projectTitle.text];
    
    // create post with project title as identifier for project
    [post setObject:self.projectTitle.text forKey:@"projectTitle"];
}

- (void)updateMemberActiveProject:(NSString *)projectTitle{
    // update member's active project
    PFUser *user = [PFUser currentUser];
    [user setValue:projectTitle forKey:@"projectTitle"];
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
