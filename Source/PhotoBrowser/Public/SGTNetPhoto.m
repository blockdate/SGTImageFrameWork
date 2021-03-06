//
//  SGTNetPhoto.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTNetPhoto.h"
#import <SDWebImage/SDWebImageManager.h>

@interface SGTPhoto()
- (void)imageLoadingComplete;
@end

@interface SGTNetPhoto()
@property (nonatomic, nonnull, copy) NSURL *url;
@end

@implementation SGTNetPhoto

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)loadUnderlyingImageAndNotify {
    [super loadUnderlyingImageAndNotify];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:self.url options:SDWebImageRetryFailed|SDWebImageHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        CGFloat progress = ((CGFloat)receivedSize)/((CGFloat)expectedSize);
        if (self.progressUpdateBlock) {
            self.progressUpdateBlock(progress);
        }
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            self.underlyingImage = image;
            [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)unloadUnderlyingImage {
    [super unloadUnderlyingImage];
}

@end
