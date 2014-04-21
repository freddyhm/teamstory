//
//  PAPActivityFeedViewController.h
//  Teamstory
//
//

#import "PAPActivityCell.h"

@interface PAPActivityFeedViewController : PFQueryTableViewController <PAPActivityCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *readList;

+ (NSString *)stringForActivityType:(NSString *)activityType;


- (void)setActivityBadge:(NSString *)badge;
- (void)updateReadList:(NSString *)itemPhotoId;
- (void)addToReadList:(NSString *)itemPhotoId itemActivityId:(NSString *)itemActivityId;


@end
