//
//  CameraFilterViewController.h
//  Teamstory
//
//  Created by Freddy Hidalgo-Monchez on 1/15/2014.
//
//

#import <UIKit/UIKit.h>

@interface CameraFilterViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic,strong) IBOutlet UIImageView *croppedImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelEditBtn;
@property (nonatomic, strong) IBOutlet UICollectionView *filterList;



- (id)initWithImage:(UIImage *)aImage nib:(NSString *)nibNameOrNil source:(NSString *)imgSource;


@end
