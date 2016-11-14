//
//  SGTPhotoFlowViewController.m
//  Demo
//
//  Created by 吴磊 on 2016/11/8.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <Photos/Photos.h>
#import <Masonry/Masonry.h>
#import "SGTPhotoFlowViewController.h"
#import "SGTPhotoAssetViewCell.h"
#import "SGTPhoto.h"
#import "SGTPhotoMarco.h"
#import "SGTAssetPhoto.h"
#import "UIImage+Extend.h"
#import "UIViewController+SGTImagePicker.h"
#import "NSBundle+SGTCurrent.h"
#import "SGTAlbumListViewController.h"
#import "UIView+SGTImagePicker.h"
#import "ImagePickerTitleButton.h"
#import "SelectedPhotoGalleryView.h"
#import "SGTPhotoBrowserPicker.h"
#import "UIView+Extend.h"
#import "SGTPhotoPickerControllerDelegate.h"
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define kSizeThumbnailCollectionView  ([UIScreen mainScreen].bounds.size.width-10)/4

@interface SGTAssetPhoto()
@property (nonatomic, nullable, strong) PHAsset *imageAssert;
@property (nonatomic, nullable, strong) NSDictionary *imageInfo;
@end

@interface SGTPhotoFlowViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, SGTPhotoAssetViewCellStatuChangeDelegate, SGTSelectedPhotoGalleryViewDelegate, SGTPhotoBrowserPickerDelegate> {
    
    PHFetchResult<PHAsset *> *_photoAssetList;
}

#pragma mark - View

/**
 the collection view to show the current album photo
 */
@property (nonatomic, strong) UICollectionView *photoFlowCollectionView;

/**
 title button to show the albums list
 */
@property (nonatomic, nonnull, strong) ImagePickerTitleButton *titleButton;

/**
 the album list tableview
 */
@property (nonatomic, nonnull, strong) UITableView *albumsTableView;

@property (nonatomic, nonnull, strong) UIView *bottomToolBar;

@property (nonatomic, nonnull, strong) UIButton *closeButton;

@property (nonatomic, nonnull, strong) UIButton *doneButton;

@property (nonatomic, nonnull, strong) UILabel *selectCountLabel;

@property (nonatomic, nonnull, strong) SelectedPhotoGalleryView *selectedPhotoGalleryView;

#pragma mark - Data

/**
 the album array
 */
@property (nonatomic, nonnull, strong) NSMutableArray<PHAssetCollection *> *photoCollectionArray;

/**
 the selected album photocollection
 */
@property (nonatomic, nonnull, strong) PHAssetCollection *photoCollection;

/**
 thpe photo collect fetch result array, this array contain the system photocollection and custom photocollection
 */
@property (nonatomic, strong) NSArray *photoCollectionFetchResultArray;

/**
 the selected photos
 */
@property (nonatomic, nonnull, strong) NSMutableArray<SGTPhotoSelectProtocol> *selectedPhoto;

/**
 the photo array for current album
 */
@property (nonatomic, nonnull, strong) NSMutableArray<SGTPhotoSelectProtocol> *photoArray;

/**
 update the assetCollections on init ,it will initialize the albums list and choose the first album as current to show of
 */
- (void)updateAssetCollections;

/**
 reload the current album
 */
- (void)reloadCurrentAlbum;

/**
 send the selected photot and self to the receiver, triggle on send button clicked

 @param sender the send button
 */
- (void)sendButtonAction:(id)sender;

/**
 preview the selected image on photobrowser
 */
- (void)previewAction;

/**
 cancle the photo pick action
 */
- (void)cancelAction;
@end

@implementation SGTPhotoFlowViewController

#pragma mark - Object

- (instancetype) init {
    self = [super init];
    if (self) {
        _maxPickCount = 9;
//        the albums managed by system, modify was forbidden
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
//        the albums create by user or import from itunes
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        self.photoCollectionFetchResultArray = @[smartAlbums,userAlbums];
        self.selectedPhoto = [NSMutableArray<SGTPhotoSelectProtocol> array];
    }
    return self;
}

