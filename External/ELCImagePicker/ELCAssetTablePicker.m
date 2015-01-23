//
//  ELCAssetTablePicker.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "PAPTabBarController.h"
#import "SVProgressHUD.h"
#import "Mixpanel.h"
#import "FlightRecorder.h"


@interface ELCAssetTablePicker ()

@property (nonatomic, assign) int columns;
@property (nonatomic, strong) UIBarButtonItem *doneBtn;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) ELCAsset *prevAsset;

@end

@implementation ELCAssetTablePicker

//Using auto synthesizers

- (id)init
{
    self = [super init];
    if (self) {
        //Sets a reasonable default bigger then 0 for columns
        //So that we don't have a divide by 0 scenario
        self.columns = 4;
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView setAllowsSelection:NO];
    
    // mixpanel analytics
    [[Mixpanel sharedInstance] track:@"Viewed Screen" properties:@{@"Type" : @"Photo Album"}];
    
    // flightrecorder analytics
    [[FlightRecorder sharedInstance] trackPageView:@"Photo Album"];
    
    // flightrecorder event analytics
    [[FlightRecorder sharedInstance] trackEventWithCategory:@"photo_album_screen" action:@"viewing_photo_album" label:@"" value:@""];
        
    // set color of nav bar to custom grey
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(79/255.0) green:(91/255.0) blue:(100/255.0) alpha:(0.0/255.0)];
    
    // set title to white 
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // cancel button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelImagePicker)];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;

    // done button
    self.doneBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    self.navigationItem.rightBarButtonItem = self.doneBtn;
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];

    
}

- (void)setButtonTitle:(NSString *)groupName{
    
    // downwards triange in nav bar
    NSString *downTriangle = @" \U000025BE\U0000FE0E";
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectZero];
    [button addTarget:self action:@selector(selectAlbum:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:[groupName stringByAppendingString:downTriangle] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [button sizeToFit];

    self.navigationItem.titleView = button;
    self.albumName = groupName;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.columns = self.view.bounds.size.width / 90;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.columns = self.view.bounds.size.width / 90;
    [self.tableView reloadData];
}

- (void)preparePhotos
{
    @autoreleasepool {
        
        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result == nil) {
                return;
            }
            
            ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result];
            [elcAsset setParent:self];
            
            BOOL isAssetFiltered = NO;
            if (self.assetPickerFilterDelegate &&
                [self.assetPickerFilterDelegate respondsToSelector:@selector(assetTablePicker:isAssetFilteredOut:)])
            {
                isAssetFiltered = [self.assetPickerFilterDelegate assetTablePicker:self isAssetFilteredOut:(ELCAsset*)elcAsset];
            }
            
            if (!isAssetFiltered) {
                [self.elcAssets addObject:elcAsset];
            }
            
        }];
        
        self.elcAssets = [NSMutableArray arrayWithArray:[[self.elcAssets reverseObjectEnumerator] allObjects]];
        
        // if camera roll, insert special camera tile
        if([self.albumName isEqualToString:@"Camera Roll"]){
            ELCAsset *camCell = [[ELCAsset alloc] init];
            camCell.isCam = YES;
            [camCell setParent:self];
            [self.elcAssets insertObject:camCell atIndex:0];
        }
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)selectAlbum:(id)sender{
    ELCAlbumPickerController *pickAlbum = [[ELCAlbumPickerController alloc] init];
    pickAlbum.parent = self.parent;
    
    [self.navigationController pushViewController:pickAlbum animated:YES];
}

- (void)processCompleted:(ALAssetsGroup *)group{
    
    self.assetGroup = group;
    [self.assetGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    [self viewDidLoad];
    [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    [self.tableView reloadData];
}

- (void)doneAction:(id)sender
{
	NSMutableArray *selectedAssetsImages = [[NSMutableArray alloc] init];
    
    BOOL isSelected = NO;
    
	for (ELCAsset *elcAsset in self.elcAssets) {
        if ([elcAsset selected]) {
            [selectedAssetsImages addObject:[elcAsset asset]];
            isSelected = YES;
        }
	}
    
    // check if there's a pic selected, show pop up if not
    if(isSelected){
        
        // analytics        
        [[Mixpanel sharedInstance] track:@"Selected Album Picture" properties:@{}];
        
        [self.parent selectedAssets:selectedAssetsImages];
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"No Picture Selected :(" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)cancelImagePicker{

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)shouldSelectAsset:(ELCAsset *)asset
{
    // remove selected frame from previous asset
    if(self.prevAsset != nil){
        self.prevAsset.selected = NO;
    }
    
    NSUInteger selectionCount = 0;
    for (ELCAsset *elcAsset in self.elcAssets) {
        if (elcAsset.selected) selectionCount++;
    }
    
    BOOL shouldSelect = YES;
    
    if ([self.parent respondsToSelector:@selector(shouldSelectAsset:previousCount:)]) {
        shouldSelect = [self.parent shouldSelectAsset:asset previousCount:selectionCount];
    }
    
    // update prev asset
    self.prevAsset = asset;
    
    [self.tableView reloadData];
    
    return shouldSelect;
}

- (void)assetSelected:(ELCAsset *)asset
{
    if(asset != nil){
                
        if(!asset.isCam){
            if (self.singleSelection) {
                for (ELCAsset *elcAsset in self.elcAssets) {
                    if (asset != elcAsset) {
                        elcAsset.selected = NO;
                    }
                }
            }
            if (self.immediateReturn) {
                NSArray *singleAssetArray = @[asset.asset];
                [(NSObject *)self.parent performSelector:@selector(selectedAssets:) withObject:singleAssetArray afterDelay:0];
            }
        }else{
            
            [SVProgressHUD show];
            
            // start cam when first cell selected, deselect
            asset.selected = NO;
            [self openCamera];
        }
    }
}

- (void)openCamera {
    
    // gets camera controller from tabbarcontroller
    UIImagePickerController *camera = [self.parent performSelector:@selector(startCamera)];
    
    if(camera != nil){
        [self.navigationController presentViewController:camera animated:YES completion:nil];
    }
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.columns <= 0) { //Sometimes called before we know how many columns we have
        self.columns = 4;
    }
    NSInteger numRows = ceil([self.elcAssets count] / (float)self.columns);
    return numRows;
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)path
{
    long index = path.row * self.columns;
    long length = MIN(self.columns, [self.elcAssets count] - index);
    return [self.elcAssets subarrayWithRange:NSMakeRange(index, length)];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ELCAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setAssets:[self assetsForIndexPath:indexPath]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 106;
}

- (int)totalSelectedAssets
{
    int count = 0;
    
    for (ELCAsset *asset in self.elcAssets) {
		if (asset.selected) {
            count++;
		}
	}
    
    return count;
}

#pragma mark - Sample protocol delegate
-(void)processCompleted{
    
}


@end
