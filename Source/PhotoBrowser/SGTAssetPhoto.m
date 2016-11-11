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
- (void)imageLoadingStarted;
- (void)imageLoadingComplete;
- (void)imageLoadCompleteWithNoNotify;
@end

@interface SGTAssetPhoto() {
    NSUInteger _requestID;
}

@property (nonatomic, nullable, strong) PHAsset *imageAssert;
@property (nonatomic, nullable, strong) NSDictionary *imageInfo;
@end

@implementation SGTAssetPhoto
static PHImageRequestOptions *requestOptions;
- (instancetype)initWithAsset:(PHAsset *)imageAsset {
    self = [super init];
    if (self) {
        self.imageAssert = imageAsset;
        self.preferSize = PHImageManagerMaximumSize;
        if (!requestOptions) {
            requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        }
    }
    return self;
}

- (NSUInteger)size {
    return 0;
}

- (void)loadUnderlyingImageAndNotify {
    [super loadUnderlyingImageAndNotify];
    
    __weak typeof(self) weakSelf = self;
    _requestID = [[PHImageManager defaultManager] requestImageForAsset:self.imageAssert targetSize:self.preferSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        strongSelf.underlyingImage = result;
        strongSelf.imageInfo = info;
        [strongSelf performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
    }];
}

- (void)loadUnderlyImageFinished:(void (^)(id<SGTPhotoProtocol> _Nonnull))finished {
    [self imageLoadingStarted];
    __weak typeof(self) weakSelf = self;
    _requestID = [[PHImageManager defaultManager] requestImageForAsset:self.imageAssert targetSize:self.preferSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        strongSelf.underlyingImage = result;
        strongSelf.imageInfo = info;
        finished(strongSelf);
        [strongSelf performSelectorOnMainThread:@selector(imageLoadCompleteWithNoNotify) withObject:nil waitUntilDone:NO];
    }];
}

- (void)unloadUnderlyingImage {
    [super unloadUnderlyingImage];
    self.imageInfo = nil;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SGTAssetPhoto class]]) {
        SGTAssetPhoto *photo = (SGTAssetPhoto *)object;
        return [self.imageAssert isEqual:photo.imageAssert];
    }
    if ([object isKindOfClass:[PHAsset class]]) {
        PHAsset *photo = (PHAsset *)object;
        return [self.imageAssert isEqual:photo];
    }
    return NO;
}

@end
