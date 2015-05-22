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

@interface ProjectPostViewControllerTest : XCTestCase

@property (nonatomic) ProjectPostViewController *vc;

@end

@implementation ProjectPostViewControllerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.vc = [[ProjectPostViewController alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
