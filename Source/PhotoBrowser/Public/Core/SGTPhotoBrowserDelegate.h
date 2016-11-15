//
//  SGTPhotoBrowserProtocol.h
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGTPhotoProtocol.h"

@class SGTPhotoBrowser,SGTCaptionView,SGTPhoto;

@protocol SGTPhotoBrowserDelegate <NSObject>
@optional
- (void)willAppearPhotoBrowser:(SGTPhotoBrowser * _Nonnull)photoBrowser;
- (void)willDisappearPhotoBrowser:(SGTPhotoBrowser * _Nonnull)photoBrowser;
- (void)photoBrowser:(SGTPhotoBrowser * _Nonnull)photoBrowser didShowPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(SGTPhotoBrowser * _Nonnull)photoBrowser didDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(SGTPhotoBrowser * _Nonnull)photoBrowser willDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(SGTPhotoBrowser * _Nonnull)photoBrowser didDismissActionSheetWithButtonIndex:(NSUInteger)buttonIndex photoIndex:(NSUInteger)photoIndex;
- (SGTCaptionView * _Nullable)photoBrowser:(SGTPhotoBrowser * _Nonnull)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
@end


/**
 this protocol is used to pick photo on a photobrowser,
 such as after pick a serial photos from photo library, you can pick that photoes again using browser
 */
@protocol SGTPhotoBrowserPickerProtocol <NSObject>

@required

@property (nonatomic, copy, nullable) void(^finishHandle)(BOOL finish, NSArray<SGTPhotoSelectProtocol>* _Nonnull photos) ;

- (instancetype _Nonnull)initWithSelectedPhotos:(NSArray <SGTPhotoSelectProtocol>* _Nonnull)photos;

@optional

@end
@class SGTPhotoBrowserPicker;

@protocol SGTPhotoBrowserPickerDelegate <NSObject>
- (void)sgtPhotoBrowserPickStatuChaned:(SGTPhotoBrowserPicker *_Nonnull)controller atIndex:(NSInteger)index photo:(id<SGTPhotoSelectProtocol>_Nonnull)photo;
@end

