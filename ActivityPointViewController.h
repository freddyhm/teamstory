//
//  ActivityPointViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-01-29.
//
//

#import <UIKit/UIKit.h>

@interface ActivityPointViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *points;

@end
