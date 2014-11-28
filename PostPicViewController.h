//
//  PostPicViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-11-24.
//
//

#import <UIKit/UIKit.h>

@interface PostPicViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate, UITableViewDelegate>

- (id)initWithImage:(UIImage *)originalImg source:(NSString *)source;

@end
