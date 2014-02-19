//
//  PAPPhotoTimelineViewController.h
//  Teamstory
//
//

#import "PAPPhotoHeaderView.h"

@interface PAPPhotoTimelineViewController : PFQueryTableViewController <PAPPhotoHeaderViewDelegate, UIScrollViewDelegate>

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView;

@end
