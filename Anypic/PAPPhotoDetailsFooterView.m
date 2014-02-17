//
//  PAPPhotoDetailsFooterView.m
//  Teamstory
//
//

#import "PAPPhotoDetailsFooterView.h"
#import "PAPUtility.h"

@interface PAPPhotoDetailsFooterView ()
@property (nonatomic, strong) UIView *mainView;
@end

@implementation PAPPhotoDetailsFooterView

@synthesize commentField;
@synthesize mainView;
@synthesize hideDropShadow;


#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake( 7.5f, 0.0f, 305.0f, 51.0f)];
        mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mainView];
        
        UIImageView *messageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconAddComment.png"]];
        messageIcon.frame = CGRectMake( 4.0f, 10.0f, 30.0f, 30.0f);
        [mainView addSubview:messageIcon];
        
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
    }
    return self;
}


#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!hideDropShadow) {
        [PAPUtility drawSideAndBottomDropShadowForRect:mainView.frame inContext:UIGraphicsGetCurrentContext()];
    }
}


#pragma mark - PAPPhotoDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 69.0f);
}

@end
