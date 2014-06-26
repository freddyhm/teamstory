//
//  PAPlinkPostViewController.m
//  Teamstory
//
//  Created by Tobok Lee on 2014-06-25.
//
//

#import "PAPlinkPostViewController.h"


@interface PAPlinkPostViewController ()

@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIView *popUpBox;
@property (nonatomic, strong) UITextField *url_textField;
@property (nonatomic, strong) UIButton *okayButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) PFImageView *imageView;

@end

@implementation PAPlinkPostViewController

@synthesize dimView;
@synthesize popUpBox;
@synthesize url_textField;
@synthesize okayButton;
@synthesize nextButton;
@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // init nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // set logo and nav bar buttons
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    // populating dim View (background).
    self.dimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.dimView setBackgroundColor:[UIColor colorWithWhite:0.5f alpha:0.8f]];
    [self.dimView setTag:111];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.dimView];
    
    float popUpBoxOffset;
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        popUpBoxOffset = 60.0f;
    } else {
        popUpBoxOffset = 75.0f;
    }
    
    self.popUpBox = [[UIView alloc] initWithFrame:CGRectMake(20.0f, popUpBoxOffset, 280.0f, 230.0f)];
    [self.popUpBox setBackgroundColor:[UIColor whiteColor]];
    self.popUpBox.layer.cornerRadius = 8.0f;
    [self.popUpBox setTag:110];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.popUpBox];
    
    UIView *popUpBoxHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 40.0f)];
    [popUpBoxHeader setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0]];
    popUpBoxHeader.clipsToBounds = YES;

    // Creating layer to only initiate the top right and left round corners.
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:popUpBoxHeader.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(8.0, 8.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = popUpBoxHeader.bounds;
    maskLayer.path = maskPath.CGPath;
    popUpBoxHeader.layer.mask = maskLayer;
    
    [self.popUpBox addSubview:popUpBoxHeader];
    
    UILabel *popUpBoxHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 80.0f, 30.0f)];
    [popUpBoxHeaderLabel setText:@"Add Link"];
    [popUpBoxHeaderLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
    [popUpBoxHeader addSubview:popUpBoxHeaderLabel];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(popUpBoxHeader.bounds.size.width - 30.0f, 10.0f, 20.0f, 20.0f)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"button_cancel_selected.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [popUpBoxHeader addSubview:cancelButton];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 100.0f, 150.0f, 30.0f)];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [self.titleLabel setText:@"Link Title Goes Here"];
    [self.popUpBox addSubview:self.titleLabel];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 125.0f, 170.0f, 60.0f)];
    [self.descriptionLabel setText:@"Link Description snippet will go here"];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    self.descriptionLabel.numberOfLines = 0;
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel setTextColor:[UIColor colorWithWhite:0.5f alpha:10.0f]];
    [self.popUpBox  addSubview:self.descriptionLabel];
    
    self.url_textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 60.0f, 200.0f, 30.0f)];
    [self.url_textField setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [self.popUpBox addSubview:self.url_textField];
    
    self.imageView = [[PFImageView alloc] initWithFrame:CGRectMake(10.0f, 100.0f, 80.0f, 80.0f)];
    [self.imageView setBackgroundColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
    [self.popUpBox addSubview:self.imageView];
    
    UIColor *teamStoryColor = [UIColor colorWithRed:86.0f/255.0f green:185.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    
    self.okayButton = [[UIButton alloc] initWithFrame:CGRectMake(220.0f, 60.0f, 50.0f, 30.0f)];
    [self.okayButton setBackgroundColor:[UIColor whiteColor]];
    self.okayButton.clipsToBounds = YES;
    self.okayButton.layer.cornerRadius = 3.0f;
    [self.okayButton.layer setBorderWidth:2.0f];
    [self.okayButton.layer setBorderColor:teamStoryColor.CGColor];
    [self.okayButton setTitle:@"OK" forState:UIControlStateNormal];
    [self.okayButton.titleLabel setTextColor:teamStoryColor];
    [self.okayButton addTarget:self action:@selector(okayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.popUpBox addSubview:self.okayButton];
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 190.0f, 260.0f, 30.0f)];
    [self.nextButton setBackgroundColor:teamStoryColor];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.popUpBox addSubview:self.nextButton];
    
    
}


# pragma mark - ()
- (void)backButtonAction:(id)sender {
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)okayButtonAction:(id)sender {
    
}

- (void)cancelButtonAction:(id)sender {
    [[[[UIApplication sharedApplication] delegate] window] viewWithTag:110].hidden = YES;
    [[[[UIApplication sharedApplication] delegate] window] viewWithTag:111].hidden = YES;
}

@end
