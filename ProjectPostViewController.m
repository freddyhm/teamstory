//
//  ProjectPostViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-05-22.
//
//

#import "ProjectPostViewController.h"

#define MAX_GOAL_LENGTH 200
#define MAX_TITLE_LENGTH 200
#define TITLE_TAG_NUM 1
#define GOAL_TAG_NUM 2

@interface ThoughtPostViewController ()

- (void)saveEdit:(id)sender;
- (void)showSaveButtonOnStart;
- (void)setBkgIndex:(int)index;
- (int)generateRandomNumFromCount:(NSUInteger)count;

@property int prevBkgdIndex;

@end


@interface ProjectPostViewController ()

// input field
@property (weak, nonatomic) IBOutlet UITextView *projectGoal;

// labels
@property (weak, nonatomic) IBOutlet UILabel *projectGoalLabel;
@property (weak, nonatomic) IBOutlet UITextView *projectTitle;
@property (weak, nonatomic) IBOutlet UILabel *projectTitleLabel;

// textfield placeholders
@property (weak, nonatomic) IBOutlet UILabel *projectGoalPlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *projecTitlePlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *projectBkgdImgView;


@property (strong, nonatomic) NSString *postType;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) UIColor *placeholderColor;
@property (strong, nonatomic) NSMutableArray *bkgdImgOptions;
@property (strong, nonatomic) UIScrollView *kbAvoidingScrollView;

@end

@implementation ProjectPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postType = @"project";
    self.user = [PFUser currentUser];
    self.navigationItem.title = @"Create Project";
    
    // keyboard properties set in IB but not responding for unknown reason so we set here
    [self setKeyboardDefaultSettingsForInput];
    
    [super showSaveButtonOnStart];
    
    self.kbAvoidingScrollView = (UIScrollView *)self.view;
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
    
    int randomBkgdOption = [super generateRandomNumFromCount:self.bkgdImgOptions.count];
    self.projectBkgdImgView.image = [self.bkgdImgOptions objectAtIndex:randomBkgdOption];
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

- (void)hidePlaceholderIfPresent:(UITextView *)textView{
    
    NSUInteger tagNum = textView.tag;
    
    if(tagNum == GOAL_TAG_NUM){
        if(!self.projectGoalPlaceholder.hidden){
            [self.projectGoalPlaceholder setHidden:YES];
        }
    }else if(tagNum == TITLE_TAG_NUM){
        if(!self.projecTitlePlaceholder.hidden){
            [self.projecTitlePlaceholder setHidden:YES];
        }
    }
}

#pragma mark - Textfield and Textview Delegates

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    [self hidePlaceholderIfPresent:textView];

    if(textView.tag == GOAL_TAG_NUM && [PAPUtility checkForPreIphone5]){
        [self moveKeyboardWhenSizingForOldIphones];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if(![self checkGoalContentIsSmallerThanFrame]){
        [self showGoalTooLongAlert];
    }
}

#pragma mark - Error Checking Methods

- (BOOL)isInputTypeValid:(NSString *)type{
    return [type isEqualToString:@"goal"] || [type isEqualToString:@"title"];
}

- (BOOL)checkGoalContentIsSmallerThanFrame{
    
   // NSLog(@"%f", self.projectGoal.contentSize.height);
   // NSLog(@"%f", self.projectGoal.frame.size.height);

    return YES;
}

- (BOOL)checkInputTextIsLessThanMaxLength:(NSString *)text type:(NSString *)type{

    BOOL isUnderMax = YES;
    
    if([self isInputTypeValid:type]){
        if([type isEqualToString:@"goal"] && [text length] > MAX_GOAL_LENGTH){
            isUnderMax = NO;
            [self showOverMaxLengthAlert:type maxLength:MAX_GOAL_LENGTH];
        }else if([type isEqualToString:@"title"] && [text length] > MAX_TITLE_LENGTH){
            isUnderMax = NO;
            [self showOverMaxLengthAlert:type maxLength:MAX_TITLE_LENGTH];
        }
    }
    
    return isUnderMax;
}

- (BOOL)validateBeforeSaving{
    
    BOOL areInputsNotEmpty = [self checkInputTextIsNotEmpty:self.projectTitle.text] && [self checkInputTextIsNotEmpty:self.projectGoal.text];
    BOOL isGoalContentSmallerThanFrameSize = [self checkGoalContentIsSmallerThanFrame];
    
    if(!areInputsNotEmpty){
        [self showEmptyInputAlert];
    }
    
    if(!isGoalContentSmallerThanFrameSize){
        [self showGoalTooLongAlert];
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

- (void)showGoalTooLongAlert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"Your goal is too long"
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

#pragma mark - Keyboard Default Settings Method

- (void)setKeyboardDefaultSettingsForInput{
    [self.projectTitle setTintColor:[UIColor whiteColor]];
    [self.projectGoal setTintColor:[UIColor whiteColor]];
    
    [self.projectTitle setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.projectTitle.textContainer setMaximumNumberOfLines:2];
    [self.projectTitle.textContainer setLineBreakMode:NSLineBreakByClipping];
    
    [self.projectGoal setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.projectGoal.textContainer setMaximumNumberOfLines:2];
    [self.projectGoal.textContainer setLineBreakMode:NSLineBreakByClipping];
}

- (void)moveKeyboardWhenSizingForOldIphones{
    [self.kbAvoidingScrollView setContentInset:UIEdgeInsetsMake(-100.0f, 0, 0, 0)];
}

@end
