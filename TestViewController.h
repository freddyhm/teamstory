//
//  TestViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-11-07.
//
//

#import <UIKit/UIKit.h>
#import "CustomKeyboardViewController.h"

@interface TestViewController : UIViewController <CustomKeyboardViewControllerDelegate>
@property (nonatomic, retain) CustomKeyboardViewController *customKeyboard;

@end
