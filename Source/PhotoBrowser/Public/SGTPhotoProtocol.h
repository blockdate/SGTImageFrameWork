//
//  SGTPhotoProtocol.h
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/2.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset,PHPhotoLibrary;

@protocol SGTPhotoProtocol <NSObject>

@required

+ (instancetype _Nonnull)photoWithImage:(UIImage * _Nonnull)image;
+ (instancetype _Nonnull)photoWithFilePath:(NSString *_Nonnull)path;
+ (instancetype _Nonnull)photoWithURL:(NSURL *_Nonnull)url;
+ (instancetype _Nonnull)photoWithPhoto:(PHAsset *_Nonnull)asset;

+ (NSArray<SGTPhotoProtocol> *_Nonnull)photosWithImages:(NSArray<UIImage *> *_Nonnull)imagesArray;
+ (NSArray<SGTPhotoProtocol> *_Nonnull)photosWithFilePaths:(NSArray<NSString *> *_Nonnull)pathsArray;
+ (NSArray<SGTPhotoProtocol> *_Nonnull)photosWithURLs:(NSArray<NSURL *> *_Nonnull)urlsArray;
+ (NSArray<SGTPhotoProtocol> *_Nonnull)photosWithPhotos:(NSArray<PHAsset *> *_Nonnull)assetArray;

@property (nonatomic, strong, nullable) UIImage *underlyingImage;

- (NSUInteger)size;

/**
 用于显示的完整图片

 @return Image to show
 */
- ( UIImage * _Nullable )fullImage;

/**
 用于显示的缩略图

 @return thumbnail image
 */
- ( UIImage * _Nullable )thumbnail;

/**
 当需要加载该图片资源时调用，当加载完成或者失败之后发送相应通知
 [[NSNotificationCenter defaultCenter] postNotificationName:IDMPhoto_LOADING_DID_END_NOTIFICATION
                                                      object:self];
 */
- (void)loadUnderlyingImageAndNotify;

/**
 用于在视图控制器销毁时，护着内存告急时销毁释放图片
 */
- (void)unloadUnderlyingImage;

@optional


/**
 蒙层文字

 @return the des of caption
 */
- ( NSString * _Nullable )caption;


/**
 异步加载等待时显示的占位视图

 @return placeholderImage while image is loading
 */
- ( UIImage * _Nullable )placeholderImage;

@end

@protocol SGTPhotoSelectProtocol <SGTPhotoProtocol>

@property (nonatomic) BOOL isSelect;

@end
