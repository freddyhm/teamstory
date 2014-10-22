//
//  PAPActivityFeedViewController.h
//  Teamstory
//
//

#import "PAPActivityCell.h"

@interface PAPActivityFeedViewController : PFQueryTableViewController <PAPActivityCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *readList;
@property (nonatomic, strong) NSMutableDictionary *activityReadList;

+ (NSString *)stringForActivityType:(NSString *)activityType object:(PFObject *)object;


- (void)setActivityBadge:(NSString *)badge;
- (void)fetchReadListFromServer:(void (^)(id readList, NSError*error))completionBlock;
- (void)addActivityToReadList:(NSString *)activityId postId:(NSString *)postId customAttributes:(NSMutableDictionary *)attributes;
- (void)saveReadList:(void (^)(BOOL success, NSError*error))completionBlock;
- (void)updateStatusForActivityInReadList:(NSString *)activityId newStatus:(NSString *)newStatus;
- (void)setActivityReadList;
- (NSMutableDictionary *)findActivityInReadList:(NSString *)activityId;
- (NSString *)getStatusForActivityInReadList:(NSString *)activityId;

@end
