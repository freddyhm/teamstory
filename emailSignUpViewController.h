//
//  emailSignUpViewController.h
//  Teamstory
//
//  Created by Tobok Lee on 12/16/13.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface emailSignUpViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) UITextField *signUpEmailTextField;
@property (nonatomic, strong) UITextField *signUpPWTextField;
@property (nonatomic, strong) UITextField *signUpPWTextField_confirm;


@end
