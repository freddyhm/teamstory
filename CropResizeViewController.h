//
//  BFViewController.h
//  CropDemo
//
//  Created by John Nichols on 2/28/13.
//  Copyright (c) 2013 John Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CropResizeViewController : UIViewController <UIScrollViewDelegate>


- (IBAction)cropPressed:(id)sender;
- (id)initWithImage:(UIImage *)aImage nib:(NSString *)nibNameOrNil source:(NSString *)imgSource;
    
@end
