//
//  PAPMessageListCell.m
//  Teamstory
//
//  Created by Tobok Lee on 9/10/14.
//
//

#import "PAPMessageListCell.h"

#define cellHeight 85.0f
#define profilePictureGap 80.0f
#define leftGap 80.0f

@implementation PAPMessageListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        /*
        self.cellButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, cellHeight)];
        self.cellButton.backgroundColor = [UIColor clearColor];
        [self addSubview:self.cellButton];
        */
        self.profileImageView = [[PFImageView alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 50.0f, 50.0f)];
        [self addSubview:self.profileImageView];
        
        self.userButton = [[UIButton alloc] initWithFrame:self.profileImageView.frame];
        [self addSubview:self.userButton];
        
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(profilePictureGap, 15.0f, [UIScreen mainScreen].bounds.size.width - profilePictureGap - leftGap, 20.0f)];
        [self.userName setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
        [self addSubview:self.userName];
        
        self.lastMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(profilePictureGap, 35.0f, [UIScreen mainScreen].bounds.size.width - profilePictureGap - leftGap, 45.0f)];
        [self.lastMessageLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
        [self.lastMessageLabel setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
        [self.lastMessageLabel setNumberOfLines:2];
        [self addSubview:self.lastMessageLabel];
        
        self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - leftGap + 30.0f, 40.0f, 35.0f, 25.0f)];
        self.badgeLabel.backgroundColor = [UIColor redColor];
        self.badgeLabel.alpha = 0.8f;
        self.badgeLabel.layer.cornerRadius = 13.0f;
        self.badgeLabel.clipsToBounds = YES;
        self.badgeLabel.hidden = YES;
        [self.badgeLabel setTextColor:[UIColor whiteColor]];
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        [self addSubview:self.badgeLabel];
        
        self.timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - leftGap + 10.0f, 15.0f, 60.0f, 15.0f)];
        [self.timeStampLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.0f]];
        [self.timeStampLabel setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
        self.timeStampLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timeStampLabel];
        
        UIView *lineBreak = [[UIView alloc] initWithFrame:CGRectMake(profilePictureGap, 84.0f, [UIScreen mainScreen].bounds.size.width - profilePictureGap, 1.0f)];
        lineBreak.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        [self addSubview:lineBreak];
         
    }
    return self;
}


-(void)setUser:(PFUser *)user {
    self.messageUser = user;
    [self.profileImageView setFile:[self.messageUser objectForKey:@"profilePictureSmall"]];
    [self.profileImageView loadInBackground:^(UIImage *image, NSError *error) {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = YES;
    }];
    
    self.userName.text = [self.messageUser objectForKey:@"displayName"];
}

@end
