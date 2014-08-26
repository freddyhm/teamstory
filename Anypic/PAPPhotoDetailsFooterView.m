//
//  PAPPhotoDetailsFooterView.m
//  Teamstory
//
//

#import "PAPPhotoDetailsFooterView.h"
#import "PAPUtility.h"

@interface PAPPhotoDetailsFooterView ()

@end

@implementation PAPPhotoDetailsFooterView

@synthesize commentField;
@synthesize mainView;
@synthesize hideDropShadow;
@synthesize commentView;


#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 51.0f)];
        mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mainView];
        
        /*
        commentField = [[UITextField alloc] initWithFrame:CGRectMake( 40.0f, 10.0f, 255.0f, 31.0f)];
        commentField.backgroundColor = [UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
        commentField.font = [UIFont systemFontOfSize:12.0f];
        commentField.placeholder = @"Add a comment";
        commentField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        commentField.leftViewMode = UITextFieldViewModeAlways;
        commentField.returnKeyType = UIReturnKeySend;
        commentField.textColor = [UIColor colorWithRed:119.0f/255.0f green:119.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
        commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [commentField setValue:[UIColor colorWithRed:154.0f/255.0f green:146.0f/255.0f blue:138.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"]; // Are we allowed to modify private properties like this? -Héctor
        [mainView addSubview:commentField];
         */
         
         
        
        commentView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 299.0f, 31.0f)];
        commentView.backgroundColor = [UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
        commentView.font = [UIFont systemFontOfSize:12.0f];
        commentView.text = @"Add a comment";
        //commentView.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        //commentView.leftViewMode = UITextFieldViewModeAlways;
        commentView.returnKeyType = UIReturnKeySend;
        commentView.textColor = [UIColor colorWithRed:119.0f/255.0f green:119.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
        //commentView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //[commentView setValue:[UIColor colorWithRed:154.0f/255.0f green:146.0f/255.0f blue:138.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"]; // Are we allowed to modify private properties like this? -Héctor
        
        [mainView addSubview:commentView];
        
        /*
        // Set comment send button
        self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(commentView.frame.origin.x + commentView.frame.size.width + 10, commentView.frame.origin.y, 31.0f, 31.0f)];
        [self.sendBtn setBackgroundColor:[UIColor redColor]];
        [mainView addSubview:self.sendBtn];
        */ 
        
        
    }
    return self;
}


#pragma mark - UIView
/*
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!hideDropShadow) {
        [PAPUtility drawSideAndBottomDropShadowForRect:mainView.frame inContext:UIGraphicsGetCurrentContext()];
    }
}
*/

#pragma mark - PAPPhotoDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, 305.0f, 69.0f);
}

+ (CGRect)rectForEditView {
    return CGRectMake( 0.0f, 0.0f, 305.0f, 100.0f);
}

@end
