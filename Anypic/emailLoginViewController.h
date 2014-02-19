//
//  emailLoginViewController.h
//  Teamstory
//
//  Created by Tobok Lee on 12/12/13.
//
//


@interface emailLoginViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *pwTextField;
@property (nonatomic, strong) UIWindow *window;

@end
