//
//  SGTAssetPhoto.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTAssetPhoto.h"
#import <Photos/Photos.h>

@interface SGTPhoto()
- (void)imageLoadingComplete;
@end

@interface SGTAssetPhoto() {
    NSUInteger _requestID;
}

@property (nonatomic, nullable, strong) PHAsset *imageAssert;
@property (nonatomic, nullable, strong) NSDictionary *imageInfo;
@end

@implementation SGTAssetPhoto

- (instancetype)initWithAsset:(PHAsset *)imageAsset {
    self = [super init];
    if (self) {
        self.imageAssert = imageAsset;
    }
    return self;
}

- (NSUInteger)size {
    return 0;
}

- (void)loadUnderlyingImageAndNotify {
    [super loadUnderlyingImageAndNotify];
    static PHImageRequestOptions *requestOptions;
    if (!requestOptions) {
        requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    }
    __weak typeof(self) weakSelf = self;
    _requestID = [[PHImageManager defaultManager] requestImageForAsset:self.imageAssert targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        strongSelf.underlyingImage = result;
        strongSelf.imageInfo = info;
        [strongSelf performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
    }];
}

- (void)unloadUnderlyingImage {
    [super unloadUnderlyingImage];
    self.imageAssert = nil;
    self.imageInfo = nil;
}

@end
