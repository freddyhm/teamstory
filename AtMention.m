//
//  AtMention.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-12-19.
//
//

#import "AtMention.h"

@interface AtMention ()

@property PFQuery *userQuery;

@end

@implementation AtMention

#pragma mark Singleton Methods

+ (id)sharedAtMention {
    static AtMention *atMention = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        atMention = [[self alloc] init];
    });
    
    return atMention;
}

- (id)init {
    if (self = [super init]) {
        
        self.userQuery = [PFUser query];
        self.userQuery.limit = MAXFLOAT;
        [self.userQuery whereKeyExists:@"displayName"];
        [self.userQuery orderByAscending:@"displayName"];
    }
    return self;
}

- (void)getAllUsers:(void (^)(NSArray *objects, BOOL succeeded, NSError *error))completionBlock {
    
    [self.userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.userArray = [[NSMutableArray alloc] initWithArray:objects];
            return completionBlock(objects, YES, nil);
        }else{
            return completionBlock(nil, NO, error);
        }
    }];
}



/*
 

 [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
 [SVProgressHUD dismiss];
 if (!error) {
 self.userArray = [[NSMutableArray alloc] initWithArray:objects];
 self.atmentionUserArray = [[NSMutableArray alloc] init];
 self.filteredArray = objects;
 self.autocompleteTableView.backgroundColor = [UIColor clearColor];
 } else {
 NSLog(@"%@", error);
 }
 }]; } else {
 [SVProgressHUD dismiss];
 */




@end
