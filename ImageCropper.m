//
//  ImageCropper.m
//  Created by http://github.com/iosdeveloper
//

#import "ImageCropper.h"

@implementation ImageCropper

@synthesize scrollView, imageView;
@synthesize delegate;

- (id)initWithImage:(UIImage *)image {
	self = [super init];
	
	if (self) {

		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,0.0, self.view.frame.size.width, 380.0)];
		[scrollView setBackgroundColor:[UIColor blackColor]];
		[scrollView setDelegate:self];
		[scrollView setShowsHorizontalScrollIndicator:NO];
		[scrollView setShowsVerticalScrollIndicator:NO];
		[scrollView setMaximumZoomScale:2.0];
		
		imageView = [[UIImageView alloc] initWithImage:image];
		
		CGRect rect;
		rect.size.width = image.size.width;
		rect.size.height = image.size.height;
		
		[imageView setFrame:rect];
		
		[scrollView setContentSize:[imageView frame].size];
		[scrollView setMinimumZoomScale:[scrollView frame].size.width / [imageView frame].size.width];
		[scrollView setZoomScale:[scrollView minimumZoomScale]];
		[scrollView addSubview:imageView];
		
		[[self view] addSubview:scrollView];
	}
	
	return self;
}

- (void)cancelCropping {
	[delegate imageCropperDidCancel:self]; 
}

- (void)finishCropping {
	float zoomScale = 1.0 / [scrollView zoomScale];
	
	CGRect rect;
	rect.origin.x = [scrollView contentOffset].x * zoomScale;
	rect.origin.y = [scrollView contentOffset].y * zoomScale;
	rect.size.width = [scrollView bounds].size.width * zoomScale;
	rect.size.height = [scrollView bounds].size.height * zoomScale;
	
	CGImageRef cr = CGImageCreateWithImageInRect([[imageView image] CGImage], rect);
	
	UIImage *cropped = [UIImage imageWithCGImage:cr];
	
	CGImageRelease(cr);
	
	[delegate imageCropper:self didFinishCroppingWithImage:cropped];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}


@end