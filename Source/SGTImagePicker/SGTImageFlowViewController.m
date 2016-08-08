//
//  DNImageFlowViewController.m
//  ImagePicker
//
//  Created by block on 15/2/11.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import "SGTImageFlowViewController.h"
#import "SGTImagePickerController.h"
#import "SGTPhotoBrowser.h"
#import "UIViewController+DNImagePicker.h"
#import "UIView+DNImagePicker.h"
#import "UIColor+Hex.h"
#import "SGTAssetsViewCell.h"
#import "SGTSendButton.h"
#import "SGTImageAsset.h"
#import "NSURL+DNIMagePickerUrlEqual.h"
#import <AssetsLibrary/AssetsLibrary.h>

//static NSUInteger kDNImageFlowMaxSeletedNumber = 9;

@interface SGTImageFlowViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SGTAssetsViewCellDelegate, SGTPhotoBrowserDelegate>

@property (nonatomic, strong) NSURL *assetsGroupURL;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong) UICollectionView *imageFlowCollectionView;
@property (nonatomic, strong) SGTSendButton *sendButton;


@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) NSMutableArray *selectedAssetsArray;

@property (nonatomic, assign) BOOL isFullImage;
@end

static NSString* const dnAssetsViewCellReuseIdentifier = @"DNAssetsViewCell";

@implementation SGTImageFlowViewController

- (instancetype)initWithGroupURL:(NSURL *)assetsGroupURL
{
    self = [super init];
    if (self) {
        _kDNImageFlowMaxSeletedNumber = 1;
        _assetsArray = [NSMutableArray new];
        _selectedAssetsArray = [NSMutableArray new];
        _assetsGroupURL = assetsGroupURL;
        if ([SGTImageAsset sharedLibrary] != nil) {
            _assetsLibrary = [SGTImageAsset sharedLibrary];
        }else {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupData];
}

- (void)dealloc
{
    NSLog(@"%s DNImageFlowViewController",__FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - setup view and data
- (void)setupData
{
    [_assetsLibrary groupForURL:self.assetsGroupURL resultBlock:^(ALAssetsGroup *assetsGroup){
        self.assetsGroup = assetsGroup;
        if (self.assetsGroup) {
            self.title =[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
            [self loadData];
        }
        
    } failureBlock:^(NSError *error){
        //            NSLog(@"%@",error.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tips" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];
}


- (void)setupView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self createBarButtonItemAtPosition:Left
                      statusNormalImage:[UIImage imageNamed:@"back_normal"]
                   statusHighlightImage:[UIImage imageNamed:@"back_highlight"]
                                 action:@selector(backButtonAction)];
    [self createBarButtonItemAtPosition:Right
                                   text:NSLocalizedStringFromTable(@"cancel", @"DNImagePicker", @"取消")
                                 action:@selector(cancelAction)];
    
    [self imageFlowCollectionView];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"preview", @"DNImagePicker", @"预览") style:UIBarButtonItemStylePlain target:self action:@selector(previewAction)];
    [item1 setTintColor:[UIColor blackColor]];
    item1.enabled = NO;
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithCustomView:self.sendButton];
    
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item4.width = -10;
    
    [self setToolbarItems:@[item1,item2,item3,item4] animated:NO];
}

- (void)loadData
{
    [self.assetsGroup setAssetsFilter:ALAssetsFilterFromDNImagePickerControllerFilterType([[self dnImagePickerController] filterType])];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [self.assetsArray insertObject:[[SGTImageAsset alloc] initWithAlasset:result] atIndex:0];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageFlowCollectionView reloadData];
            [self scrollerToBottom:NO];
        });
    });
}

