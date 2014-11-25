//
//  PostPicViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-11-24.
//
//

#import <UIKit/UIKit.h>

@interface PostPicViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *cropScrollView;
@property (nonatomic, strong) IBOutlet UIImageView *cropImgView;
@property (nonatomic, strong) UIImage *originalImg;

- (id)initWithNibName:(NSString *)nibNameOrNil originalImg:(UIImage *)originalImg bundle:(NSBundle *)nibBundleOrNil;

@end
