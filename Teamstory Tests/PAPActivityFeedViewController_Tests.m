//
//  Teamstory_Tests.m
//  Teamstory Tests
//
//  Created by Freddy Hidalgo-Monchez on 2014-10-15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import <objc/runtime.h>
#import "PAPActivityFeedViewController.h"


@interface PAPActivityFeedViewController_Tests : XCTestCase

@property PAPActivityFeedViewController *activityFeedViewController;
@property NSMutableArray *activityReadList;
@property XCTestExpectation *expecation;
@property PFUser *currentUser;

@end

@implementation PAPActivityFeedViewController_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.activityFeedViewController = [[PAPActivityFeedViewController alloc] init];
    
    self.activityReadList = [[NSMutableArray alloc]init];
    
    // set item to keep track of checked status
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"testid", @"photoId", @"unread", @"status", nil];
    // add item to our checklist
    [self.activityReadList addObject:item];
    
    // get current user object
    self.currentUser = [PFUser currentUser];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    self.activityReadList = nil;
    self.currentUser = nil;
    self.activityFeedViewController = nil;
    self.expecation = nil;
}

- (void)testCurrentUserIsNotNil{
    XCTAssertNotNil(self.currentUser);
}

- (void)testViewControllerHasReadListProperty{
    objc_property_t readListProperty = class_getProperty([self.activityFeedViewController class], "readList");
    XCTAssertTrue(readListProperty != NULL, @"View Controller needs a readList");
}


- (void)testCanCreateNewItemList{
    XCTAssertNotNil([[self.activityReadList objectAtIndex:0] objectForKey:@"status"]);
}

- (void)testViewControllerSetRemoteListWithLocalOneItemList{
    
    self.expecation = [self expectationWithDescription:@"set read list on server"];
    
    // set readlist for current user
    [self.currentUser setObject:self.activityReadList forKey:@"activityReadList"];
    
    // save object
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        XCTAssert(succeeded, @"Set array with one item in activityReadList");
        [self.expecation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testViewControllerSetRemoteListWithLocalTwoItemList{
    
    self.expecation = [self expectationWithDescription:@"set read list on server"];
    
    // set second item
    NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"testid2", @"photoId", @"unread", @"status", nil];
    
    // add second item to read list
    [self.activityReadList addObject:item2];
    
    // set readlist for current user
    [self.currentUser setObject:self.activityReadList forKey:@"activityReadList"];
    
    // save object
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        XCTAssert(succeeded, @"Set array with two items in activityReadList");
        [self.expecation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testViewControllerFetchedRemoteReadListIsArray{
    
    self.expecation = [self expectationWithDescription:@"fetch read list from server"];
    
    // set readlist for current user
    [self.currentUser setObject:self.activityReadList forKey:@"activityReadList"];
    
    // save object
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        XCTAssert([[self.currentUser objectForKey:@"activityReadList"] isKindOfClass:[NSArray class]]);
        [self.expecation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testViewControllerFetchedRemoteListItem{
    
    self.expecation = [self expectationWithDescription:@"fetch read list from server"];
    
    // set readlist for current user
    [self.currentUser setObject:self.activityReadList forKey:@"activityReadList"];
    
    // save object
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSArray *fetchedReadList = [self.currentUser objectForKey:@"activityReadList"];
        XCTAssertNotNil([[fetchedReadList objectAtIndex:0] objectForKey:@"status"]);
        [self.expecation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testViewControllerUpdateRemoteList{
    
    self.expecation = [self expectationWithDescription:@"modify list from server"];
    
    // set readlist for current user
    [self.currentUser setObject:self.activityReadList forKey:@"activityReadList"];
    
    // save object
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // replace object
        [[self.currentUser objectForKey:@"activityReadList"] setObject:@"test" atIndex:0];
        
        XCTAssertEqual([[self.currentUser objectForKey:@"activityReadList"] objectAtIndex:0], @"test");
        [self.expecation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testViewControllerSetUpdatedRemoteList{
    
    self.expecation = [self expectationWithDescription:@"set modified read list from server"];
    
    // set readlist for current user
    [self.currentUser setObject:self.activityReadList forKey:@"activityReadList"];
    
    // save object
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // replace object
        [[self.currentUser objectForKey:@"activityReadList"] setObject:@"test" atIndex:0];
        
        // save updated list
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            XCTAssertEqual([[self.currentUser objectForKey:@"activityReadList"] objectAtIndex:0], @"test");
            [self.expecation fulfill];
        
        }];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testViewControllerUpdateRemoteListItem{
    
    self.expecation = [self expectationWithDescription:@"modify list item from server"];
    
    // set readlist for current user
    [self.currentUser setObject:self.activityReadList forKey:@"activityReadList"];
    
    // save object
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // update item status
        [[[self.currentUser objectForKey:@"activityReadList"] objectAtIndex:0] setObject:@"read" forKey:@"status"];
        
        // get status
        NSString *status = [[[self.currentUser objectForKey:@"activityReadList"] objectAtIndex:0] objectForKey:@"status"];
        
        XCTAssertEqual(status, @"read");
        [self.expecation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testViewControllerSetUpdatedListItem{
    
    self.expecation = [self expectationWithDescription:@"set modified list item from server"];
    
    // set readlist for current user
    [self.currentUser setObject:self.activityReadList forKey:@"activityReadList"];
    
    // save object
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // update item status
        [[[self.currentUser objectForKey:@"activityReadList"] objectAtIndex:0] setObject:@"read" forKey:@"status"];
        
        // save updated item
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            XCTAssert(succeeded, @"Should save modified read list item");
            [self.expecation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testViewControllerSetUpdateListItemWithObjectId{
    
    self.expecation = [self expectationWithDescription:@"set specific list item"];
    
    // object id we want to update
    NSString *itemId = @"testid";
        
    // look for itemId in read list
    for (int i = 0; i < self.activityReadList.count; i++) {
        
        // get list item id in activityReadList
         NSString *listItemId = [[self.activityReadList objectAtIndex:i] objectForKey:@"photoId"];
      
        // update if we find a match
        if([listItemId isEqualToString:itemId]){
            
            // update read list item and set updated list to user object
            [[self.activityReadList objectAtIndex:i] setObject:@"read" forKey:@"status"];
            [self.currentUser setObject:self.activityReadList forKey:@"activityReadList"];
            
            // save updated read list
            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                XCTAssertEqual([[[self.currentUser objectForKey:@"activityReadList"] objectAtIndex:0] objectForKey:@"status"], @"read");
                [self.expecation fulfill];
            }];
        }
    }

    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