#pragma mark - helpmethods
- (void)scrollerToBottom:(BOOL)animated
{
    NSInteger rows = [self.imageFlowCollectionView numberOfItemsInSection:0] - 1;
    [self.imageFlowCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:rows inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
}

- (SGTImagePickerController *)dnImagePickerController
{
    
    if (nil == self.navigationController
        ||
        NO == [self.navigationController isKindOfClass:[SGTImagePickerController class]])
    {
        NSAssert(false, @"check the navigation controller");
    }
    return (SGTImagePickerController *)self.navigationController;
}

- (BOOL)assetIsSelected:(SGTImageAsset *)targetAsset
{
    for (SGTImageAsset *asset in self.selectedAssetsArray) {
        NSURL *assetURL = asset.url;//[asset valueForProperty:ALAssetPropertyAssetURL];
        NSURL *targetAssetURL = targetAsset.url;//[targetAsset valueForProperty:ALAssetPropertyAssetURL];
        if ([assetURL isEqualToOther:targetAssetURL]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeAssetsObject:(SGTImageAsset *)asset
{
    if ([self assetIsSelected:asset]) {
        [self.selectedAssetsArray removeObject:asset];
    }
}

- (void)addAssetsObject:(SGTImageAsset *)asset
{
    [self.selectedAssetsArray addObject:asset];
}

- (SGTImageAsset *)dnassetFromALAsset:(SGTImageAsset *)ALAsset
{
    SGTImageAsset *asset = [[SGTImageAsset alloc] initWithAlasset:ALAsset];
//    asset.url = [DNAsset valueForProperty:ALAssetPropertyAssetURL];
    return asset;
}

- (NSArray *)seletedDNAssetArray
{
    NSMutableArray *seletedArray = [NSMutableArray new];
    for (SGTImageAsset *asset in self.selectedAssetsArray) {
//        DNAsset *dnasset = [self dnassetFromALAsset:asset];
        [seletedArray addObject:asset];
    }
    return seletedArray;
}

#pragma mark - priviate methods
- (void)sendImages
{
    NSString *properyID = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    [[NSUserDefaults standardUserDefaults] setObject:properyID forKey:kDNImagePickerStoredGroupKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SGTImageAsset setSharedLibrary:_assetsLibrary];
    
    SGTImagePickerController *imagePicker = [self dnImagePickerController];
    if (imagePicker && [imagePicker.imagePickerDelegate respondsToSelector:@selector(dnImagePickerController:sendImages:isFullImage:)]) {
        [imagePicker.imagePickerDelegate dnImagePickerController:imagePicker sendImages:[self seletedDNAssetArray] isFullImage:self.isFullImage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];}

- (void)browserPhotoAsstes:(NSArray *)assets pageIndex:(NSInteger)page
{
    SGTPhotoBrowser *browser = [[SGTPhotoBrowser alloc] initWithPhotos:assets
                                                        currentIndex:page
                                                           fullImage:self.isFullImage];
    browser.delegate = self;
    browser.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:browser animated:YES];
}

- (BOOL)seletedAssets:(SGTImageAsset *)asset
{
    if ([self assetIsSelected:asset]) {
        return NO;
    }

    UIBarButtonItem *firstItem = self.toolbarItems.firstObject;
    firstItem.enabled = YES;
    if (self.selectedAssetsArray.count >= _kDNImageFlowMaxSeletedNumber) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"alertTitle", @"DNImagePicker", nil) message:[NSString stringWithFormat:@"图片最多允许选择%@张",@(_kDNImageFlowMaxSeletedNumber)] delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }else
    {
        [self addAssetsObject:asset];
        self.sendButton.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedAssetsArray.count];
        return YES;
    }
}

- (void)deseletedAssets:(SGTImageAsset *)asset
{
    [self removeAssetsObject:asset];
    self.sendButton.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedAssetsArray.count];
    if (self.selectedAssetsArray.count < 1) {
        UIBarButtonItem *firstItem = self.toolbarItems.firstObject;
        firstItem.enabled = NO;
    }
}

