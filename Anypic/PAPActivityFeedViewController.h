//
//  PAPActivityFeedViewController.h
//  Teamstory
//
//

#import "PAPActivityCell.h"

@interface PAPActivityFeedViewController : PFQueryTableViewController <PAPActivityCellDelegate>

@property BOOL loadedWithViewNotification;
@property (nonatomic, strong) NSMutableArray *readList;

- (void)notificationSetup;
+ (NSString *)stringForActivityType:(NSString *)activityType;


- (void)setActivityBadge:(NSString *)badge;


@end
