//
//  SGTZoomingScrollView.h
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGTPhotoProtocol.h"
#import "SGTTapDetectingImageViewDelegate.h"
#import "SGTTapDetectingViewDelegate.h"

@class SGTPhotoBrowser, SGTCaptionView, SGTTapDetectingImageView, SGTTapDetectingView,DACircularProgressView;
@interface SGTZoomingScrollView : UIScrollView<UIScrollViewDelegate, SGTTapDetectingImageViewDelegate, SGTTapDetectingViewDelegate>

@property (nonatomic, strong) SGTTapDetectingView *tapView;
@property (nonatomic, strong) SGTTapDetectingImageView *photoImageView;
@property (nonatomic, strong) SGTCaptionView *captionView;
@property (nonatomic, strong) id<SGTPhotoProtocol> photo;
@property (nonatomic) CGFloat maximumDoubleTapZoomScale;
@property (nonatomic, strong) DACircularProgressView *progressView;

- (id)initWithPhotoBrowser:(SGTPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setProgress:(CGFloat)progress forPhoto:(id<SGTPhotoProtocol>)photo;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;

@end
