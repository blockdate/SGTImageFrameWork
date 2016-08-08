//
//  DNAssetsViewCell.h
//  ImagePicker
//
//  Created by block on 15/2/11.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>

@class SGTAssetsViewCell,SGTImageAsset;

@protocol SGTAssetsViewCellDelegate <NSObject>
@optional

- (void)didSelectItemAssetsViewCell:(SGTAssetsViewCell *)assetsCell;
- (void)didDeselectItemAssetsViewCell:(SGTAssetsViewCell *)assetsCell;
@end

@interface SGTAssetsViewCell : UICollectionViewCell

@property (nonatomic, strong) SGTImageAsset *asset;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, weak) id<SGTAssetsViewCellDelegate> delegate;

- (void)fillWithAsset:(SGTImageAsset *)asset isSelected:(BOOL)seleted;

@end
