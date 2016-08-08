//
//  CTAssetsViewController.m
//  QianKr
//
//  Created by 磊吴 on 15/6/30.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import "CTAssetsViewController.h"
#import "CTAssetHead.h"
#import "CTAssetsViewCell.h"
#import "CTAssetsSupplementaryView.h"
#import "CTAssetsPickerController.h"
#import "PickPhotoFromCameraCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CTImagePickBottomView.h"
#import "PhotoBroswerVC.h"
#import "CTAssetsGroupViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface CTAssetsViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CTImagePickBottomViewDelegate>

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CTImagePickBottomView *bottomView;
@end

#define kAssetsViewCellIdentifier           @"AssetsViewCellIdentifier"
#define kAssetsSupplementaryViewIdentifier  @"AssetsSupplementaryViewIdentifier"

@implementation CTAssetsViewController

- (id)init
{
    if (self = [super init])
    {
        
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
        self.preferredContentSize = kPopoverContentSize;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self setupButtons];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssets];
}



#pragma mark - Setup

- (void)setupViews
{
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.footerReferenceSize          = CGSizeMake(0, 44.0);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-64-49) collectionViewLayout:layout];
    
    _collectionView.allowsMultipleSelection = YES;
    
    [_collectionView registerClass:[CTAssetsViewCell class]
        forCellWithReuseIdentifier:kAssetsViewCellIdentifier];
    [_collectionView registerClass:[PickPhotoFromCameraCell class]
        forCellWithReuseIdentifier:@"PickPhotoFromCameraCell"];
    [_collectionView registerClass:[CTAssetsSupplementaryView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:kAssetsSupplementaryViewIdentifier];
    [self.view addSubview:self.collectionView];
    _bottomView = [[CTImagePickBottomView alloc] initWithFrame:CGRectMake(0, ScreenHeight-64-49, ScreenWidth, 49)];
    _bottomView.count = 0;
    _bottomView.delegate = self;
    _bottomView.limitCount = @(((CTAssetsPickerController *)self.navigationController).maximumNumberOfSelection);
    [self.view addSubview:_bottomView];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)setupButtons
{
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(dismiss:)];
}

- (void)setupAssets
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        
        if (asset)
        {
            [self.assets addObject:asset];
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            if ([type isEqual:ALAssetTypePhoto])
                self.numberOfPhotos ++;
            if ([type isEqual:ALAssetTypeVideo])
                self.numberOfVideos ++;
        }
        
        else if (self.assets.count > 0)
        {
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionTop
                                                animated:YES];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return self.assets.count;
    return self.assets.count+1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger off = 2;
    return CGSizeMake((ScreenWidth - 3*off)/3,(ScreenWidth - 3*off)/3);
//    return CGSizeMake(100, 100);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(0, 44.0);;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (indexPath.row == 0 && indexPath.section == 0) {
        static NSString *CellIdentifier1 = @"PickPhotoFromCameraCell";
        
        PickPhotoFromCameraCell *mcell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier1 forIndexPath:indexPath];
        
        cell = mcell;
    }else {
        static NSString *CellIdentifier2 = kAssetsViewCellIdentifier;
        
        CTAssetsViewCell *mcell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier2 forIndexPath:indexPath];
//        [mcell bind:[self.assets objectAtIndex:indexPath.row]];
        [mcell bind:[self.assets objectAtIndex:indexPath.row-1]];
        cell = mcell;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *viewIdentifiert = kAssetsSupplementaryViewIdentifier;
    
    CTAssetsSupplementaryView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:viewIdentifiert forIndexPath:indexPath];
    
    [view setNumberOfPhotos:self.numberOfPhotos numberOfVideos:self.numberOfVideos];
    
    return view;
}


#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CTAssetsPickerController *vc = (CTAssetsPickerController *)self.navigationController;
    
    return ([collectionView indexPathsForSelectedItems].count < vc.maximumNumberOfSelection);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self openCamera];
        return;
    }
    [self setTitleWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return;
    }
    [self setTitleWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}

#pragma mark - Imagepicker delegate 

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    WS(weakSelf);
    //    先判断资源是否是图片资源
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    //    系统预置的图片类型常量
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //        取得图片
        UIImage *image = info[UIImagePickerControllerEditedImage];
        
