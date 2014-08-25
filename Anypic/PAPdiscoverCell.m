//
//  PAPdiscoverCell.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-08-24.
//
//

#import "PAPdiscoverCell.h"

@implementation PAPdiscoverCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.imageViewButton1 = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 100.0f, 100.0f)];
        //[self.imageViewButton1 addTarget:self action:@selector(imageViewButton1Action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageViewButton1];
        
        self.imageViewButton2 = [[UIButton alloc] initWithFrame:CGRectMake(110.0f, 5.0f, 100.0f, 100.0f)];
        //[self.imageViewButton2 addTarget:self action:@selector(imageViewButton2Action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageViewButton2];
        
        self.imageViewButton3 = [[UIButton alloc] initWithFrame:CGRectMake(215.0f, 5.0f, 100.0f, 100.0f)];
        //[self.imageViewButton3 addTarget:self action:@selector(imageViewButton3Action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageViewButton3];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setImage1:(PFFile *)image1 setImage2:(PFFile *)image2 setImage3:(PFFile *)image3 {
    [image1 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageViewButton1 setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        });
        
    }];
    
    [image2 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageViewButton2 setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        });
        
    }];
    
    [image3 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageViewButton3 setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        });
        
    }];
}

- (void) imageViewButton1Action:(id)sender{
    
}

- (void) imageViewButton2Action:(id)sender{
    
}

- (void) imageViewButton3Action:(id)sender{
    
}

/*
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}
 */

@end
