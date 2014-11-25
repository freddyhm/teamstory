//
//  ImageCropper.h
//  Created by http://github.com/iosdeveloper
//

#import <UIKit/UIKit.h>

@protocol ImageCropperDelegate;

@interface ImageCropper : UIViewController <UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *imageView;

@property (nonatomic, assign) id <ImageCropperDelegate> delegate;

- (id)initWithImage:(UIImage *)image;

@end

@protocol ImageCropperDelegate <NSObject>
- (void)imageCropper:(ImageCropper *)cropper didFinishCroppingWithImage:(UIImage *)image;
- (void)imageCropperDidCancel:(ImageCropper *)cropper;
@end