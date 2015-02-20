//
//  PAPLoginPopupViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2/19/15.
//
//

#import "PAPLoginPopupViewController.h"
#import "AppDelegate.h"
#import "PAPLoginInfoSheetViewController.h"

@interface PAPLoginPopupViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailTextView;
@property (strong, nonatomic) IBOutlet UITextField *confirmPWTextView;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextView;

@end

@implementation PAPLoginPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
}
- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)twitterButtonAction:(id)sender {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            [self navigateToInfoSheet];
        } else {
            NSLog(@"User logged in with Twitter!");
            // TODO find a way to fetch details with Twitter..
            
            //NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", user.username];
            NSString * requestString = @"https://api.twitter.com/1.1/users/show.json?screen_name=toboklee";
            
            NSURL *verify = [NSURL URLWithString:requestString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
            [[PFTwitterUtils twitter] signRequest:request];
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
            
            
            if ( error == nil){
                NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                [user setObject:[result objectForKey:@"profile_image_url_https"]
                         forKey:@"picture"];
                // does this thign help?
                [user setUsername:[result objectForKey:@"screen_name"]];
                
                NSString * names = [result objectForKey:@"name"];
                NSLog(@"%@", names);
                
                
            }
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:^{
                }];
            }];
            
        }     
    }];
}
- (IBAction)signUpButtonAction:(id)sender {
    [self navigateToInfoSheet];
}

- (void) navigateToInfoSheet {
    PAPLoginInfoSheetViewController *loginInfoSheetController = [[PAPLoginInfoSheetViewController alloc] initWithNibName:@"PAPLoginInfoSheetViewController" bundle:nil];
    [self presentViewController:loginInfoSheetController animated:YES completion:nil];
}

// UITextField placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

// UITextField text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}
@end
