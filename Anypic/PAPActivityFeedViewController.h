//
//  PAPActivityFeedViewController.h
//  Teamstory
//
//

#import "PAPActivityCell.h"

@interface PAPActivityFeedViewController : PFQueryTableViewController <PAPActivityCellDelegate>

@property (nonatomic, strong) NSMutableArray *readList;

- (void)notificationSetup:(int)size source:(NSString *)source;
+ (NSString *)stringForActivityType:(NSString *)activityType;


- (void)setActivityBadge:(NSString *)badge;
- (void)updateReadList:(int)size source:(NSString *)source;


@end
