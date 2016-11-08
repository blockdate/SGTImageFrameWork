//
//  DNPhotoBrowserViewController.h
//  ImagePicker
//
//  Created by block on 15/2/28.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SGTImageFlowViewController;
@class SGTPhotoPickerBrowser,SGTImageAsset;

@protocol SGTPhotoPickerBrowserDelegate <NSObject>

@required
- (void)sendImagesFromPhotobrowser:(SGTPhotoPickerBrowser *)photoBrowse currentAsset:(SGTImageAsset *)asset;
- (NSInteger)seletedPhotosNumberInPhotoBrowser:(SGTPhotoPickerBrowser *)photoBrowser;
- (BOOL)photoBrowser:(SGTPhotoPickerBrowser *)photoBrowser currentPhotoAssetIsSeleted:(SGTImageAsset *)asset;
- (BOOL)photoBrowser:(SGTPhotoPickerBrowser *)photoBrowser seletedAsset:(SGTImageAsset *)asset;
- (void)photoBrowser:(SGTPhotoPickerBrowser *)photoBrowser deseletedAsset:(SGTImageAsset *)asset;
- (void)photoBrowser:(SGTPhotoPickerBrowser *)photoBrowser seleteFullImage:(BOOL)fullImage;
@end

NS_CLASS_DEPRECATED_IOS(4_0, 7_0, "Use SGTPhotoBrowserPicker instead")
@interface SGTPhotoPickerBrowser : UIViewController

@property (nonatomic, weak) id<SGTPhotoPickerBrowserDelegate> delegate;

- (instancetype)initWithPhotos:(NSArray *)photosArray
                  currentIndex:(NSInteger)index
                     fullImage:(BOOL)isFullImage;

- (void)hideControls;
- (void)toggleControls;
@end
