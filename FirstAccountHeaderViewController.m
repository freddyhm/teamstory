//
//  FirstAccountHeaderViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-03-04.
//
//

#import "FirstAccountHeaderViewController.h"

@interface FirstAccountHeaderViewController ()

@end

@implementation FirstAccountHeaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationLabel.text = self.locationInfo;
    self.descriptionLabel.text = self.descriptionInfo;
    self.websiteLink.titleLabel.text = self.websiteInfo;
    self.followerCountLabel.text = self.followerCountInfo;
    self.followingCountLabel.text = self.followingCountInfo;
    self.pointCountLabel.text = self.pointCountInfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
