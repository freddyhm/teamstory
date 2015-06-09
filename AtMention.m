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
        self.userQuery.limit = 1000;
        [self.userQuery whereKeyExists:@"displayName"];
        [self.userQuery orderByAscending:@"displayName"];
    }
    return self;
}

- (void)getAllUsers:(void (^)(NSArray *objects, BOOL succeeded, NSError *error))completionBlock {
    
    // get all user objects in database
    [self.userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            // add objects to our user list
            self.userList = [[NSMutableArray alloc]initWithArray:objects];
            
            // get the next 1000, will have to refactor to auto skip based on user count
            self.userQuery.skip = 1000;
            
            [self.userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error){
                    
                    // add objects to our user list
                    [self.userList addObjectsFromArray:objects];
                    
                    return completionBlock(objects, YES, nil);
                }else{
                    return completionBlock(nil, NO, error);
                }
            }];
            
        }else{
            return completionBlock(nil, NO, error);
        }
    }];
}


@end
