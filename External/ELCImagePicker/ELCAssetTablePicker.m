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


@interface ELCAssetTablePicker ()

@property (nonatomic, assign) int columns;
@property (nonatomic, strong) UIBarButtonItem *doneBtn;

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
    
   
    
    // set color of nav bar to custom grey
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(79/255.0) green:(91/255.0) blue:(100/255.0) alpha:(0.0/255.0)];
    
    // set title to white 
    //self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // cancel button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelImagePicker)];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    
    if([self.navigationItem.title isEqualToString:@"Camera Roll"]){
        
        ELCAsset *camCell = [[ELCAsset alloc] init];
        camCell.isCam = YES;
        [camCell setParent:self];
        [self.elcAssets addObject:camCell];
    }

    // done button
    self.doneBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];;
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectZero];
    [button addTarget:self action:@selector(selectAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:self.navigationItem.title forState:UIControlStateNormal];
    [button sizeToFit];
    
    self.navigationItem.titleView = button;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.columns = self.view.bounds.size.width / 80;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.columns = self.view.bounds.size.width / 80;
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
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            /*
            // scroll to bottom
            long section = [self numberOfSectionsInTableView:self.tableView] - 1;
            long row = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
            if (section >= 0 && row >= 0) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:row
                                                     inSection:section];
                [self.tableView scrollToRowAtIndexPath:ip
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:NO];
            }
             */
            
            
            
            
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
    
	for (ELCAsset *elcAsset in self.elcAssets) {
        if ([elcAsset selected]) {
            [selectedAssetsImages addObject:[elcAsset asset]];
        }
	}
    [self.parent selectedAssets:selectedAssetsImages];
}

- (void)cancelImagePicker{

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)shouldSelectAsset:(ELCAsset *)asset
{
    NSUInteger selectionCount = 0;
    for (ELCAsset *elcAsset in self.elcAssets) {
        if (elcAsset.selected) selectionCount++;
    }
    
    BOOL shouldSelect = YES;
    
    if ([self.parent respondsToSelector:@selector(shouldSelectAsset:previousCount:)]) {
        shouldSelect = [self.parent shouldSelectAsset:asset previousCount:selectionCount];
    }
    
    return shouldSelect;
}

- (void)assetSelected:(ELCAsset *)asset
{
    if(asset != nil){
        
        [self doneButtonEnabled:YES];
        
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
            
            // start cam when first cell selected, deselect
            asset.selected = NO;
            [self shouldStartCameraController];
            
        }
    }else{
        [self doneButtonEnabled:NO];
    }
}

- (void)doneButtonEnabled:(BOOL)selected{
    
    if(selected){
        self.navigationItem.rightBarButtonItem = self.doneBtn;
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    imagePicker.allowsEditing = NO;
    imagePicker.showsCameraControls = YES;
    
    /*
    
    // get tab bar and home controller from stack
    PAPTabBarController *tabBarController =[[self.navigationController viewControllers] objectAtIndex:1];
    NSArray *tabBarViewControllers = [tabBarController viewControllers];
    
    [tab]

    
    imagePicker.delegate = tabBarController;
     
     */
    
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    
    return YES;
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
	return 79;
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
