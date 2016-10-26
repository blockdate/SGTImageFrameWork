//
//  DNAsset.m
//  ImagePicker
//
//  Created by block on 15/3/6.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import "SGTImageAsset.h"
#import "NSURL+DNIMagePickerUrlEqual.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import "UIImage+Extend.h"

@interface SGTImageAsset()



@end

@interface NSString(MD5)
- (NSString *) MD5String;
@end

@implementation SGTImageAsset

static ALAssetsLibrary* _sharedLibrary = nil;

- (instancetype)initWithAlasset:(ALAsset *)asset {
    self = [super init];
    if (self) {
        _alAsset = asset;
        _url = [asset valueForProperty:ALAssetPropertyAssetURL];

//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [self saveToDisk];
//        });
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _imageAsset = image;
        NSString *s = [NSString stringWithFormat:@"%lf",[[NSDate date] timeIntervalSince1970]];
        _url = [NSURL URLWithString:s];

//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [self saveToDisk];
//        });
    }
    return self;
}

- (UIImage *)image {
    if (_alAsset != nil) {
        CGImageRef thumbnailImageRef = [_alAsset thumbnail];
        return thumbnailImageRef==nil?[UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"assets_placeholder_picture"]:[UIImage imageWithCGImage:thumbnailImageRef];
    }else {
        return _imageAsset;
    }
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return [self isEqualToAsset:other];
    }
}

- (BOOL)isEqualToAsset:(SGTImageAsset *)asset
{
    if ([asset isKindOfClass:[SGTImageAsset class]]) {
        return [self.url isEqualToOther:asset.url];
    } else {
        return NO;
    }
}

- (UIImage *)fullScreenImage {
    if (_alAsset != nil) {
        return [UIImage imageWithCGImage:[[_alAsset defaultRepresentation] fullScreenImage]];
    }else if (_imageAsset != nil) {
        return _imageAsset;
    }
    return nil;
}

+ (ALAssetsLibrary *)sharedLibrary {
    return _sharedLibrary;
}

+ (void)setSharedLibrary:(ALAssetsLibrary *)library {
    _sharedLibrary = library;
}

+ (void)clearSharedLibrary:(ALAssetsLibrary *)library {
    _sharedLibrary = nil;
}

- (NSString *)imageDirectory {
    
    NSString *path = [[self imageCacheDirectory] stringByAppendingPathComponent:[self imageName]];
    return path;
}

- (NSString *)imageName {
    NSString *name = [[[[self url] absoluteString] MD5String] stringByAppendingString:@".jpeg"];
    return name;
}

- (void)writeToFile:(NSString *)filePath {
    
    NSString *path = [self imageCacheDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        NSError *error = nil;
        [manager createDirectoryAtPath:path withIntermediateDirectories:false attributes:nil error:&error];
        if (error) {
            NSLog(@"创建图片临时文件路径失败");
        }
    }
//    NSData *photo = UIImageJPEGRepresentation(UIImage, kCompressionQuality);

    if (self.imageAsset != nil) {
        NSData *data = nil;
        data = UIImagePNGRepresentation(self.image);
        long long imgsize = data.length;
        double scale = maxSize*1.0/imgsize;
        NSLog(@"scale %lf",scale);
        data = UIImageJPEGRepresentation(self.image, scale>=1?0:scale);
//        data = UIImagePNGRepresentation(self.image);
        
        [data writeToFile:filePath atomically:true];
    }else {
//        long long sizeOfRawDataInBytes = [[_alAsset defaultRepresentation] size];
        UIImage *img = [UIImage imageWithCGImage:[[_alAsset defaultRepresentation] fullScreenImage]];
        NSData *data = nil;
        data = UIImagePNGRepresentation(img);
        long long imgsize = data.length;
        double scale = maxSize*1.0/imgsize;
        NSLog(@"scale %lf",scale);
        data = UIImageJPEGRepresentation(img, scale>=1?1:scale);
        
        [data writeToFile:filePath atomically:true];
//        NSMutableData* rawData = [NSMutableData dataWithLength:(NSUInteger) sizeOfRawDataInBytes];
//        void* bufferPointer = [rawData mutableBytes];
//        NSError* error=nil;
//        [[_alAsset defaultRepresentation] getBytes:bufferPointer
//                                        fromOffset:0
//                                            length:sizeOfRawDataInBytes
//                                             error:&error];
//        if (error)
//        {
//            NSLog(@"Getting bytes failed with error: %@",error);
//        }
//        else 
//        {
//            [rawData writeToFile:filePath
//                      atomically:YES];
//        }
    }
}

- (NSString *)imageCacheDirectory {
    NSString *path = [[self cachePath] stringByAppendingPathComponent:@"uploadImage"];
    return path;
}

- (NSString *)saveToDisk {
    NSString *path = [self imageDirectory];
    [self writeToFile:path];
    NSLog(@"save image to %@ success",[self imageDirectory]);
    return path;
}

- (NSString *)cachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return cachesDir;
}


static long long maxSize = 1048576;
+ (void)setMaxSaveSize:(long long) size {
    maxSize = size;
}
+ (long long) maxSavedSize  {
    return maxSize;
}

@end


@implementation NSString (MD5)

- (NSString *) MD5String{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (int)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}
@end
