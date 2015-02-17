//
//  PAPdiscoverFollowerCell.m
//  Teamstory
//
//  Created by Tobok Lee on 2/12/15.
//
//

#import "PAPdiscoverFollowerCell.h"
#import "PAPdiscoverCell.h"

#define photoHeaderViewHeight 44.0f

@interface PAPdiscoverFollowerCell ()



@end

@implementation PAPdiscoverFollowerCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.photoHeaderView = [[PAPPhotoHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, photoHeaderViewHeight) buttons:PAPPhotoHeaderButtonsDefault];
        self.photoHeaderView.delegate = self;
        [self addSubview:self.photoHeaderView];
        
        self.photoButtion1 = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, photoHeaderViewHeight + 5.0f, 100.0f, 100.0f)];
        [self.photoButtion1 addTarget:self action:@selector(photoButtion1Action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.photoButtion1];
        
        self.photoButtion2 = [[UIButton alloc] initWithFrame:CGRectMake(110.0f, photoHeaderViewHeight + 5.0f, 100.0f, 100.0f)];
        [self.photoButtion2 addTarget:self action:@selector(photoButtion2Action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.photoButtion2];
        
        self.photoButtion3 = [[UIButton alloc] initWithFrame:CGRectMake(215.0f, photoHeaderViewHeight + 5.0f, 100.0f, 100.0f)];
        [self.photoButtion3 addTarget:self action:@selector(photoButtion3Action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.photoButtion3];
        
        self.PFimageViewForButton1 = [[PFImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.photoButtion1.bounds.size.width, self.photoButtion1.bounds.size.height)];
        [self.photoButtion1 addSubview:self.PFimageViewForButton1];
        
        self.PFimageViewForButton2 = [[PFImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.photoButtion2.bounds.size.width, self.photoButtion2.bounds.size.height)];
        [self.photoButtion2 addSubview:self.PFimageViewForButton2];
        
        self.PFimageViewForButton3 = [[PFImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.photoButtion3.bounds.size.width, self.photoButtion3.bounds.size.height)];
        [self.photoButtion3 addSubview:self.PFimageViewForButton3];
         
    }
    return self;
}

- (void)photoButtion1Action:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(setPhotoInDiscover:)]) {
        [delegate setPhotoInDiscover:[self.photoArray objectAtIndex:0]];
    }
}

- (void)photoButtion2Action:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(setPhotoInDiscover:)]) {
        [delegate setPhotoInDiscover:[self.photoArray objectAtIndex:1]];
    }
}

- (void)photoButtion3Action:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(setPhotoInDiscover:)]) {
        [delegate setPhotoInDiscover:[self.photoArray objectAtIndex:2]];
    }
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapUserButton:user:)]) {
        [delegate photoHeaderView:photoHeaderView didTapUserButton:button user:user];
    }
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapFollowButtonForDiscover:(UIButton *)button user:(PFUser *)user {
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapFollowButtonForDiscover:user:)]) {
        [delegate photoHeaderView:photoHeaderView didTapFollowButtonForDiscover:button user:user];
    }
}


@end