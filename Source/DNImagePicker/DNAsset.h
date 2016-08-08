//
//  DNAsset.h
//  ImagePicker
//
//  Created by Block on 15/3/6.
//  Copyright (c) 2015年 Block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface DNAsset : NSObject

@property (nonatomic, strong) ALAsset *alAsset;

@property (nonatomic, strong) UIImage *imageAsset;

/**
 *  ALAsset Url or UIImage create timerinterval
 */
@property (nonatomic, strong) NSURL *url;

/**
 *  get thumbnail image from ALAsset or original image from UIImage
 */
@property (nonatomic, readonly, strong) UIImage *image;

/**
 *  get the FullScreenImage from Alasset or original image from UIImage
 *
 *  @return
 */
- (UIImage *)fullScreenImage;


- (BOOL)isEqualToAsset:(DNAsset *)asset;

/**
 *  使用ALAsset初始化资源
 *
 *  @param asset ALAsset
 *
 *  @return instancetype
 */
- (instancetype)initWithAlasset:(ALAsset *)asset;

/**
 *  使用UIImage初始化资源
 *
 *  @param image UIImage
 *
 *  @return instancetype
 */
- (instancetype)initWithImage:(UIImage *)image;

/**
 *  set AlAssetLibrary for the ALAsset source
 *
 *  @param library AlAssetLibrary
 */
+ (void)setSharedLibrary:(ALAssetsLibrary *)library;

/**
 *  clear AlAssetLibrary for the ALAsset source
 *  and the ALAsset will be no effect
 *
 *  @param library
 */
+ (void)clearSharedLibrary:(ALAssetsLibrary *)library;

/**
 *  AlAssetLibrary for the ALAsset source
 *
 *  @return AlAssetLibrary for the ALAsset source
 */
+ (ALAssetsLibrary *)sharedLibrary;
- (NSString *)imageName;
- (NSString *)imageDirectory;
- (void)writeToFile:(NSString *)filePath;
- (NSString *)saveToDisk;

@end
