//
//  ActivityPointSystem.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-05-12.
//
//

#import <Foundation/Foundation.h>

@interface ActivityPointSystem : NSObject

@property (nonatomic, strong) NSNumber *activityPoints;
+ (id)sharedActivityPointSystem;
- (void)addPointToActivityCount:(NSString *)activityType;
- (void)getActivityPointsOnFirstRun;

@end
