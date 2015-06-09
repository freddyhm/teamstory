//
//  FirstAccountHeaderViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-03-04.
//
//

#import <UIKit/UIKit.h>

@interface FirstAccountHeaderViewController : UIViewController

// labels

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *websiteLink;
@property (strong, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *followingLabel;
@property (strong, nonatomic) IBOutlet UILabel *followerLabel;
@property (strong, nonatomic) IBOutlet PFImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *seperatorLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointLabel;

@property (strong, nonatomic) IBOutlet UIView *containerView;

// values

@property (strong, nonatomic) NSString *locationInfo;
@property (strong, nonatomic) NSString *descriptionInfo;
@property (strong, nonatomic) NSString *websiteInfo;
@property (strong, nonatomic) NSString *followerCountInfo;
@property (strong, nonatomic) NSString *followingCountInfo;
@property (strong, nonatomic) NSString *pointCountInfo;

@end
