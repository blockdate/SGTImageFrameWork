//
//  SGTPhotoPickerController.h
//  Demo
//
//  Created by 吴磊 on 2016/11/8.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PhotosTypes.h>
#import "SGTPhotoPickerControllerDelegate.h"

FOUNDATION_EXTERN NSString * _Nonnull sgtImagePickerStoredGroupKey;

@interface SGTPhotoPickerController : UINavigationController

/**
 the max count of media assert to pick
 */
@property (nonatomic) NSInteger maxPickCount;

/**
 media source type to show , photo assert avaliable only for now
 */
@property (nonatomic) PHAssetMediaType mediaType;

@property (nonatomic, nullable, weak) id<SGTPhotoPickerControllerDelegate> photoPickerDelegate;

- (instancetype _Nonnull)init;
- (instancetype _Nonnull)initWithMaxPickCount:(NSInteger)count;
- (instancetype _Nonnull)initWithMaxPickCount:(NSInteger)count pickerDelegate:(id<SGTPhotoPickerControllerDelegate> _Nullable)delegate;

@end
