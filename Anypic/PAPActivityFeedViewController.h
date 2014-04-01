//
//  PAPActivityFeedViewController.h
//  Teamstory
//
//

#import "PAPActivityCell.h"

@interface PAPActivityFeedViewController : PFQueryTableViewController <PAPActivityCellDelegate>

@property (nonatomic, strong) NSMutableArray *readList;

- (void)notificationSetup:(int)size;
+ (NSString *)stringForActivityType:(NSString *)activityType;


- (void)setActivityBadge:(NSString *)badge;


@end
