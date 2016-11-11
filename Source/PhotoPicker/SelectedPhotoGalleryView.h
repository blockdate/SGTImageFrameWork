//
//  SelectedPhotoGalleryView.h
//  Demo
//
//  Created by 吴磊 on 2016/11/10.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SGTPhotoSelectProtocol;
@class SelectedPhotoGalleryView;
@protocol SGTSelectedPhotoGalleryViewDelegate <NSObject>

- (void)sgtSelectedPhotoGalleryView:(SelectedPhotoGalleryView *_Nonnull)view statueChaned:(NSInteger)index photo:(id<SGTPhotoSelectProtocol>_Nonnull)photo;

@end

@interface SelectedPhotoGalleryView : UIView

@property (nonatomic, nullable, copy) void(^selectPhotoHandle)(UIImageView * _Nonnull tapedImageView, NSInteger index);
@property (nonatomic, nullable, weak) id<SGTSelectedPhotoGalleryViewDelegate> delegate;
- (void)addPhoto:(id<SGTPhotoSelectProtocol> _Nonnull)photo;

- (void)removePhoto:(id<SGTPhotoSelectProtocol> _Nonnull)photo;

@end
