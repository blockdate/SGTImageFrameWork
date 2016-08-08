//
//  DNPhotoBrowserViewController.h
//  ImagePicker
//
//  Created by block on 15/2/28.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SGTImageFlowViewController;
@class SGTPhotoBrowser,SGTImageAsset;
@protocol SGTPhotoBrowserDelegate <NSObject>

@required
- (void)sendImagesFromPhotobrowser:(SGTPhotoBrowser *)photoBrowse currentAsset:(SGTImageAsset *)asset;
- (NSInteger)seletedPhotosNumberInPhotoBrowser:(SGTPhotoBrowser *)photoBrowser;
- (BOOL)photoBrowser:(SGTPhotoBrowser *)photoBrowser currentPhotoAssetIsSeleted:(SGTImageAsset *)asset;
- (BOOL)photoBrowser:(SGTPhotoBrowser *)photoBrowser seletedAsset:(SGTImageAsset *)asset;
- (void)photoBrowser:(SGTPhotoBrowser *)photoBrowser deseletedAsset:(SGTImageAsset *)asset;
- (void)photoBrowser:(SGTPhotoBrowser *)photoBrowser seleteFullImage:(BOOL)fullImage;
@end

@interface SGTPhotoBrowser : UIViewController

@property (nonatomic, weak) id<SGTPhotoBrowserDelegate> delegate;

- (instancetype)initWithPhotos:(NSArray *)photosArray
                  currentIndex:(NSInteger)index
                     fullImage:(BOOL)isFullImage;

- (void)hideControls;
- (void)toggleControls;
@end