//        NSURL *assetUrl = info[UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *lib = [CTAssetsGroupViewController defaultAssetsLibrary];
        [lib saveImage:image toAlbum:[_assetsGroup valueForProperty:ALAssetsGroupPropertyName] withCompletionBlock:^(NSURL *assetURL, NSError *error) {
            [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.assets insertObject:asset atIndex:0];
                    [weakSelf.collectionView reloadData];
                });
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf showHint:@"获取拍摄图片错误" yOffset:-20];
                });
            }];

        }];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - CTImagePickBottomViewDelegate

- (void)ctImagePickBottomView:(CTImagePickBottomView *)view tapButtonAtIndex:(NSInteger)index {
    if (index == 0) {
        [self showSelectedImageInGallery:self.collectionView.indexPathsForSelectedItems];
    }else {
        [self finishPickingAssets:nil];
    }
}

#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)indexPaths
{
    self.bottomView.count = @(indexPaths.count);
    // Reset title to group name
    if (indexPaths.count == 0)
    {
        self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        return;
    }
    
    BOOL photosSelected = NO;
    BOOL videoSelected  = NO;
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        ALAsset *asset = [self.assets objectAtIndex:indexPath.item];
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto])
            photosSelected  = YES;
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
            videoSelected   = YES;
        
        if (photosSelected && videoSelected)
            break;
    }
    
    NSString *format;
    
    if (photosSelected && videoSelected)
        format = NSLocalizedString(@"%d Items Selected", nil);
    
    else if (photosSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"%d Photos Selected", nil) : NSLocalizedString(@"%d Photo Selected", nil);
    
    else if (videoSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"%d Videos Selected", nil) : NSLocalizedString(@"%d Video Selected", nil);
    
    self.title = [NSString stringWithFormat:format, indexPaths.count];
    
}


#pragma mark - Actions

- (void)showSelectedImageInGallery:(NSArray *)indexPaths {
    // Reset title to group name
    if (indexPaths.count == 0)
    {
        return;
    }
    
    NSMutableArray *imageAssetArray = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths)
    {
        ALAsset *asset = [self.assets objectAtIndex:indexPath.item];
        [imageAssetArray addObject:asset];
    }
    
    [self localImage:indexPaths Show:imageAssetArray];
}

-(void)localImage:(NSArray *)indexPaths Show:(NSArray *)imageAssetArray{
    
    __weak typeof(self) weakSelf=self;
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:0 photoModelBlock:^NSArray *{
        
        NSArray *localImages = imageAssetArray;
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:localImages.count];
        for (NSUInteger i = 0; i< localImages.count; i++) {
            NSIndexPath *indexP = indexPaths[i];
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i + 1;
//            pbModel.title = [NSString stringWithFormat:@"这是标题%@",@(i+1)];
//            pbModel.desc = [NSString stringWithFormat:@"我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字我是一段很长的描述文字%@",@(i+1)];
            ALAsset *asset = localImages[i];
            ALAssetRepresentation *rep = asset.defaultRepresentation;
            pbModel.image = [UIImage imageWithCGImage:[rep fullScreenImage]];
            
            //源frame
            CTAssetsViewCell *cell = (CTAssetsViewCell *)[weakSelf collectionView:weakSelf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexP.row inSection:0]];
            UIImageView *imageV =(UIImageView *) cell.imageView;
            pbModel.sourceImageView = imageV;
            pbModel.sourceFrame = CGRectMake(0, 0, rep.dimensions.width, rep.dimensions.height);
            [modelsM addObject:pbModel];
        }
        
        return modelsM;
    }];
}

- (void)dismiss:(id)sender
{
    CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
    
    if ([picker.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
        [picker.delegate assetsPickerControllerDidCancel:picker];
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)finishPickingAssets:(id)sender
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        [assets addObject:[self.assets objectAtIndex:indexPath.item]];
    }
    if (_shouldDismissWhenFinished) {
        CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
        
        if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
            [picker.delegate assetsPickerController:picker didFinishPickingAssets:assets];
        
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];

    }else {
//        TODO:
    }
    
}

- (void)openCamera {
    //            先判断资源是否可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self loadSourceWithType:UIImagePickerControllerSourceTypeCamera];
    }else{
        [self showAlterWithMessage:@"相机不可用"];
    }
}

- (void)loadSourceWithType:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    //    是否对相册资源进行自动处理
    picker.allowsEditing = YES;
    //
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)showAlterWithMessage:(NSString *)message{
    UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alt show];
}

@end
