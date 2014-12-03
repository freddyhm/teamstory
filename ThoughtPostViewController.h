//
//  ThoughtPostViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-05-22.
//
//

#import <UIKit/UIKit.h>

@protocol ThoughtPostViewControllerDelegate <NSObject>;
- (void)didUploadThought;
@end

@interface ThoughtPostViewController : UIViewController <UITextViewDelegate>
@property (nonatomic, weak) id<ThoughtPostViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImg;
@property (strong, nonatomic) IBOutlet UIImageView *placeholder;
@property (strong, nonatomic) IBOutlet UITextView *thoughtTextView;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipe;
@property (strong, nonatomic) IBOutlet UIButton *rightNavSelector;
@property (strong, nonatomic) IBOutlet UIButton *leftNavSelector;
@property (strong, nonatomic) IBOutlet UIImageView *placeholderSign;

- (IBAction)rightNav:(id)sender;
- (IBAction)leftNav:(id)sender;
@end


