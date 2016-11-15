//
//  SGTImagePhoto.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/2.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTImagePhoto.h"
#import "NSDate+Extend.h"
#import "NSString+Password.h"
#import <Photos/Photos.h>
@interface SGTPhoto()
- (void)imageLoadingComplete;
@end

@interface SGTImagePhoto()
@property (nonatomic, nonnull, strong) NSString *name;
@end

@implementation SGTImagePhoto

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.underlyingImage = image;
        self.name = [NSDate date].timestamp;
    }
    return self;
}

- (void)loadUnderlyingImageAndNotify {
    [super loadUnderlyingImageAndNotify];
//    image already set with init
    [self imageLoadingComplete];
}

- (void)unloadUnderlyingImage {
//    just release the image by super
    [super unloadUnderlyingImage];
}

- (void)saveToAlbum:(void (^)(BOOL))finish {
    if (self.underlyingImage) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:self.underlyingImage];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"finisj error:%@ success %d",error,success);
            if (finish) {
                finish(success);
            }
        }];
    }else {
        if (finish) {
            finish(NO);
        }
    }
}

- (void)saveToDisk:(void (^)(BOOL))finish {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.underlyingImage) {
            BOOL isDirectory;
            if (![[NSFileManager defaultManager] fileExistsAtPath:self.preferFilePath isDirectory:&isDirectory]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:self.preferFilePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *fullPath = [self fullLocalFilePath];
            NSData *imageData = UIImagePNGRepresentation(self.underlyingImage);
            [imageData writeToFile:fullPath atomically:YES];
            NSLog(@"save to path %@", fullPath);
            if (finish) {
                finish(YES);
            }
        }else {
            if (finish) {
                finish(NO);
            }
        }
    });
}

- (NSString *)fullLocalFilePath {
    
    NSString *name = [self.name md5];
    NSString *fullPath = [self.preferFilePath stringByAppendingPathComponent:name];
    return fullPath;
}

@end
