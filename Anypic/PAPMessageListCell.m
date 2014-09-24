//
//  PAPMessageListCell.m
//  Teamstory
//
//  Created by Tobok Lee on 9/10/14.
//
//

#import "PAPMessageListCell.h"

#define cellHeight 85.0f

@implementation PAPMessageListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, cellHeight)];
        self.cellButton.backgroundColor = [UIColor clearColor];
        [self addSubview:self.cellButton];
        
        self.profileImageView = [[PFImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 30.0f, 30.0f)];
        [self addSubview:self.profileImageView];
        
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 10.0f, 200.0f, 20.0f)];
        [self addSubview:self.userName];
        
        self.lastMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 40.0f, 250.0f, 30.0f)];
        [self addSubview:self.lastMessageLabel];
        
        self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(290.0f, 40.0f, 30.0f, 30.0f)];
        self.badgeLabel.backgroundColor = [UIColor redColor];
        self.badgeLabel.layer.cornerRadius = 10.0f;
        [self addSubview:self.badgeLabel];
        
         
    }
    return self;
}


-(void)setUser:(PFUser *)user {
    self.messageUser = user;
    [self.profileImageView setFile:[self.messageUser objectForKey:@"profilePictureSmall"]];
    [self.profileImageView loadInBackground];
    
    self.userName.text = [self.messageUser objectForKey:@"displayName"];
}

@end
