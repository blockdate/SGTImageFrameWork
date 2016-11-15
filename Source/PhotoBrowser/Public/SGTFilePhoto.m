//
//  SGTFilePhoto.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTFilePhoto.h"
#import <Photos/Photos.h>

@interface SGTPhoto()
- (void)imageLoadingComplete;
@end

@interface SGTFilePhoto()

@property (nonatomic, nonnull, copy) NSString *filePath;

@end

@implementation SGTFilePhoto

@synthesize filePath=_filePath;
- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        self.filePath = filePath;
        self.preferFilePath = [filePath stringByDeletingLastPathComponent];
    }
    return self;
}

- (NSUInteger)size {
    NSFileManager *filemanager = [NSFileManager defaultManager];
    BOOL isderectory;
    if([filemanager fileExistsAtPath:self.filePath isDirectory:&isderectory]){
        
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:self.filePath error:nil];
        
        // file size
        NSNumber *theFileSize;
        theFileSize = [attributes objectForKey:NSFileSize];
        if (theFileSize) {
            return [theFileSize unsignedIntegerValue];
        }
    }
    return 0;
}

- (void)loadUnderlyingImageAndNotify {
    [super loadUnderlyingImageAndNotify];
    [self performSelectorInBackground:@selector(loadImageFromFileAsync) withObject:nil];
}

- (void)unloadUnderlyingImage {
    [super unloadUnderlyingImage];
}

- (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (image.images)
    {
        // Do not decode animated images
        return image;
    }
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    // If failed, return undecompressed image
    if (!context) return image;
    
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

- (void)loadImageFromFileAsync {
    @autoreleasepool {
        @try {
            self.underlyingImage = [UIImage imageWithContentsOfFile:self.filePath];
            if (!self.underlyingImage) {
            }
        } @finally {
            self.underlyingImage = [self decodedImageWithImage: self.underlyingImage];
            [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)saveToAlbum:(void (^)(BOOL))finish {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        
        NSURL *url = [NSURL URLWithString:self.filePath];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"finisj error:%@ success %d",error,success);
            if (finish) {
                finish(success);
            }
        }];
    }else {
        NSLog(@"file not exit at %@", self.filePath);
    }
}

- (NSString *)fullLocalFilePath {
    return self.filePath;
}

@end