-(void)dealloc {
    for (UIViewController *controller in self.childViewControllers) {
        [controller removeFromParentViewController];
    }
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleButton = [[ImagePickerTitleButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    [self.titleButton addTarget:self action:@selector(titleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleButton;
    
//    [self createBarButtonItemAtPosition:Left
//                      statusNormalImage:[UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"back_normal"]
//                   statusHighlightImage:[UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"back_highlight"]
//                                 action:@selector(backButtonAction)];
//    [self createBarButtonItemAtPosition:Right
//                                   text:NSLocalizedStringFromTableInBundle(@"cancel", @"SGTImagePickerController", [NSBundle sgt_currentBundle], @"取消")
//                                 action:@selector(cancelAction)];
    
    [self.view addSubview:self.photoFlowCollectionView];
    [self.view addSubview:self.bottomToolBar];
    [self.view addSubview:self.selectedPhotoGalleryView];
    self.photoFlowCollectionView.frame = CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 49);
    self.bottomToolBar.frame = CGRectMake(0, ScreenHeight - 49, ScreenWidth, 49);
    self.selectedPhotoGalleryView.frame = CGRectMake(ScreenWidth + 1, ScreenHeight - kSizeThumbnailCollectionView - 4 - 49, ScreenWidth, kSizeThumbnailCollectionView + 4);
//    [self.photoFlowCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.view);
//        make.top.equalTo(self.mas_topLayoutGuideBottom);
//        make.bottom.equalTo(self.bottomToolBar.mas_top);
//    }];
//    [self.bottomToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.right.and.bottom.equalTo(self.view);
//        make.height.equalTo(@(49));
//    }];
    
    [self updateAssetCollections];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
}

#pragma mark - Datas

- (void)releaseAllUnderlyingPhotos {
    for (id p in _photoArray) { if (p != [NSNull null]) [p unloadUnderlyingImage]; } // Release photos
}

- (void)updateAssetCollections {
    // Filter albums
    NSArray *assetCollectionSubtypes = @[
                                         @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                         @(PHAssetCollectionSubtypeAlbumMyPhotoStream)
                                         ];//self.assetCollectionSubtypes;
    NSMutableDictionary *smartAlbums = [NSMutableDictionary dictionaryWithCapacity:assetCollectionSubtypes.count];
    NSMutableArray *userAlbums = [NSMutableArray array];
    
    for (PHFetchResult *fetchResult in self.photoCollectionFetchResultArray) {
        [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
            PHAssetCollectionSubtype subtype = assetCollection.assetCollectionSubtype;
            
            if (subtype == PHAssetCollectionSubtypeAlbumRegular) {
                [userAlbums addObject:assetCollection];
            } else if ([assetCollectionSubtypes containsObject:@(subtype)]) {
                if (!smartAlbums[@(subtype)]) {
                    smartAlbums[@(subtype)] = [NSMutableArray array];
                }
                [smartAlbums[@(subtype)] addObject:assetCollection];
            }
        }];
    }
    
    NSMutableArray *assetCollections = [NSMutableArray array];
    
    // Fetch smart albums
    for (NSNumber *assetCollectionSubtype in assetCollectionSubtypes) {
        NSArray *collections = smartAlbums[assetCollectionSubtype];
        
        if (collections) {
            [assetCollections addObjectsFromArray:collections];
        }
    }
    
    // Fetch user albums
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
        [assetCollections addObject:assetCollection];
    }];
    
    self.photoCollectionArray = assetCollections;
    self.photoCollection = self.photoCollectionArray.firstObject;
    [self albumsTableView];
    [self reloadCurrentAlbum];
    
}

