//
//  PAPPhotoTimelineViewController.h
//  Teamstory
//
//

#import "PAPPhotoHeaderView.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface PAPPhotoTimelineViewController : PFQueryTableViewController <PAPPhotoHeaderViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView;
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;

@end
