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
@property NSMutableDictionary *activityReadList;
@property XCTestExpectation *expecation;
@property PFUser *currentUser;

@end

@implementation PAPActivityFeedViewController_Tests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // remove activity read list for current user for testing purposes
    [[PFUser currentUser] removeObjectForKey:@"activityReadList"];
    
    // new controller instance
    self.activityFeedViewController = [[PAPActivityFeedViewController alloc] init];
    
    // get current user object
    self.currentUser = [PFUser currentUser];

    // get readlist from property
    self.activityReadList = self.activityFeedViewController.activityReadList;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    self.activityReadList = nil;
    self.currentUser = nil;
    self.activityFeedViewController = nil;
    self.expecation = nil;
}

#pragma mark - Core

- (void)testCurrentUserIsNotNil{
    XCTAssertNotNil(self.currentUser);
}

- (void)testViewControllerHasReadListProperty{
    objc_property_t readListProperty = class_getProperty([self.activityFeedViewController class], "activityReadList");
    XCTAssertTrue(readListProperty != NULL, @"View Controller needs an activityReadList");
}

#pragma mark - Adding To List

- (void)testViewControllerAddOneActivityWithCustomAttributesToList{
    
    // add new item
    NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"unread", @"status", nil];
    
    // set it in our read list
    [self.activityFeedViewController addActivityToReadList:@"testActId" postId:@"testPostId" customAttributes:newAttributes];
    
    // get item 
    NSMutableDictionary *item = [self.activityFeedViewController.activityReadList objectForKey:@"testActId"];
    
    // check if new item was added with proper attributes
    XCTAssertEqualObjects([item objectForKey:@"status"], @"unread");
}

- (void)testViewControllerAddActivityWithNoAttributes{
    
    // set it in our read list
    [self.activityFeedViewController addActivityToReadList:@"testActId" postId:@"testPostId" customAttributes:nil];

    // get item
    NSMutableDictionary *item = [self.activityFeedViewController.activityReadList objectForKey:@"testActId"];
    
    // check if new item was added with default attributes
    XCTAssertEqualObjects([item objectForKey:@"status"], @"unread");
}

- (void)testViewControllerAddActivityWithNoPostId{
    
    // set it in our read list
    [self.activityFeedViewController addActivityToReadList:@"testActId" postId:nil customAttributes:nil];
    
    // get item
    NSMutableDictionary *item = [self.activityFeedViewController.activityReadList objectForKey:@"testActId"];
    
    // check if new item was added with default attributes
    XCTAssertEqualObjects([item objectForKey:@"postId"], @"");
}

- (void)testViewControllerAddActivityWithNoActivityId{
    
    // check if new item was added with default attributes
    XCTAssertNoThrow([self.activityFeedViewController addActivityToReadList:nil postId:@"testPostId" customAttributes:nil]);
}

- (void)testViewControllerAddActivityWithNoIds{
    // check if adding an item with no id throws an rerror
    XCTAssertNoThrow([self.activityFeedViewController addActivityToReadList:nil postId:nil customAttributes:nil]);
}


- (void)testViewControllerAddTwoActivitiesWithAttributesToList{
    
    // add new item
    NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"read", @"status", nil];
    
    // add new item2
    NSMutableDictionary *newItem2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"unread", @"status", nil];
    
    // add items to our readlist
    [self.activityFeedViewController addActivityToReadList:@"testActId" postId:@"testPostId" customAttributes:newItem];
    [self.activityFeedViewController addActivityToReadList:@"testActId2" postId:@"testPostId2" customAttributes:newItem2];
    
    // get item2
    NSMutableDictionary *item = [self.activityFeedViewController.activityReadList objectForKey:@"testActId2"];
    
    // check if new item was added with proper attributes
    XCTAssertEqualObjects([item objectForKey:@"status"], @"unread");
}

#pragma mark - Search List