- (void)reloadCurrentAlbum {
    [self releaseAllUnderlyingPhotos];
    
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:self.photoCollection options:nil];
    NSMutableArray<SGTPhotoSelectProtocol> *photoArray = [NSMutableArray<SGTPhotoSelectProtocol> arrayWithCapacity:result.count];
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SGTAssetPhoto *photo = [SGTAssetPhoto photoWithPhoto:obj];
        if ([self.selectedPhoto containsObject:photo]) {
            photo.isSelect = YES;
        }
        [photoArray addObject:photo];
    }];
    self.photoArray = photoArray;
    [self.titleButton rt_setTitle:self.photoCollection.localizedTitle arrowAppearance:YES];
    [self.photoFlowCollectionView reloadData];
}

- (BOOL)isSelectedPhoto:(PHAsset *)asset {
    if (asset == nil) {
        return NO;
    }
    if ([self.selectedPhoto containsObject:asset]) {
        return YES;
    }
    return NO;
}

- (void)showPhotoCollection:(PHAssetCollection *)photoCollection {
    self.photoCollection = photoCollection;
    [self reloadCurrentAlbum];
    if (self.albumsTableView.top > 0.0f) {
        [self titleButtonPressed:nil];
    }
}

#pragma mark - ui action

- (void)scrollerToBottom:(BOOL)animated {
    NSInteger rows = [self.photoFlowCollectionView numberOfItemsInSection:0] - 1;
    [self.photoFlowCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:rows inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
}

- (void)sendButtonAction:(id)sender {
    if ([self.photoPickerDelegate respondsToSelector:@selector(sgtphotoPickFinishedWithImages:otherInfo:)]) {
        [self.photoPickerDelegate sgtphotoPickFinishedWithImages:self.selectedPhoto otherInfo:nil];
    }
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (void)previewAction {
    
}

- (void)cancelAction {
    if ([self.photoPickerDelegate respondsToSelector:@selector(sgtphotoPickCancled:)]) {
        [self.photoPickerDelegate sgtphotoPickCancled:(SGTPhotoPickerController *)self.navigationController];
    }
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (void)titleButtonPressed:(id)sender {
    if(self.albumsTableView.top < 0.0f) {
        self.title = @"相簿";
//        [titleButton rt_setTitle:[NSString stringWithFormat:@"相簿"] arrowAppearance:NO];
        [self.titleButton rt_setTitle:@"相簿" arrowAppearance:NO];
        [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.albumsTableView.top = 64.0f;
//            self.toolBarView.top = ScreenHeight;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.title = self.photoCollection.localizedTitle;
//        [titleButton rt_setTitle:[NSString stringWithFormat:@"%@",self.assetCollection.localizedTitle] arrowAppearance:YES];
        [self.titleButton rt_setTitle:self.photoCollection.localizedTitle arrowAppearance:YES];
        [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.albumsTableView.top = -ScreenHeight;
//            self.toolBarView.top = ScreenHeight - _toolBarView.height;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)showPhotoBrowser:(NSArray<SGTPhotoSelectProtocol>*)photos imageView:(UIImageView *)imageview startIndex:(NSInteger)index {
    SGTPhotoBrowserPicker *browser = [[SGTPhotoBrowserPicker alloc] initWithSelectedPhotos:photos animatedFromView:imageview];
    [browser setInitialPageIndex:index];
    browser.hideBottomBar = YES;
    [self.navigationController presentViewController:browser animated:YES completion:nil];
}

#pragma mark - Photo Select Action

- (void)addPhoto:(id<SGTPhotoSelectProtocol>)photo {
    if ([self.selectedPhoto containsObject:photo]) {
        return;
    }
    if (self.selectedPhoto.count >= _maxPickCount) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"alertTitle", @"SGTImagePickerController", [NSBundle sgt_currentBundle], nil) message:[NSString stringWithFormat:@"图片最多允许选择%@张",@(_maxPickCount)] delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        photo.isSelect = NO;
        return;
    }
    [self.selectedPhoto addObject:photo];
    [self.selectedPhotoGalleryView addPhoto:photo];
    [self updateBottomBar];
//    NSLog(@"photo added");
}

- (void)removePhoto:(id<SGTPhotoSelectProtocol>)photo {
    if ([self.selectedPhoto containsObject:photo]) {
//        NSLog(@"photo removed");
        [self.selectedPhoto removeObject:photo];
        [self.selectedPhotoGalleryView removePhoto:photo];
        [self updateBottomBar];
    }
}

- (void)updateBottomBar {
    if (self.selectedPhoto.count > 0) {
        self.doneButton.enabled = YES;
        self.doneButton.selected = YES;
        if(self.selectedPhotoGalleryView.x > ScreenWidth) {
            [UIView animateWithDuration:0.2 animations:^{
                CGFloat photoGalleryHeight = kSizeThumbnailCollectionView + 4;
                self.selectedPhotoGalleryView.frame = CGRectMake(0, ScreenHeight - photoGalleryHeight- 49, ScreenWidth, photoGalleryHeight);
                self.photoFlowCollectionView.frame = CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 49 - photoGalleryHeight);
            }];
        }else {
            
        }
//        if (_selectedPhotoGalleryView.alpha == 0) {
//            _selectedPhotoGalleryView.alpha = 1;
//            [UIView animateWithDuration:0.12 animations:^{
//                [self.bottomToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.left.and.right.and.bottom.equalTo(self.view);
//                    make.height.equalTo(@(49 + kSizeThumbnailCollectionView + 4));
//                }];
//                [self.bottomToolBar layoutIfNeeded];
//            }];
//            
//        }
    }else {
        self.doneButton.enabled = NO;
        self.doneButton.selected = NO;
        if(self.selectedPhotoGalleryView.x < ScreenWidth) {
            [UIView animateWithDuration:0.2 animations:^{
                CGFloat photoGalleryHeight = kSizeThumbnailCollectionView + 4;
                self.selectedPhotoGalleryView.frame = CGRectMake(ScreenWidth + 1, ScreenHeight - photoGalleryHeight- 49, ScreenWidth, photoGalleryHeight);
                self.photoFlowCollectionView.frame = CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 49);
            }];
        }
//        if (_selectedPhotoGalleryView.alpha == 1) {
//            _selectedPhotoGalleryView.alpha = 0;
//            [UIView animateWithDuration:0.12 animations:^{
//                [self.bottomToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.left.and.right.and.bottom.equalTo(self.view);
//                    make.height.equalTo(@(49));
//                }];
//                
//            }];
//            [self.view layoutIfNeeded];
//        }
    }
}

#pragma mark - UICollectionView delegate and Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SGTPhotoAssetViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SGTPhotoAssetViewCell" forIndexPath:indexPath];
    CGSize itemSize = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
    CGSize targetSize = SGTCGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
    id<SGTPhotoSelectProtocol> photo = self.photoArray[indexPath.row];
    photo.preferSize = targetSize;
    cell.delegate = self;
    [cell fillWithPhoto:photo];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SGTPhotoAssetViewCell *cell = (SGTPhotoAssetViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self showPhotoBrowser:self.photoArray imageView:cell.imageView startIndex:indexPath.row];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(kSizeThumbnailCollectionView, kSizeThumbnailCollectionView);
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

#pragma mark - SGTPhotoAssetViewCellStatuChangeDelegate

- (void)sgtPhotoAssetViewCellStatuChanged:(SGTPhotoAssetViewCell *)cell {
    if (cell.photo) {
        if (cell.photo.isSelect) {
            [self addPhoto:cell.photo];
        }else {
            [self removePhoto:cell.photo];
        }
    }
}

#pragma mark - SGTSelectedPhotoGalleryViewDelegate, SGTPhotoBrowserPickerDelegate

- (void)sgtSelectedPhotoGalleryView:(SelectedPhotoGalleryView *)view statueChaned:(NSInteger)index photo:(id<SGTPhotoSelectProtocol>)photo {
    if (photo.isSelect) {
        [self addPhoto:photo];
    }else {
        [self removePhoto:photo];
    }
}

- (void)sgtPhotoBrowserPickStatuChaned:(SGTPhotoBrowserPicker *)controller atIndex:(NSInteger)index photo:(id<SGTPhotoSelectProtocol>)photo {
    if (photo.isSelect) {
        [self addPhoto:photo];
    }else {
        [self removePhoto:photo];
    }
}

#pragma mark - Getter

- (UICollectionView *)photoFlowCollectionView {
    if (nil == _photoFlowCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 2.0;
        layout.minimumInteritemSpacing = 2.0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _photoFlowCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
        _photoFlowCollectionView.backgroundColor = [UIColor clearColor];
        [_photoFlowCollectionView registerClass:[SGTPhotoAssetViewCell class] forCellWithReuseIdentifier:@"SGTPhotoAssetViewCell"];
        _photoFlowCollectionView.allowsMultipleSelection = NO;
        _photoFlowCollectionView.alwaysBounceVertical = YES;
        _photoFlowCollectionView.delegate = self;
        _photoFlowCollectionView.dataSource = self;
        _photoFlowCollectionView.showsHorizontalScrollIndicator = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        _photoFlowCollectionView.backgroundColor = [UIColor whiteColor];
    }
    
    return _photoFlowCollectionView;
}

- (UITableView *)albumsTableView {
    
    if(nil == _albumsTableView) {
        SGTAlbumListViewController *albumsListController = [[SGTAlbumListViewController alloc] initWithPhotoCollections:self.photoCollectionArray];
        albumsListController.photoFlowViewController = self;
        _albumsTableView = albumsListController.tableView;
        _albumsTableView.frame = CGRectMake(0.0f, -ScreenHeight, ScreenWidth, ScreenHeight - self.navigationController.navigationBar.frame.size.height);
        [self addChildViewController:albumsListController];
        [_albumsTableView removeFromSuperview];
        _albumsTableView.clipsToBounds = true;
        [self.view addSubview:_albumsTableView];
    }
    return _albumsTableView;
}

- (UIView *)bottomToolBar {
    if (nil == _bottomToolBar) {
        _bottomToolBar = [[UIView alloc] init];
        [_bottomToolBar addSubview:[self effectView]];
        [_bottomToolBar addSubview:self.closeButton];
        [_bottomToolBar addSubview:self.doneButton];
        self.closeButton.frame = CGRectMake(20, 12, 25, 25);
        self.doneButton.frame = CGRectMake(ScreenWidth - 45, 12, 25, 25);
    }
    return _bottomToolBar;
}

- (UIView *)effectView {
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    effectView.frame = CGRectMake(0, 0, ScreenWidth, 49);
    return effectView;
}

- (SelectedPhotoGalleryView *)selectedPhotoGalleryView {
    if (nil == _selectedPhotoGalleryView) {
        _selectedPhotoGalleryView = [[SelectedPhotoGalleryView alloc] init];
        _selectedPhotoGalleryView.delegate = self;
        __weak typeof(self)weakSelf = self;
        _selectedPhotoGalleryView.selectPhotoHandle = ^(UIImageView *imageView, NSInteger index) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf showPhotoBrowser:strongSelf.selectedPhoto imageView:imageView startIndex:index];
        };
    }
    return _selectedPhotoGalleryView;
}

- (UIButton *)closeButton {
    if(nil == _closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"icon_close_dark"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}
- (UIButton *)doneButton {
    if(nil == _doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setImage:[UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"icon_finish_light"] forState:UIControlStateNormal];
        [_doneButton setImage:[UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"icon_finish_green"] forState:UIControlStateSelected];
        [_doneButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UILabel *)selectCountLabel {
    if (nil == _selectCountLabel) {
        _selectCountLabel = [[UILabel alloc] init];
        
    }
    return _selectCountLabel;
}

@end
