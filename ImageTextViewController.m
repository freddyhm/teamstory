//
//  ImageTextViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-05-18.
//
//

#import "ImageTextViewController.h"
#import "CameraFilterViewController.h"

@interface ImageTextViewController ()

@end

@implementation ImageTextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
    self.textView.text = @"Enter";
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapOutside];
}

#pragma mark - UITextViewDelegate

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)saveImg:(id)sender {
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.textView.frame];
    label.text = self.textView.text;
    label.font = [self.textView font];
    label.numberOfLines = 0;
    [label sizeToFit];
    
    [self.imageView addSubview:label];
    
    UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0.0); //retina res
    [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [label removeFromSuperview];
    
    CameraFilterViewController *filterController = [[CameraFilterViewController alloc]initWithImage:image nib:@"CameraFilterViewController" source:@"one"];
    
    [self.navigationController pushViewController:filterController animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
