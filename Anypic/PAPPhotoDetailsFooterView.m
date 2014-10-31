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
        
        commentView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 299.0f, 31.0f)];
        commentView.backgroundColor = [UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
        commentView.font = [UIFont systemFontOfSize:12.0f];
        commentView.text = @"Add a comment";
        commentView.returnKeyType = UIReturnKeySend;
        commentView.textColor = [UIColor colorWithRed:119.0f/255.0f green:119.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
        [mainView addSubview:commentView];
    }
    return self;
}

#pragma mark - PAPPhotoDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, 305.0f, 69.0f);
}

+ (CGRect)rectForEditView {
    return CGRectMake( 0.0f, 0.0f, 305.0f, 100.0f);
}



@end
