//
//  emailSignUpViewController.h
//  Anypic
//
//  Created by Tobok Lee on 12/16/13.
//
//

#import <UIKit/UIKit.h>

@interface emailSignUpViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UITextField *signUpEmailTextField;
@property (nonatomic, strong) UITextField *signUpPWTextField;
@property (nonatomic, strong) UITextField *signUpPWTextField_confirm;


@end
