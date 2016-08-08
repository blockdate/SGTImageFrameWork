//
//  DNAssetsViewCell.h
//  ImagePicker
//
//  Created by DingXiao on 15/2/11.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>

@class DNAssetsViewCell,DNAsset;

@protocol DNAssetsViewCellDelegate <NSObject>
@optional

- (void)didSelectItemAssetsViewCell:(DNAssetsViewCell *)assetsCell;
- (void)didDeselectItemAssetsViewCell:(DNAssetsViewCell *)assetsCell;
@end

@interface DNAssetsViewCell : UICollectionViewCell

@property (nonatomic, strong) DNAsset *asset;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, weak) id<DNAssetsViewCellDelegate> delegate;

- (void)fillWithAsset:(DNAsset *)asset isSelected:(BOOL)seleted;

@end
