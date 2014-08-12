//
//  PAPHomeViewController.h
//  Teamstory
//
//

#import "GAITrackedViewController.h"
#import "PAPPhotoTimelineViewController.h"
#import "PhotoTimelineViewController.h"

@interface PAPHomeViewController : PhotoTimelineViewController <UIScrollViewDelegate>

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;


@end
