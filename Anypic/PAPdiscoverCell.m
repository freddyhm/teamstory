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
        [self addSubview:self.imageViewButton1];
        
        self.imageViewButton2 = [[UIButton alloc] initWithFrame:CGRectMake(110.0f, 5.0f, 100.0f, 100.0f)];
        [self addSubview:self.imageViewButton2];
        
        self.imageViewButton3 = [[UIButton alloc] initWithFrame:CGRectMake(215.0f, 5.0f, 100.0f, 100.0f)];
        [self addSubview:self.imageViewButton3];
        
        self.PFimageViewForButton1 = [[PFImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.imageViewButton1.bounds.size.width, self.imageViewButton1.bounds.size.height)];
        [self.imageViewButton1 addSubview:self.PFimageViewForButton1];
        
        self.PFimageViewForButton2 = [[PFImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.imageViewButton2.bounds.size.width, self.imageViewButton2.bounds.size.height)];
        [self.imageViewButton2 addSubview:self.PFimageViewForButton2];
        
        self.PFimageViewForButton3 = [[PFImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.imageViewButton3.bounds.size.width, self.imageViewButton3.bounds.size.height)];
        [self.imageViewButton3 addSubview:self.PFimageViewForButton3];
        
        
        
    }
    return self;
}

- (void)setImage1:(PFFile *)image1 setImage2:(PFFile *)image2 setImage3:(PFFile *)image3 {
    /*
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
     */
    self.PFimageViewForButton1.file = image1;
    self.PFimageViewForButton2.file = image2;
    self.PFimageViewForButton3.file = image3;
    
    [self.PFimageViewForButton1 loadInBackground];
    [self.PFimageViewForButton2 loadInBackground];
    [self.PFimageViewForButton3 loadInBackground];
     
}

@end
