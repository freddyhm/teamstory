//
//  AtMention.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-12-19.
//
//

#import <foundation/Foundation.h>

@interface AtMention : NSObject

@property (nonatomic, strong) NSMutableArray *userList;
+ (id)sharedAtMention;
- (void)getAllUsers:(void (^)(NSArray *objectsm, BOOL succeeded, NSError *error))completionBlock;

@end