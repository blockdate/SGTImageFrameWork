//
//  SGTPhoto.h
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/2.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTPhotoProtocol.h"

@class PHAsset,PHPhotoLibrary;

@interface SGTPhoto : NSObject <SGTPhotoSelectProtocol>
// Progress download block, used to update the circularView
typedef void (^SGTPhotoProgressUpdateBlock)(CGFloat progress);

@property (nonatomic) CGSize preferSize;
@property (nonatomic, nullable) NSString *preferFilePath;
@property (nonatomic) BOOL isSelect;
@property (nonatomic, strong, nullable) NSString *caption;
@property (nonatomic, strong, nullable) SGTPhotoProgressUpdateBlock progressUpdateBlock;
@property (nonatomic, strong, nullable) UIImage *placeholderImage;
@property (nonatomic, strong, nullable) UIImage *underlyingImage;
@property (nonatomic, assign) BOOL loadingInProgress;
@property (nonatomic, nullable, weak) id<SGTPhotoSelectStatueChangeDelegate> delegate;

@end
