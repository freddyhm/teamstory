//
//  PAPActivityFeedViewController.h
//  Teamstory
//
//

#import "PAPActivityCell.h"

@interface PAPActivityFeedViewController : PFQueryTableViewController <PAPActivityCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *readList;

- (void)notificationSetup:(int)size source:(NSString *)source;
+ (NSString *)stringForActivityType:(NSString *)activityType;


- (void)setActivityBadge:(NSString *)badge;
- (void)updateReadList:(NSString *)itemPhotoId;


@end
