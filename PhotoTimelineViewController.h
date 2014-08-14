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
#import <UIKit/UIKit.h>

@interface PhotoTimelineViewController : UIViewController <PAPPhotoHeaderViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *feed;
@property (strong, nonatomic) IBOutlet NSMutableArray *objects;
@property (nonatomic, strong) PFQuery *loadQuery;

- (BOOL)objectsDidLoad:(NSError *)error;
- (void)loadObjects:(void (^)(BOOL succeeded))completionBlock isRefresh:(BOOL)isRefresh;


@end
