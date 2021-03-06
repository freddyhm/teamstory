//
//  PhotoTimelineViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-07-29.
//
//

#import "PAPPhotoHeaderView.h"
#import "PostFooterView.h"
#import "PAPPhotoDetailsViewController.h"
#import "PAPPhotoCell.h"
#import <UIKit/UIKit.h>

@interface PhotoTimelineViewController : UIViewController <PAPPhotoHeaderViewDelegate, PostFooterViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, PAPPhotoCellDelegate, UIActivityItemSource, UIPopoverPresentationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *feed;
@property (strong, nonatomic) IBOutlet NSMutableArray *objects;
@property (nonatomic, strong) UIView *texturedBackgroundView;
@property (nonatomic, strong) PFQuery *loadQuery;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView *extendBgView;
@property BOOL inviteButtonCheckForShare;

- (BOOL)objectsDidLoad:(NSError *)error;
- (void)loadObjects:(void (^)(BOOL succeeded))completionBlock isRefresh:(BOOL)isRefresh fromSource:(NSString *)fromSource;
- (NSIndexPath *)getIndexPathForFeed:(NSString *)feed;
- (NSString *)getFeedSourceType;


@end
