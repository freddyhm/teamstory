//
//  BFViewController.h
//  CropDemo
//
//  Created by John Nichols on 2/28/13.
//  Copyright (c) 2013 John Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFCropInterface.h"

@interface BFViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic,strong) NSString *imageSource;
@property (nonatomic, strong) IBOutlet UIImageView *displayImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) IBOutlet UIScrollView *moveImage;
@property (nonatomic, strong) BFCropInterface *cropper;


- (IBAction)cropPressed:(id)sender;
- (id)initWithImage:(UIImage *)aImage nib:(NSString *)nibNameOrNil source:(NSString *)imgSource;
    
@end
