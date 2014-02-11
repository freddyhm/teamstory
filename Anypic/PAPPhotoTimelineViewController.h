//
//  PAPPhotoTimelineViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import "PAPPhotoHeaderView.h"

@interface PAPPhotoTimelineViewController : PFQueryTableViewController <PAPPhotoHeaderViewDelegate, UIScrollViewDelegate>

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView;

@end
