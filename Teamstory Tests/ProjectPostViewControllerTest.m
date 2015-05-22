//
//  ProjectPostViewControllerTest.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-05-22.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ProjectPostViewController.h"
#import "FakeTextContainer.h"

@interface ProjectPostViewController ()

- (UITextField *)projectTitle;
- (UITextView *)projectGoal;
- (UITextField *)projectDueDate;

@end

@interface ProjectPostViewControllerTest : XCTestCase

@property (nonatomic) ProjectPostViewController *vc;
@property(nonatomic, assign) NSUInteger countShowAlert;
@property(nonatomic, retain) NSString *lastShowAlertMessage;

@end

// Check if textfield goes over a certain amount

// Check if all fields are filled before saving

// Check if alertview is shown if fields aren't within criteria when finishing editing

// Check if alertview is shown if fields aren't within criteria at saving

// Check keyboard height is proper

// UI tweaks

// Add auto layout and check it sizes properly for all devices

// Check if regular thought isn't affected


@implementation ProjectPostViewControllerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.vc = [[ProjectPostViewController alloc] initWithNibName:@"ProjectPostViewController" bundle:nil];
    
    [self.vc view];
}

- (void)testTitleInputIsLessThanMaxChar{
    NSString *titleText = self.vc.projectTitle.text;
    XCTAssertLessThan([titleText length], 10, @"Title must be less than 10 characters");
}

- (void)testGoalInputIsLessThanMaxChar{
    NSString *goalText = self.vc.projectTitle.text;
    XCTAssertLessThan([goalText length], 80, @"Goal must be less than 80 characters");
}

- (void)testDueDateInputIsLessThanMaxChar{
    NSString *dueDateText = self.vc.projectTitle.text;
    XCTAssertLessThan([dueDateText length], 10, @"Title must be less than 10 characters");
}

- (void)testThatTitleInputHasPlaceholder{
    NSString *titlePlaceholder = self.vc.projectTitle.placeholder;
    XCTAssertNotNil(titlePlaceholder, @"Title placeholder should be set");
}

- (void)testThatGoalInputHasPlaceholder{
    NSString *projDueDatePlaceholder = self.vc.projectGoal.text;
    XCTAssertFalse([projDueDatePlaceholder isEqualToString:@""], @"Goal placeholder should be set");
}

- (void)testThatDueDateInputHasPlaceholder{
    NSString *projDueDatePlaceholder = self.vc.projectDueDate.placeholder;
    XCTAssertNotNil(projDueDatePlaceholder, @"Due Date placeholder should be set");
}

- (void)testTitleInputOverMaxCharShowsAlert{
    
    NSString *longTitle = @"sdfakl;jdsfl;afkljdas;fjasd;fkj";
    
    if([longTitle length] > 10){
        [self showAlertWithMessage:@"over max char"];
    }
    
    XCTAssertEqual(self.countShowAlert, 1);
}

- (void)showAlertWithMessage:(NSString *)message
{
    ++self.countShowAlert;
    [self setLastShowAlertMessage:message];
}



- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

+ (Class)alertViewClass{
    return [UIAlertView class];
}


@end
