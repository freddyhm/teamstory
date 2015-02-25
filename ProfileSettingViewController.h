//
//  ProfileSettingViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2015-02-15.
//
//

#import <UIKit/UIKit.h>

@interface ProfileSettingViewController : UIViewController <UINavigationControllerDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *backgroundView;
@property (strong, nonatomic) IBOutlet PFImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UITextField *twitter_textfield;

@property (strong, nonatomic) IBOutlet UITextField *linkedin_textfield;
@property (strong, nonatomic) IBOutlet UITextField *angellist_textfield;


@property (strong, nonatomic) IBOutlet UIPickerView *industry_pickerView;
@property (strong, nonatomic) IBOutlet UITextField *email_address;
@property (strong, nonatomic) IBOutlet UITextField *location;
@property (strong, nonatomic) IBOutlet UITextView *userDescription;
@property (strong, nonatomic) IBOutlet UITextField *website;
@property (strong, nonatomic) IBOutlet UITextField *displayName;
@property (strong, nonatomic) IBOutlet UIButton *industry;

@property (strong, nonatomic) IBOutlet UIView *industryView;
@property (strong, nonatomic) IBOutlet UIButton *industry_buttonAction;

@end
