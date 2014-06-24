//
//  PAPHomeViewController.h
//  Teamstory
//
//

#import "GAITrackedViewController.h"
#import "PAPPhotoTimelineViewController.h"

@interface PAPHomeViewController : PAPPhotoTimelineViewController <UIScrollViewDelegate>

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;


@end