#pragma mark - getter/setter
- (ALAssetsLibrary *)assetsLibrary
{
    if (nil == _assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (UICollectionView *)imageFlowCollectionView
{
    if (nil == _imageFlowCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 2.0;
        layout.minimumInteritemSpacing = 2.0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _imageFlowCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
        _imageFlowCollectionView.backgroundColor = [UIColor clearColor];
        [_imageFlowCollectionView registerClass:[SGTAssetsViewCell class] forCellWithReuseIdentifier:dnAssetsViewCellReuseIdentifier];
        
        _imageFlowCollectionView.alwaysBounceVertical = YES;
        _imageFlowCollectionView.delegate = self;
        _imageFlowCollectionView.dataSource = self;
        _imageFlowCollectionView.showsHorizontalScrollIndicator = YES;
        [self.view addSubview:_imageFlowCollectionView];
    }
    
    return _imageFlowCollectionView;
}

- (SGTSendButton *)sendButton
{
    if (nil == _sendButton) {
        _sendButton = [[SGTSendButton alloc] initWithFrame:CGRectZero];
        [_sendButton addTaget:self action:@selector(sendButtonAction:)];
    }
    return  _sendButton;
}

#pragma mark - ui action
- (void)backButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonAction:(id)sender
{
    if (self.selectedAssetsArray.count > 0) {
        [self sendImages];
    }
}

- (void)previewAction
{
    if (self.selectedAssetsArray.count>0) {
        [self browserPhotoAsstes:self.selectedAssetsArray pageIndex:0];
    }
}

- (void)cancelAction
{
    SGTImagePickerController *navController = [self dnImagePickerController];
    if (navController && [navController.imagePickerDelegate respondsToSelector:@selector(dnImagePickerControllerDidCancel:)]) {
        [navController.imagePickerDelegate dnImagePickerControllerDidCancel:navController];
    }
    
    if(navController) {
        [navController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - DNAssetsViewCellDelegate
- (void)didSelectItemAssetsViewCell:(SGTAssetsViewCell *)assetsCell
{
    assetsCell.isSelected = [self seletedAssets:assetsCell.asset];
}

- (void)didDeselectItemAssetsViewCell:(SGTAssetsViewCell *)assetsCell
{
    assetsCell.isSelected = NO;
    [self deseletedAssets:assetsCell.asset];
}

#pragma mark - UICollectionView delegate and Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SGTAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:dnAssetsViewCellReuseIdentifier forIndexPath:indexPath];
    SGTImageAsset *asset = self.assetsArray[indexPath.row];
    cell.delegate = self;
    [cell fillWithAsset:asset isSelected:[self assetIsSelected:asset]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self browserPhotoAsstes:self.assetsArray pageIndex:indexPath.row];
}

#define kSizeThumbnailCollectionView  ([UIScreen mainScreen].bounds.size.width-10)/4
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(kSizeThumbnailCollectionView, kSizeThumbnailCollectionView);
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

#pragma mark - DNPhotoBrowserDelegate
- (void)sendImagesFromPhotobrowser:(SGTPhotoBrowser *)photoBrowser currentAsset:(SGTImageAsset *)asset
{
    if (self.selectedAssetsArray.count <= 0) {
        [self seletedAssets:asset];
        [self.imageFlowCollectionView reloadData];
    }
    [self sendImages];
}

- (NSInteger)seletedPhotosNumberInPhotoBrowser:(SGTPhotoBrowser *)photoBrowser
{
    return self.selectedAssetsArray.count;
}

- (BOOL)photoBrowser:(SGTPhotoBrowser *)photoBrowser currentPhotoAssetIsSeleted:(SGTImageAsset *)asset{
    return [self assetIsSelected:asset];
}

- (BOOL)photoBrowser:(SGTPhotoBrowser *)photoBrowser seletedAsset:(SGTImageAsset *)asset
{
    BOOL seleted = [self seletedAssets:asset];
    [self.imageFlowCollectionView reloadData];
    return seleted;
}

- (void)photoBrowser:(SGTPhotoBrowser *)photoBrowser deseletedAsset:(SGTImageAsset *)asset
{
    [self deseletedAssets:asset];
    [self.imageFlowCollectionView reloadData];
}

- (void)photoBrowser:(SGTPhotoBrowser *)photoBrowser seleteFullImage:(BOOL)fullImage
{
    self.isFullImage = fullImage;
}
@end