//
//  ThoughtPostViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-05-22.
//
//

#import <UIKit/UIKit.h>

@interface ThoughtPostViewController : UIViewController <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImg;
@property (strong, nonatomic) IBOutlet UIImageView *placeholder;
@property (strong, nonatomic) IBOutlet UITextView *thoughtTextView;
- (IBAction)rightNav:(id)sender;
- (IBAction)leftNav:(id)sender;
- (void)exitPost;

@end
