//
//  SGTPhotoBrowser.h
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGTPhotoBrowserDelegate.h"
#import "SGTPhotoProtocol.h"


@interface SGTPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

// Properties
@property (nonatomic, nullable, weak) id<SGTPhotoBrowserDelegate> delegate;

// View customization
@property (nonatomic, nullable, strong) UIColor *backgroundColor;

/**
 not used
 */
@property (nonatomic) BOOL displayToolbar DEPRECATED_ATTRIBUTE;

/**
 enable auto select
 */
@property (nonatomic) BOOL enableSelected;

/**
 the titles that will display on actionsheet on long press
 */
@property (nonatomic, nonnull, strong) NSArray *actionButtonTitles;

/**
 loading animation Track color（backgroudcolor）
 */
@property (nonatomic, nullable, weak) UIColor *trackTintColor;

/**
 loading animation Tint color （tintcolor）
 */
@property (nonatomic, nullable, weak) UIColor *progressTintColor;
/**
 the source image used to animation present
 */
@property (nonatomic, nullable, weak) UIImage *scaleImage;

/**
 change photos using animated while not using finger dragging
 */
@property (nonatomic) BOOL changePhotosAnimated;

/**
 hide the status bar, default is not
 */
@property (nonatomic) BOOL forceHideStatusBar;

/**
 using pop animation to present
 */
@property (nonatomic) BOOL usePopAnimation;

/**
 disable vertical swipe to dismiss or pop photoBrowser
 */
@property (nonatomic) BOOL disableVerticalSwipe;

// Default value: true. Set to false to tell the photo viewer not to hide the interface when scrolling
@property (nonatomic) BOOL autoHideInterface;

// Defines zooming of the background (default 1.0)
@property (nonatomic) float backgroundScaleFactor;

// Animation time (default .28)
@property (nonatomic) float animationDuration;

// Init
- (instancetype _Nonnull)initWithPhotos:(NSArray <SGTPhotoProtocol>* _Nonnull)photosArray;

// Init (animated)
- (instancetype _Nonnull)initWithPhotos:(NSArray <SGTPhotoProtocol>* _Nonnull)photosArray animatedFromView:(UIView* _Nonnull)view;

// Init with NSURL objects
- (instancetype _Nonnull)initWithPhotoURLs:(NSArray <NSURL *>* _Nonnull)photoURLsArray;

// Init with NSURL objects (animated)
- (instancetype _Nonnull)initWithPhotoURLs:(NSArray <NSURL *>* _Nonnull)photoURLsArray animatedFromView:(UIView* _Nonnull)view;

// Reloads the photo browser and refetches data
- (void)reloadData;


/**
 Set page that photo browser starts on

 @param index the first show image on photo array
 */
- (void)setInitialPageIndex:(NSUInteger)index;


/**
 set the custom navigationbar and the done selector will provide by the handle block

 @param barView custom bar view
 @param handle  the done action pass handle
 */
- (void)setCustomTopNavigationBar:(UIView * _Nonnull)barView withDoneHandle:(void(^_Nullable)(_Nonnull SEL action)) handle;


/**
 get the photo at index

 @param index inde

 @return photo
 */
- (id<SGTPhotoProtocol> _Nullable)photoAtIndex:(NSUInteger)index;

@end
