//
//  ThoughtPostViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-05-22.
//
//

#import <UIKit/UIKit.h>

@interface ThoughtPostViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *submit;

- (IBAction)saveEdit:(id)sender;


@end
