//
//  ImageTextViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-05-18.
//
//

#import <UIKit/UIKit.h>

@interface ImageTextViewController : UIViewController <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *submit;
- (IBAction)saveImg:(id)sender;

@end
