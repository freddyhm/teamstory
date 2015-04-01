//
//  SecondAccountViewHeaderController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-03-04.
//
//

#import <UIKit/UIKit.h>

@interface SecondAccountHeaderViewController : UIViewController

@property NSInteger index;
@property (strong, nonatomic) IBOutlet UIButton *twitter;
@property (strong, nonatomic) IBOutlet UIButton *linkedIn;
@property (strong, nonatomic) IBOutlet UIButton *angelList;
@property (strong, nonatomic) IBOutlet UILabel *industryLabel;
@property (strong, nonatomic) IBOutlet UILabel *industryInfo;

@end