- (void)testViewControllerFindActivityWithActivityId{
    
    // object id we want to update
    NSString *activityId = @"testActId";
    
    // add items to our readlist
    [self.activityFeedViewController addActivityToReadList:activityId postId:@"testPostId" customAttributes:nil];
    
    // get item with id
    NSMutableDictionary *item = [self.activityFeedViewController findActivityInReadList:activityId];
    
    XCTAssertNotNil(item);
}


- (void)testViewControllerFindActivityWithMissingActivityId{
    
    // add items to our readlist
    [self.activityFeedViewController addActivityToReadList:@"testActId" postId:@"testPostId" customAttributes:nil];
    
    // object id that doesn't exist
    NSString *activityId = @"testActId2";
    
    // get item with id
    NSMutableDictionary *item = [self.activityFeedViewController findActivityInReadList:activityId];
    
    XCTAssertNil(item);
}

- (void)testViewControllerFindActivityWithNoItemId{
    XCTAssertNil([self.activityFeedViewController findActivityInReadList:nil]);
}

- (void)testViewControllerGetStatusWithActivityId{
    
    // object id we're adding
    NSString *activityId = @"testActId";
    
    // add items to our readlist
    [self.activityFeedViewController addActivityToReadList:activityId postId:@"testPostId" customAttributes:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"YOO", @"status", nil]];

    // get status of item
    NSString *status = [self.activityFeedViewController getStatusForActivityInReadList:activityId];
    
    XCTAssertEqualObjects(status, @"YOO");
}

- (void)testViewControllerGetStatusWithoutActivityId{
    XCTAssertNoThrow([self.activityFeedViewController getStatusForActivityInReadList:nil]);
}

- (void)testViewControllerGetStatusWithWrongActivityId{
    XCTAssertNil([self.activityFeedViewController getStatusForActivityInReadList:@"dsfsadjl"]);
}

#pragma mark - Update List

- (void)testViewControllerUpdateActivityWithActivityId{
    
    // object id we want to update
    NSString *activityId = @"testActId";
    
    // add items to our readlist
    [self.activityFeedViewController addActivityToReadList:activityId postId:@"testPostId" customAttributes:nil];
    
    // update activity
    [self.activityFeedViewController updateStatusForActivityInReadList:activityId newStatus:@"read"];
    
    // get item with id
    NSMutableDictionary *item = [self.activityReadList valueForKey:activityId];
    
    // check if change took place
    XCTAssertEqualObjects([item objectForKey:@"status"], @"read");
}

- (void)testViewControllerUpdateAllActivitiesWithSamePostId{
    
    NSString *firstActivity = @"testActId";
    NSString *secondActivity = @"testActId2";
    NSString *postId = @"testPostId";
    
    // add items to our readlist
    [self.activityFeedViewController addActivityToReadList:firstActivity postId:postId customAttributes:nil];
    // add items to our readlist
    [self.activityFeedViewController addActivityToReadList:secondActivity postId:postId customAttributes:nil];
    
    // update activity
    [self.activityFeedViewController updateStatusForActivityInReadList:firstActivity newStatus:@"read"];
    
    // get item of second activity
    NSMutableDictionary *item = [self.activityReadList valueForKey:secondActivity];
    
    // check if change took place for second activity
    XCTAssertEqualObjects([item objectForKey:@"status"], @"read");
}


- (void)testViewControllerUpdateActivityWithoutActivityId{
    // check if adding an activity with no id throws an rerror
    XCTAssertNoThrow([self.activityFeedViewController updateStatusForActivityInReadList:nil newStatus:@"read"]);
}


- (void)testViewControllerUpdateNonExistingActivityId{
    // check if update non-existing activity throws an error
    XCTAssertNoThrow([self.activityFeedViewController updateStatusForActivityInReadList:@"random" newStatus:@"read"]);
}

#pragma mark - Save & Fetch From Server

