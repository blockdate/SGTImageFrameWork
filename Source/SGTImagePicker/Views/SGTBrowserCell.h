//
//  DNBrowserCell.h
//  ImagePicker
//
//  Created by block on 15/2/28.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class SGTPhotoBrowser,SGTImageAsset;

@interface SGTBrowserCell : UICollectionViewCell

@property (nonatomic, weak) SGTPhotoBrowser *photoBrowser;

@property (nonatomic, strong) ALAsset *asset;

@end
