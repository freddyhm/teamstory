//
//  PAPwebviewViewController.h
//  Teamstory
//
//  Created by Tobok Lee on 2/19/14.
//
//

#import <UIKit/UIKit.h>

@interface PAPwebviewViewController : UIViewController <UIWebViewDelegate,UIActionSheetDelegate>

- (id)initWithWebsite:(NSString *)website;
@end
