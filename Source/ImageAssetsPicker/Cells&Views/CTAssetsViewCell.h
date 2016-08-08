//
//  CTAssetsViewCell.h
//  QianKr
//
//  Created by 磊吴 on 15/6/30.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTAssetHead.h"

@interface CTAssetsViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView ;

- (void)bind:(ALAsset *)asset;

@end