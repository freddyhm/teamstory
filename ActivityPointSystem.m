//
//  ActivityPointSystem.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-05-12.
//
//

#import "ActivityPointSystem.h"

@implementation ActivityPointSystem

+ (id)sharedActivityPointSystem {
    static ActivityPointSystem *activityPointSystem = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        activityPointSystem = [[self alloc] init];
    });
    
    return activityPointSystem;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)getActivityPointsOnFirstRun{
    
    // get points from user
    self.activityPoints = [[PFUser currentUser] objectForKey:@"activityPoints"];
    
    // check if we have points already, set 100 as default if not
    if(self.activityPoints == nil){
        [self setDefaultPoints];
    }
}

- (void)setDefaultPoints{
    // start with 100
    self.activityPoints = [NSNumber numberWithInt:100];
    [self saveCurrentActivityPoints];
}

- (void)addPointToActivityCount:(NSString *)activityType{
    
    int points = 0;
    
    if([activityType isEqualToString:@"comment"]){
        points = 1;
    }else if([activityType isEqualToString:@"post"]){
        points = 2;
    }
    
    self.activityPoints = [NSNumber numberWithInt:[self.activityPoints intValue] + points];
    [self saveCurrentActivityPoints];
}

- (void)saveCurrentActivityPoints{
    [[PFUser currentUser] setObject:self.activityPoints forKey:@"activityPoints"];
    [[PFUser currentUser] saveInBackground];
}


@end
