//
//  SGTPhotoAssetViewCell.h
//  Demo
//
//  Created by 吴磊 on 2016/11/10.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>
#import "SGTPhotoProtocol.h"

@class SGTPhotoAssetViewCell;
@protocol SGTPhotoAssetViewCellStatuChangeDelegate <NSObject>

- (void)sgtPhotoAssetViewCellStatuChanged:(SGTPhotoAssetViewCell * _Nonnull)cell;

@end

@class SGTAssetsViewCell,SGTImageAsset;
@interface SGTPhotoAssetViewCell : UICollectionViewCell
@property (nonatomic, nonnull, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong, nullable) id<SGTPhotoSelectProtocol> photo;
@property (nonatomic, weak, nullable) id<SGTPhotoAssetViewCellStatuChangeDelegate> delegate;

- (void)fillWithPhoto:(id<SGTPhotoSelectProtocol> _Nonnull)asset;

@end
