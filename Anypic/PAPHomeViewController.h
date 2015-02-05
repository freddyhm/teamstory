//
//  PAPHomeViewController.h
//  Teamstory
//
//

#import "GAITrackedViewController.h"
#import "PhotoTimelineViewController.h"

@interface PAPHomeViewController : PhotoTimelineViewController <UIScrollViewDelegate, PostFooterViewDelegate>

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;
@property (nonatomic, strong) UIButton *feedbackBtn;
- (void)refreshCurrentFeed;
- (void)getActivityPoints;


@end
