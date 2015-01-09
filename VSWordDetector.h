//
//  VSWordDetector.h
//  VSWordDetector
//
//  Created by TheTiger on 05/02/14.
//  Copyright (c) 2014 TheTiger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSWordDetector;

@protocol VSWordDetectorDelegate <NSObject>
-(void)wordDetector:(VSWordDetector *)wordDetector detectWord:(NSString *)word;
@end

@interface VSWordDetector : NSObject

-(id)initWithDelegate:(id<VSWordDetectorDelegate>)delegate;
-(void)addOnView:(id)view;

@end
