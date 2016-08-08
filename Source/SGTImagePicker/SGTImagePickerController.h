//
//  DNImagePickerController.h
//  ImagePicker
//
//  Created by block on 15/2/10.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGTImageAsset.h"
@class ALAssetsFilter;
FOUNDATION_EXTERN NSString *kDNImagePickerStoredGroupKey;
typedef NS_ENUM(NSUInteger, SGTImagePickerFilterType) {
    None,
    Photos,
    Videos,
};

UIKIT_EXTERN ALAssetsFilter * ALAssetsFilterFromDNImagePickerControllerFilterType(SGTImagePickerFilterType type);

@class SGTImagePickerController;
@protocol SGTImagePickerControllerDelegate <NSObject>
@optional
/**
 *  imagePickerController‘s seleted photos
 *
 *  @param imagePickerController
 *  @param imageAssets           the seleted photos packaged DNAsset type instances
 *  @param fullImage             if the value is yes, the seleted photos is full image
 */
- (void)dnImagePickerController:(SGTImagePickerController *)imagePicker
                     sendImages:(NSArray<SGTImageAsset *> *)imageAssets
                    isFullImage:(BOOL)fullImage;

- (void)dnImagePickerControllerDidCancel:(SGTImagePickerController *)imagePicker;
@end


@interface SGTImagePickerController : UINavigationController

@property (nonatomic, assign) NSInteger kDNImageFlowMaxSeletedNumber;
@property (nonatomic, assign) SGTImagePickerFilterType filterType;
@property (nonatomic, weak) id<SGTImagePickerControllerDelegate> imagePickerDelegate;
- (instancetype)initWithMaxCount:(NSInteger)maxCount;
@end
