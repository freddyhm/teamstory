//
//  ThoughtPostViewController.m
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 2014-05-22.
//
//

#import "ThoughtPostViewController.h"
#import "CameraFilterViewController.h"

@interface ThoughtPostViewController ()

@end

@implementation ThoughtPostViewController

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
    
    // init nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // set logo and nav bar buttons
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit:)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    
    self.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
    self.textView.text = @"Enter";
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapOutside];
}

-(void)viewWillAppear:(BOOL)animated{
    
    // set color of nav bar to teal
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - UITextViewDelegate

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - ()

- (IBAction)saveEdit:(id)sender {
    
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

- (void)backButtonAction:(id)sender {
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end