- (void)testSaveReadList{
    
    self.expecation = [self expectationWithDescription:@"saving read list"];
    
    // save list
    [self.activityFeedViewController saveReadList:^(BOOL success, NSError *error) {
        XCTAssert(success);
        [self.expecation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testFetchReadListNoErrors{
    
    self.expecation = [self expectationWithDescription:@"fetch read list form server"];
    
    // save and fetch
    [self.activityFeedViewController fetchReadListFromServer:^(id readList, NSError *error) {
        XCTAssertNil(error);
        [self.expecation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testFetchMissingReadList{
    
    self.expecation = [self expectationWithDescription:@"fetch read list form server"];
    
    // remove activity read list
    [self.currentUser removeObjectForKey:@"activityReadList"];
    
    // fetch missing read list
    [self.activityFeedViewController fetchReadListFromServer:^(id readList, NSError *error) {
        if(!error){
            // check if field is nil
            XCTAssertNil(readList);
            [self.expecation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testSaveAndFetchEmptyReadList{
    
    self.expecation = [self expectationWithDescription:@"saving read list"];
    
    // save & fetch empty list
    [self.activityFeedViewController saveReadList:^(BOOL success, NSError *error) {
        if(success){
            [self.activityFeedViewController fetchReadListFromServer:^(id readList, NSError *error) {
                if(!error){
                    XCTAssertEqual([readList count], 0);
                    [self.expecation fulfill];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}


- (void)testViewControllerFetchedReadListIsMutableDictionary{
    
    self.expecation = [self expectationWithDescription:@"fetch read list from server"];
    
    // save empty list
    [self.activityFeedViewController saveReadList:^(BOOL success, NSError *error) {
        if(success){
            // fetch empty list
            [self.activityFeedViewController fetchReadListFromServer:^(id readList, NSError *error) {
                if(!error){
                    // check if readlist is a mutable dictionary
                    XCTAssert([readList isKindOfClass:[NSMutableDictionary class]]);
                    [self.expecation fulfill];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testViewControllerSaveReadListWithOneItem{
    
    self.expecation = [self expectationWithDescription:@"fetch read list form server"];

    // add items to our readlist
    [self.activityFeedViewController addActivityToReadList:@"testActId" postId:@"testPostId" customAttributes:nil];
    
    // save current read list
    [self.activityFeedViewController saveReadList:^(BOOL success, NSError *error) {
        
        if(success){
            // fetch read list
            [self.activityFeedViewController fetchReadListFromServer:^(id readList, NSError *error) {
                // check if item added on server
                XCTAssertEqual([readList count], 1);
                [self.expecation fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testViewControllerSaveReadListWithTwoItems{
    
    self.expecation = [self expectationWithDescription:@"fetch read list form server"];
    
    // add activities to our readlist
    [self.activityFeedViewController addActivityToReadList:@"testActId" postId:@"testPostId" customAttributes:nil];
    [self.activityFeedViewController addActivityToReadList:@"testActId2" postId:@"testPostId2" customAttributes:nil];
    
    // save current read list
    [self.activityFeedViewController saveReadList:^(BOOL success, NSError *error) {
        
        if(success){
            
            // fetch read list
            [self.activityFeedViewController fetchReadListFromServer:^(id readList, NSError *error) {
                
                // check if two items added on server
                XCTAssertEqual([readList count], 2);
                [self.expecation fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

# pragma mark - Remove & Save On Server

- (void)testViewControllerRemoveItemAndSave{
    
    self.expecation = [self expectationWithDescription:@"fetch read list form server"];
    
    // add items to our readlist
    [self.activityFeedViewController addActivityToReadList:@"testActId" postId:@"testPostId" customAttributes:nil];
    [self.activityFeedViewController addActivityToReadList:@"testActId2" postId:@"testPostId2" customAttributes:nil];
    
    // save current read list
    [self.activityFeedViewController saveReadList:^(BOOL success, NSError *error) {
        
        if(success){
            
            // remove item from list
            [self.activityReadList removeObjectForKey:@"testActId"];
            
            // save modified list
            [self.activityFeedViewController saveReadList:^(BOOL success, NSError *error) {
                // fetch updated list
                [self.activityFeedViewController fetchReadListFromServer:^(id readList, NSError *error) {
                   
                    // check if only one item
                    XCTAssertEqual([readList count], 1);
                    [self.expecation fulfill];
                }];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
