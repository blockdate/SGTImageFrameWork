//
//  SGTPhoto.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/2.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTPhoto.h"
#import "SGTPhotoMarco.h"
#import "SGTImagePhoto.h"
#import "SGTFilePhoto.h"
#import "SGTNetPhoto.h"
#import "SGTAssetPhoto.h"

@interface SGTPhoto()
- (void)imageLoadingStarted;
- (void)imageLoadingComplete;
- (void)imageLoadCompleteWithNoNotify;
@end

@implementation SGTPhoto

#pragma mark - ClassMethod

+ (instancetype)photoWithImage:(UIImage *)image {
    return [[SGTImagePhoto alloc] initWithImage:image];
}

+ (instancetype)photoWithURL:(NSURL *)url {
    return [[SGTNetPhoto alloc] initWithURL:url];
}

+ (instancetype)photoWithFilePath:(NSString *)path {
    return [[SGTFilePhoto alloc] initWithFilePath:path];
}

+ (instancetype)photoWithPhoto:(PHAsset *)asset {
    return [[SGTAssetPhoto alloc] initWithAsset:asset];
}

+ (NSArray<SGTPhotoProtocol> *)photosWithImages:(NSArray<UIImage *> *)imagesArray {
    NSMutableArray<SGTPhotoProtocol> *photos = [NSMutableArray<SGTPhotoProtocol> arrayWithCapacity:imagesArray.count];
    
    for (UIImage *image in imagesArray) {
        id<SGTPhotoProtocol> photo = [SGTPhoto photoWithImage:image];
        [photos addObject:photo];
    }
    
    return photos;
}

+ (NSArray<SGTPhotoProtocol> *)photosWithFilePaths:(NSArray <NSString *>*)pathsArray {
    NSMutableArray<SGTPhotoProtocol> *photos = [NSMutableArray<SGTPhotoProtocol> arrayWithCapacity:pathsArray.count];
    
    for (NSString *imagePath in pathsArray) {
        id<SGTPhotoProtocol> photo = [SGTPhoto photoWithFilePath:imagePath];
        [photos addObject:photo];
    }
    
    return photos;
}

+ (NSArray<SGTPhotoProtocol> *)photosWithPhotos:(NSArray<PHAsset *> *)assetArray {
    NSMutableArray<SGTPhotoProtocol> *photos = [NSMutableArray<SGTPhotoProtocol> arrayWithCapacity:assetArray.count];
    
    for (PHAsset *image in assetArray) {
        id<SGTPhotoProtocol> photo = [SGTPhoto photoWithPhoto:image];
        [photos addObject:photo];
    }
    
    return photos;
}

+ (NSArray<SGTPhotoProtocol> *)photosWithURLs:(NSArray<NSURL *> *)urlsArray {
    NSMutableArray<SGTPhotoProtocol> *photos = [NSMutableArray<SGTPhotoProtocol> arrayWithCapacity:urlsArray.count];
    
    for (NSURL *image in urlsArray) {
        id<SGTPhotoProtocol> photo = [SGTPhoto photoWithURL:image];
        [photos addObject:photo];
    }
    
    return photos;
}
#pragma mark - SGTPhotoProtocol

- (NSUInteger)size {
    NSAssert(true, @"func size should initialize by child class");
    return 0;
}

- ( UIImage * _Nullable )fullImage {
    return self.underlyingImage;
}

- (UIImage * _Nullable )thumbnail {
    return self.underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    [self imageLoadingStarted];
}

- (void)loadUnderlyImageFinished:(void (^)(id<SGTPhotoProtocol> _Nonnull))finished {
    
}

- (void)unloadUnderlyingImage {
//    NSLog(@"photo unload");
    self.loadingInProgress = false;
    self.underlyingImage = nil;
}

- (NSString *)caption {
    return nil;
}

- (UIImage *)placeholderImage {
    return nil;
}

// Called on main
- (void)imageLoadingComplete {
    [self imageLoadCompleteWithNoNotify];
    [[NSNotificationCenter defaultCenter] postNotificationName:[SGT_Photo_loading_Finish_Notification copy]
                                                        object:self];
}

- (void)imageLoadCompleteWithNoNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
}

- (void)imageLoadingStarted {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = YES;
}

- (void)setIsSelect:(BOOL)isSelect {
    if (_isSelect != isSelect) {
        _isSelect = isSelect;
        if ([_delegate respondsToSelector:@selector(sgtPhotoStatuChanged:)]) {
            [_delegate sgtPhotoStatuChanged:self];
        }
    }
}

@end
