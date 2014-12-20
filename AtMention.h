//
//  AtMention.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-12-19.
//
//

#import <foundation/Foundation.h>

@interface AtMention : NSObject

@property NSMutableArray *userArray;
+ (id)sharedAtMention;

- (void)getAllUsers:(void (^)(NSArray *objectsm, BOOL succeeded, NSError *error))completionBlock;


@end