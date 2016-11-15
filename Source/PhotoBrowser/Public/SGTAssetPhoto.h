//
//  SGTAssetPhoto.h
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTPhoto.h"
@class PHAsset,PHPhotoLibrary;

@interface SGTAssetPhoto : SGTPhoto

- (instancetype _Nonnull)initWithAsset:(PHAsset * _Nonnull)imageAsset;

@end
