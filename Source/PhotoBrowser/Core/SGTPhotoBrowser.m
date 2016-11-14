//
//  SGTPhotoBrowser.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <pop/POP.h>
#import <Masonry.h>
#import "SGTPhoto.h"
#import "SGTPhotoBrowser.h"
#import "SGTPhotoMarco.h"
#import "SGTPhotoProtocol.h"
#import "SGTZoomingScrollView.h"
#import "SGTCaptionView.h"
#import <Photos/PHImageManager.h>

#define PAGE_INDEX_TAG_OFFSET   1000
#define PAGE_INDEX(page)        ([(page) tag] - PAGE_INDEX_TAG_OFFSET)

#ifndef SGTPhotoBrowserLocalizedStrings
#define SGTPhotoBrowserLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle((key), nil, [NSBundle bundleWithPath:[[NSBundle bundleForClass: [SGTPhotoBrowser class]] pathForResource:@"IDMPBLocalizations" ofType:@"bundle"]], nil)
#endif

@interface SGTPhotoBrowser(){
    // Control
    NSTimer *_controlVisibilityTimer;
    
    // Appearance
    //UIStatusBarStyle _previousStatusBarStyle;
    BOOL _statusBarOriginallyHidden;
    
    // Present
    UIView *_senderViewForAnimation;
    
    // Misc
    BOOL _performingLayout;
    BOOL _rotating;
    BOOL _viewIsActive; // active as in it's in the view heirarchy
    BOOL _autoHide;
    NSInteger _initalPageIndex;
    
    BOOL _isdraggingPhoto;
    
    CGRect _senderViewOriginalFrame;
    //UIImage *_backgroundScreenshot;
    
    UIWindow *_applicationWindow;
    
    // iOS 7
    UIViewController *_applicationTopViewController;
    int _previousModalPresentationStyle;
    
    BOOL _originalNavgationBarHidden;
}
//Navigation
@property(nonatomic, nonnull, strong) UIView *customBar;
@property(nonatomic, nullable, strong) UIVisualEffectView *customEffectView;
@property(nonatomic, nullable, strong) UIButton *doneButton;
@property(nonatomic, nullable, strong) UILabel *currentIndexLabel;
//Datas
@property(nonatomic, nonnull, strong) NSMutableArray<SGTPhotoProtocol> *photos;
@property(nonatomic, nonnull, strong) UIScrollView *pagingScrollView;
@property(nonatomic, nonnull, strong) UIPanGestureRecognizer *panGesture;
@property(nonatomic, nonnull, strong) NSMutableSet *visiblePages, *recycledPages;
@property(nonatomic) NSUInteger pageIndexBeforeRotation;
@property(nonatomic) NSUInteger currentPageIndex;

// Actions
@property(nonatomic, nullable, strong) UIActionSheet *actionsSheet;
@property(nonatomic, nullable, strong) UIActivityViewController *activityViewController;

@end

@implementation SGTPhotoBrowser

#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        // Defaults
        self.hidesBottomBarWhenPushed = YES;
        _currentPageIndex = 0;
        _performingLayout = NO; // Reset on view did appear
        _rotating = NO;
        _viewIsActive = NO;
        _visiblePages = [NSMutableSet new];
        _recycledPages = [NSMutableSet new];
        _photos = [NSMutableArray<SGTPhotoProtocol> new];
        
        _initalPageIndex = 0;
        _autoHide = YES;
        _autoHideInterface = YES;
        
        _displayToolbar = NO;
        
        _forceHideStatusBar = NO;
        _usePopAnimation = NO;
        _disableVerticalSwipe = NO;
        
        _changePhotosAnimated = YES;
        
        _backgroundScaleFactor = 1.0;
        _animationDuration = 0.28;
        _senderViewForAnimation = nil;
        _scaleImage = nil;
        
        _isdraggingPhoto = NO;
        
        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
            self.automaticallyAdjustsScrollViewInsets = NO;
        
        _applicationWindow = [[[UIApplication sharedApplication] delegate] window];
#ifdef __IPHONE_8_0
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationCapturesStatusBarAppearance = YES;
#else
        _previousModalPresentationStyle = _applicationTopViewController.modalPresentationStyle;
        _applicationTopViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
#endif
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        // Listen for SGTPhoto notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSGTPhotoLoadingDidEndNotification:)
                                                     name:[SGT_Photo_loading_Finish_Notification copy]
                                                   object:nil];
    }
    
    return self;
}
- (id)initWithPhotos:(NSArray *)photosArray {
    if ((self = [self init])) {
        _photos = [[NSMutableArray<SGTPhotoProtocol> alloc] initWithArray:photosArray];
    }
    return self;
}
- (id)initWithPhotos:(NSArray *)photosArray animatedFromView:(UIView*)view {
    if ((self = [self init])) {
        _photos = [[NSMutableArray<SGTPhotoProtocol> alloc] initWithArray:photosArray];
        _senderViewForAnimation = view;
    }
    return self;
}
- (id)initWithPhotoURLs:(NSArray *)photoURLsArray {
    if ((self = [self init])) {
        NSArray *photosArray = [SGTPhoto photosWithURLs:photoURLsArray];
        _photos = [[NSMutableArray<SGTPhotoProtocol> alloc] initWithArray:photosArray];
    }
    return self;
}
- (id)initWithPhotoURLs:(NSArray *)photoURLsArray animatedFromView:(UIView*)view {
    if ((self = [self init])) {
        NSArray *photosArray = [SGTPhoto photosWithURLs:photoURLsArray];
        _photos = [[NSMutableArray<SGTPhotoProtocol> alloc] initWithArray:photosArray];
        _senderViewForAnimation = view;
    }
    return self;
}
- (void)dealloc {
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseAllUnderlyingPhotos];
}
- (void)releaseAllUnderlyingPhotos {
    for (id p in _photos) { if (p != [NSNull null]) [p unloadUnderlyingImage]; } // Release photos
}
- (void)didReceiveMemoryWarning {
    // Release any cached data, images, etc that aren't in use.
    [self releaseAllUnderlyingPhotos];
    [_recycledPages removeAllObjects];
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - Pan Gesture

- (void)panGestureRecognized:(id)sender {
    // Initial Setup
    SGTZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
    
    
    static float firstX, firstY;
    
    float viewHeight = scrollView.frame.size.height;
    float viewHalfHeight = viewHeight/2;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    // Gesture Began
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        [self setControlsHidden:YES animated:YES permanent:YES];
        
        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
        
        _senderViewForAnimation.hidden = (_currentPageIndex == _initalPageIndex);
        
        _isdraggingPhoto = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    translatedPoint = CGPointMake(firstX, firstY+translatedPoint.y);
    [scrollView setCenter:translatedPoint];
    
//    float newY = scrollView.center.y - viewHalfHeight;
//    float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
    
    self.view.opaque = YES;
    
    self.view.backgroundColor = self.backgroundColor ?self.backgroundColor:[UIColor blackColor];
    
    // Gesture Ended
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if(scrollView.center.y > viewHalfHeight+100 || scrollView.center.y < viewHalfHeight-100) // Automatic Dismiss View
        {
            if (_senderViewForAnimation && _currentPageIndex == _initalPageIndex) {
                [self performCloseAnimationWithScrollView:scrollView];
                return;
            }
            
            CGFloat finalX = firstX, finalY;
            
            CGFloat windowsHeigt = [_applicationWindow frame].size.height;
            
            if(scrollView.center.y > viewHalfHeight+30) // swipe down
                finalY = windowsHeigt*2;
            else // swipe up
                finalY = -viewHalfHeight;
            
            CGFloat animationDuration = 0.35;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            [UIView commitAnimations];
            
            [self performSelector:@selector(doneButtonPressed:) withObject:self afterDelay:animationDuration];
        }
        else // Continue Showing View
        {
            _isdraggingPhoto = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            
            self.view.backgroundColor = self.backgroundColor ?self.backgroundColor:[UIColor blackColor];
            
            CGFloat velocityY = (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
            
            CGFloat finalX = firstX;
            CGFloat finalY = viewHalfHeight;
            
            CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            [UIView commitAnimations];
        }
    }
}

#pragma mark - Animation

- (void)performPresentAnimation {
    self.view.alpha = 0.0f;
    _pagingScrollView.alpha = 0.0f;
    
    UIImage *imageFromView = _scaleImage ? _scaleImage : [self getImageFromView:_senderViewForAnimation];
    
    _senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
    
    UIView *fadeView = [[UIView alloc] initWithFrame:_applicationWindow.bounds];
    fadeView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:fadeView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = _senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:resizableImageView];
    _senderViewForAnimation.hidden = YES;
    
    void (^completion)() = ^() {
        self.view.alpha = 1.0f;
        _pagingScrollView.alpha = 1.0f;
        resizableImageView.backgroundColor = self.backgroundColor ? self.backgroundColor:[UIColor blackColor];
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
    };
    
    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.backgroundColor = self.backgroundColor ? self.backgroundColor:[UIColor blackColor];
    } completion:nil];
    
    CGRect finalImageViewFrame = [self animationFrameForImage:imageFromView presenting:YES scrollView:nil];
    
    if(_usePopAnimation)
    {
        [self animateView:resizableImageView
                  toFrame:finalImageViewFrame
               completion:completion];
    }
    else
    {
        [UIView animateWithDuration:_animationDuration animations:^{
            resizableImageView.layer.frame = finalImageViewFrame;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}
- (void)performCloseAnimationWithScrollView:(SGTZoomingScrollView*)scrollView {
    
    if ([_delegate respondsToSelector:@selector(willDisappearPhotoBrowser:)]) {
        [_delegate willDisappearPhotoBrowser:self];
    }
    
    float fadeAlpha = 1 - fabs(scrollView.frame.origin.y)/scrollView.frame.size.height;
    
    UIImage *imageFromView = [scrollView.photo underlyingImage];
    if (!imageFromView && [scrollView.photo respondsToSelector:@selector(placeholderImage)]) {
        imageFromView = [scrollView.photo placeholderImage];
    }
    
    UIView *fadeView = [[UIView alloc] initWithFrame:_applicationWindow.bounds];
    fadeView.backgroundColor = self.backgroundColor ? self.backgroundColor:[UIColor blackColor];
    fadeView.alpha = fadeAlpha;
    [_applicationWindow addSubview:fadeView];
    
    CGRect imageViewFrame = [self animationFrameForImage:imageFromView presenting:NO scrollView:scrollView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = imageViewFrame;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    resizableImageView.clipsToBounds = YES;
    [_applicationWindow addSubview:resizableImageView];
    self.view.hidden = YES;
    
    void (^completion)() = ^() {
        _senderViewForAnimation.hidden = NO;
        _senderViewForAnimation = nil;
        _scaleImage = nil;
        
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
        [self prepareForClosePhotoBrowser];
        [self dismissPhotoBrowserAnimated:NO];
    };
    
    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.alpha = 0;
        self.view.backgroundColor = [UIColor clearColor];
    } completion:nil];
    
    CGRect senderViewOriginalFrame = _senderViewForAnimation.superview ? [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil] : _senderViewOriginalFrame;
    
    if(_usePopAnimation)
    {
        [self animateView:resizableImageView
                  toFrame:senderViewOriginalFrame
               completion:completion];
    }
    else
    {
        [UIView animateWithDuration:_animationDuration animations:^{
            resizableImageView.layer.frame = senderViewOriginalFrame;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}
- (CGRect)animationFrameForImage:(UIImage *)image presenting:(BOOL)presenting scrollView:(UIScrollView *)scrollView{
    if (!image) {
        return CGRectZero;
    }
    
    CGSize imageSize = image.size;
    
    CGFloat maxWidth = CGRectGetWidth(_applicationWindow.bounds);
    CGFloat maxHeight = CGRectGetHeight(_applicationWindow.bounds);
    
//    if the _senderViewForAnimation is an ImageView, the image cut from it may has some lost with width or height,so scale it within the screen width and screen height may scale the image larger than the image will show after the present animation finished. 
    CGFloat targetMaxWidth = maxWidth;
    CGFloat targetMaxHeight = maxHeight;
    if (_senderViewForAnimation != nil && [_senderViewForAnimation isKindOfClass:[UIImageView class]]) {
        UIImage * originImage = ((UIImageView *)_senderViewForAnimation).image;
        if (originImage != nil) {
            CGSize originImageSize = originImage.size;
            CGFloat scale = MIN(maxWidth/originImageSize.width,maxHeight/originImageSize.height);
            targetMaxWidth = originImageSize.width * scale;
            targetMaxHeight = originImageSize.height * scale;
        }
    }
    
    CGRect animationFrame = CGRectZero;
    
    CGFloat aspect = imageSize.width / imageSize.height;
    if (targetMaxWidth / aspect <= targetMaxHeight) {
        animationFrame.size = CGSizeMake(targetMaxWidth, targetMaxWidth / aspect);
    }
    else {
        animationFrame.size = CGSizeMake(targetMaxHeight * aspect, targetMaxHeight);
    }
    
    animationFrame.origin.x = roundf((maxWidth - animationFrame.size.width) / 2.0f);
    animationFrame.origin.y = roundf((maxHeight - animationFrame.size.height) / 2.0f);
    
    if (!presenting) {
        animationFrame.origin.y += scrollView.frame.origin.y;
    }
    
    return animationFrame;
}

#pragma mark - Genaral

- (void)prepareForClosePhotoBrowser {
    // Gesture
    [_applicationWindow removeGestureRecognizer:_panGesture];
    
    _autoHide = NO;
    
    // Controls
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
}
- (void)dismissPhotoBrowserAnimated:(BOOL)animated {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if ([_delegate respondsToSelector:@selector(photoBrowser:willDismissAtPageIndex:)])
        [_delegate photoBrowser:self willDismissAtPageIndex:_currentPageIndex];
    
    [self dismissViewControllerAnimated:animated completion:^{
        if ([_delegate respondsToSelector:@selector(photoBrowser:didDismissAtPageIndex:)])
            [_delegate photoBrowser:self didDismissAtPageIndex:_currentPageIndex];
        
#ifdef __IPHONE_8_0
        _applicationTopViewController.modalPresentationStyle = _previousModalPresentationStyle;
#endif
    }];
}
- (UIButton*)customToolbarButtonImage:(UIImage*)image imageSelected:(UIImage*)selectedImage action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateDisabled];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setContentMode:UIViewContentModeCenter];
    [button setFrame:[self getToolbarButtonFrame:image]];
    return button;
}
- (CGRect)getToolbarButtonFrame:(UIImage *)image{
    BOOL const isRetinaHd = ((float)[[UIScreen mainScreen] scale] > 2.0f);
    float const defaultButtonSize = isRetinaHd ? 66.0f : 44.0f;
    CGFloat buttonWidth = (image.size.width > defaultButtonSize) ? image.size.width : defaultButtonSize;
    CGFloat buttonHeight = (image.size.height > defaultButtonSize) ? image.size.width : defaultButtonSize;
    return CGRectMake(0,0, buttonWidth, buttonHeight);
}
- (UIImage*)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIViewController *)topviewController{
    UIViewController *topviewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topviewController.presentedViewController) {
        topviewController = topviewController.presentedViewController;
    }
    
    return topviewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    self.view.backgroundColor = self.backgroundColor ? self.backgroundColor:[UIColor blackColor];
    self.view.clipsToBounds = YES;
    
    
    // Setup paging scrolling view
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor clearColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self.view addSubview:_pagingScrollView];
    
    
    [self.view addSubview:self.customBar];
    
    // Transition animation
    [self performPresentAnimation];
    
    // Gesture
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [_panGesture setMinimumNumberOfTouches:1];
    [_panGesture setMaximumNumberOfTouches:1];
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    // Update
    [self reloadData];
    
    
    if ([_delegate respondsToSelector:@selector(willAppearPhotoBrowser:)]) {
        [_delegate willAppearPhotoBrowser:self];
    }
    
    // Super
    [super viewWillAppear:animated];
    
    // Status Bar
    _statusBarOriginallyHidden = [UIApplication sharedApplication].statusBarHidden;
    
    if ([self isControllerPushed]) {
        _originalNavgationBarHidden = self.navigationController.navigationBar.hidden;
        [self.navigationController.navigationBar setHidden:true];
    }
    // Update UI
//    [self hideControlsAfterDelay];
}
-(void)viewWillDisappear:(BOOL)animated {
    if ([self isControllerPushed]) {
        [self.navigationController.navigationBar setHidden:_originalNavgationBarHidden];
    }
    [super viewWillDisappear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
}
// Release any retained subviews of the main view.
- (void)viewDidUnload {
    _currentPageIndex = 0;
    _pagingScrollView = nil;
    _visiblePages = nil;
    _recycledPages = nil;
    [super viewDidUnload];
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    if(_forceHideStatusBar) {
        return YES;
    }else {
        return NO;
    }
//    do not hide status bar
//    if(_isdraggingPhoto) {
//        if(_statusBarOriginallyHidden) {
//            return YES;
//        }
//        else {
//            return NO;
//        }
//    }
//    else {
//        return [self isControlsHidden];
//    }
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    // Flag
    _performingLayout = YES;
    
//    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // Remember index
    NSUInteger indexPriorToLayout = _currentPageIndex;
    
    // Get paging scroll view frame to determine if anything needs changing
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
    // Frame needs changing
    _pagingScrollView.frame = pagingScrollViewFrame;
    
    // Recalculate contentSize based on current orientation
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // Adjust frames and configuration of each visible page
    for (SGTZoomingScrollView *page in _visiblePages) {
        NSUInteger index = PAGE_INDEX(page);
        page.frame = [self frameForPageAtIndex:index];
        page.captionView.frame = [self frameForCaptionView:page.captionView atIndex:index];
        [page setMaxMinZoomScalesForCurrentBounds];
    }
    
    // Adjust contentOffset to preserve page location based on values collected prior to location
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];

    [self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    
    // Reset
    _currentPageIndex = indexPriorToLayout;
    _performingLayout = NO;
    
//    self.customBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 64);
//    self.customEffectView.frame = self.customBar.frame;
    // Super
    [super viewWillLayoutSubviews];
}
- (void)performLayout {
    // Setup
    _performingLayout = YES;
//    NSUInteger numberOfPhotos = [self numberOfPhotos];
    
    // Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    [self updateToolbar];
    // Content offset
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];

    [self tilePages];
    _performingLayout = NO;
    
    if(! _disableVerticalSwipe)
        [self.view addGestureRecognizer:_panGesture];
}


#pragma mark - Datas

- (void)reloadData {
    // Get data
    [self releaseAllUnderlyingPhotos];
    
    // Update
    [self performLayout];
    
    // Layout
    [self.view setNeedsLayout];
}
- (NSUInteger)numberOfPhotos {
    return _photos.count;
}
- (id<SGTPhotoProtocol>)photoAtIndex:(NSUInteger)index {
    return _photos[index];
}
- (SGTCaptionView *)captionViewForPhotoAtIndex:(NSUInteger)index {
    SGTCaptionView *captionView = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:captionViewForPhotoAtIndex:)]) {
        captionView = [_delegate photoBrowser:self captionViewForPhotoAtIndex:index];
    } else {
        id <SGTPhotoProtocol> photo = [self photoAtIndex:index];
        if ([photo respondsToSelector:@selector(caption)]) {
            if ([photo caption]) captionView = [[SGTCaptionView alloc] initWithPhoto:photo];
        }
    }
    captionView.alpha = [self isControlsHidden] ? 0 : 1; // Initial alpha
    
    return captionView;
}
- (UIImage *)imageForPhoto:(id<SGTPhotoProtocol>)photo {
    if (photo) {
        CGSize preferSize = PHImageManagerMaximumSize;//SGTCGSizeScale(self.view.bounds.size, [[UIScreen mainScreen] scale]);
        if (photo.preferSize.width != preferSize.width || photo.preferSize.height != preferSize.height ) {
            [photo unloadUnderlyingImage];
            photo.preferSize = preferSize;
        }
        // Get image or obtain in background
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
            [photo loadUnderlyingImageAndNotify];
            if ([photo respondsToSelector:@selector(placeholderImage)]) {
                return [photo placeholderImage];
            }
        }
    }
    
    return nil;
}
- (void)loadAdjacentPhotosIfNecessary:(id<SGTPhotoProtocol>)photo {
    SGTZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = PAGE_INDEX(page);
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                // Preload index - 1
                id <SGTPhotoProtocol> photo = [self photoAtIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
//                    NSLog(@"Pre-loading image at index %lu", pageIndex-1);
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                // Preload index + 1
                id <SGTPhotoProtocol> photo = [self photoAtIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
//                    NSLog(@"Pre-loading image at index %lu", pageIndex+1);
                }
            }
        }
    }
}



#pragma mark - Photo Loading Notification

- (void)handleSGTPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <SGTPhotoProtocol> photo = [notification object];
    SGTZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        if ([photo underlyingImage]) {
            // Successful load
            [page displayImage];
            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            // Failed to load
            [page displayImageFailure];
        }
    }
}

#pragma mark - Paging

- (void)tilePages {
    // Calculate which pages should be visible
    // Ignore padding as paging bounces encroach on that
    // and lead to false page loads
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger) floorf((CGRectGetMinX(visibleBounds)+sgt_padding*2) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex  = (NSInteger) floorf((CGRectGetMaxX(visibleBounds)-sgt_padding*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
    
    // Recycle no longer needed pages
    NSInteger pageIndex;
    for (SGTZoomingScrollView *page in _visiblePages) {
        pageIndex = PAGE_INDEX(page);
        if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
            [_recycledPages addObject:page];
            [page prepareForReuse];
            [page removeFromSuperview];
//            NSLog(@"Removed page at index %li", PAGE_INDEX(page));
        }
    }
    [_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
    
    // Add missing pages
    for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            // Add new page
            SGTZoomingScrollView *page;
            page = [[SGTZoomingScrollView alloc] initWithPhotoBrowser:self];
            page.backgroundColor = [UIColor clearColor];
            page.opaque = YES;
            
            [self configurePage:page forIndex:index];
            [_visiblePages addObject:page];
            [_pagingScrollView addSubview:page];
//            NSLog(@"Added page at index %lu", (unsigned long)index);
            
            // Add caption
            SGTCaptionView *captionView = [self captionViewForPhotoAtIndex:index];
            captionView.frame = [self frameForCaptionView:captionView atIndex:index];
            [_pagingScrollView addSubview:captionView];
            page.captionView = captionView;
        }
    }
}
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (SGTZoomingScrollView *page in _visiblePages)
        if (PAGE_INDEX(page) == index) return YES;
    return NO;
}
- (SGTZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
    SGTZoomingScrollView *thePage = nil;
    for (SGTZoomingScrollView *page in _visiblePages) {
        if (PAGE_INDEX(page) == index) {
            thePage = page; break;
        }
    }
    return thePage;
}
- (SGTZoomingScrollView *)pageDisplayingPhoto:(id<SGTPhotoProtocol>)photo {
    SGTZoomingScrollView *thePage = nil;
    for (SGTZoomingScrollView *page in _visiblePages) {
        if (page.photo == photo) {
            thePage = page; break;
        }
    }
    return thePage;
}
- (void)configurePage:(SGTZoomingScrollView *)page forIndex:(NSUInteger)index {
    page.frame = [self frameForPageAtIndex:index];
    page.tag = PAGE_INDEX_TAG_OFFSET + index;
    page.photo = [self photoAtIndex:index];
    
    __block __weak SGTPhoto *photo = (SGTPhoto*)page.photo;
    __weak SGTZoomingScrollView* weakPage = page;
    photo.progressUpdateBlock = ^(CGFloat progress){
        [weakPage setProgress:progress forPhoto:photo];
    };
}
- (SGTZoomingScrollView *)dequeueRecycledPage {
    SGTZoomingScrollView *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}
// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    id <SGTPhotoProtocol> currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        // photo loaded so load ajacent now
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    if ([_delegate respondsToSelector:@selector(photoBrowser:didShowPhotoAtIndex:)]) {
        [_delegate photoBrowser:self didShowPhotoAtIndex:index];
    }
}

#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;
    frame.origin.x -= sgt_padding;
    frame.size.width += (2 * sgt_padding);
    return frame;
}
- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * sgt_padding);
    pageFrame.origin.x = (bounds.size.width * index) + sgt_padding;
    return pageFrame;
}
- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}
- (BOOL)isLandscape:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    
    if ([self isLandscape:orientation])
        height = 32;
    
    return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}
- (CGRect)frameForDoneButtonAtOrientation:(UIInterfaceOrientation)orientation {
    CGRect screenBound = [UIScreen mainScreen].bounds;
    CGFloat screenWidth = screenBound.size.width;
    CGFloat y = 10;
    if ([self isLandscape:orientation]) {
        screenWidth = screenBound.size.height;
        y = 10;
    }else {
        y = 30;
    };
    
    return CGRectMake(screenWidth - 60, y, 55, 26);
}
- (CGRect)frameForCaptionView:(SGTCaptionView *)captionView atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    
    CGSize captionSize = [captionView sizeThatFits:CGSizeMake(pageFrame.size.width, 0)];
    CGRect captionFrame = CGRectMake(pageFrame.origin.x, pageFrame.size.height - captionSize.height, pageFrame.size.width, captionSize.height);
    
    return captionFrame;
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
    // Checks
    if (!_viewIsActive || _performingLayout || _rotating) return;
    
    // Tile pages
    [self tilePages];
    
    // Calculate current page
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger index = (NSInteger) (floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
    NSUInteger previousCurrentPage = _currentPageIndex;
    _currentPageIndex = index;
    if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
        
        if(_changePhotosAnimated) [self updateToolbar];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Do not hide controls when dragging begins,you can open it if you like
//    if(_autoHideInterface){
//        [self setControlsHidden:YES animated:YES permanent:NO];
//    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Update toolbar when page changes
    if(! _changePhotosAnimated) [self updateToolbar];
}

#pragma mark - Toolbar

- (void)setCustomTopNavigationBar:(UIView *)barView withDoneHandle:(void (^)(SEL _Nonnull))handle {
    if (handle) {
        handle(@selector(doneButtonPressed:));
    }
}

- (void)updateToolbar {
    if ([self numberOfPhotos] > 1) {
        _currentIndexLabel.text = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(_currentPageIndex+1), @"/", (unsigned long)[self numberOfPhotos]];
    } else {
        _currentIndexLabel.text = nil;
    }
    
}
- (void)jumpToPageAtIndex:(NSUInteger)index {
    // Change page
    if (index < [self numberOfPhotos]) {
        CGRect pageFrame = [self frameForPageAtIndex:index];
        
        if(_changePhotosAnimated)
        {
            [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - sgt_padding, 0) animated:YES];
        }
        else
        {
            _pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x - sgt_padding, 0);
            [self updateToolbar];
        }
    }
    _currentPageIndex = index;
    // Update timer to give more time
    [self hideControlsAfterDelay];
}
- (void)gotoPreviousPage { [self jumpToPageAtIndex:_currentPageIndex-1]; }
- (void)gotoNextPage     { [self jumpToPageAtIndex:_currentPageIndex+1]; }

#pragma mark - Control Hiding / Showing

// If permanent then we don't set timers to hide again
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent {
    // Cancel any timers
    [self cancelControlHiding];
    
    // Captions
    NSMutableSet *captionViews = [[NSMutableSet alloc] initWithCapacity:_visiblePages.count];
    for (SGTZoomingScrollView *page in _visiblePages) {
        if (page.captionView) [captionViews addObject:page.captionView];
    }
    
    // Hide/show bars
    [UIView animateWithDuration:(animated ? 0.1 : 0) animations:^(void) {
        CGFloat alpha = hidden ? 0 : 1;
//        [self.navigationController.navigationBar setHidden:hidden];
        self.customBar.alpha = alpha;
//        [_toolbar setAlpha:alpha];
        
//        [_doneButton setAlpha:alpha];
        for (UIView *v in captionViews) v.alpha = alpha;
    } completion:^(BOOL finished) {
        self.customBar.hidden = hidden;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
    
    // Control hiding timer
    // Will cancel existing timer but only begin hiding if they are visible
    if (!permanent) [self hideControlsAfterDelay];
    
    
}
- (void)cancelControlHiding {
    // If a timer exists then cancel and release
    if (_controlVisibilityTimer) {
        [_controlVisibilityTimer invalidate];
        _controlVisibilityTimer = nil;
    }
}
- (void)hideControlsAfterDelay {
    
    if (![self autoHideInterface]) {
        return;
    }
    
    if (![self isControlsHidden]) {
        [self cancelControlHiding];
        _controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
    }
}
- (BOOL)isControlsHidden {
    return (self.customBar.hidden);
}
- (BOOL)isControllerPushed {
    return self.navigationController != nil;
}
- (void)hideControls {
    if(_autoHide && _autoHideInterface) [self setControlsHidden:YES animated:YES permanent:NO];
}
- (void)toggleControls {
    [self setControlsHidden:![self isControlsHidden] animated:YES permanent:NO];
}

#pragma mark - Properties

- (void)setInitialPageIndex:(NSUInteger)index {
    // Validate
    if (index >= [self numberOfPhotos]) index = [self numberOfPhotos]-1;
    _initalPageIndex = index;
    _currentPageIndex = index;
    if ([self isViewLoaded]) {
        [self jumpToPageAtIndex:index];
        if (!_viewIsActive) [self tilePages]; // Force tiling if view is not visible
    }
}

#pragma mark - Buttons

- (void)doneButtonPressed:(id)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(willDisappearPhotoBrowser:)]) {
        [_delegate willDisappearPhotoBrowser:self];
    }
    if ([self isControllerPushed]) {
        if (_isdraggingPhoto) {
            [self.navigationController popViewControllerAnimated:false];
        }else {
            [self.navigationController popViewControllerAnimated:true];
        }
    }else {
        if (_senderViewForAnimation && _currentPageIndex == _initalPageIndex) {
            SGTZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
            [self performCloseAnimationWithScrollView:scrollView];
        }
        else {
            _senderViewForAnimation.hidden = NO;
            [self prepareForClosePhotoBrowser];
            [self dismissPhotoBrowserAnimated:YES];
        }
    }
}
- (void)actionButtonPressed:(id)sender {
    id <SGTPhotoProtocol> photo = [self photoAtIndex:_currentPageIndex];
    
    if ([self numberOfPhotos] > 0 && [photo underlyingImage]) {
        if(!_actionButtonTitles)
        {
            // Activity view
            NSMutableArray *activityItems = [NSMutableArray arrayWithObject:[photo underlyingImage]];
            if (photo.caption) [activityItems addObject:photo.caption];
            
            self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            
            __typeof__(self) __weak selfBlock = self;
#ifdef  __IPHONE_8_0
            [self.activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                [selfBlock hideControlsAfterDelay];
                selfBlock.activityViewController = nil;
            }];
#else
            [self.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
                [selfBlock hideControlsAfterDelay];
                selfBlock.activityViewController = nil;
            }];
#endif
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [self presentViewController:self.activityViewController animated:YES completion:nil];
            }
            else { // iPad
                UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:self.activityViewController];
                [popover presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)
                                         inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny
                                       animated:YES];
            }
        }
        else
        {
            // Action sheet
            self.actionsSheet = [UIActionSheet new];
            self.actionsSheet.delegate = self;
            for(NSString *action in _actionButtonTitles) {
                [self.actionsSheet addButtonWithTitle:action];
            }
            
            self.actionsSheet.cancelButtonIndex = [self.actionsSheet addButtonWithTitle:@"取消"];
            self.actionsSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [_actionsSheet showInView:self.view];
            } else {
                [_actionsSheet showFromBarButtonItem:sender animated:YES];
            }
        }
        
        // Keep controls hidden
        [self setControlsHidden:NO animated:YES permanent:YES];
    }
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == _actionsSheet) {
        self.actionsSheet = nil;
        
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:didDismissActionSheetWithButtonIndex:photoIndex:)]) {
                [_delegate photoBrowser:self didDismissActionSheetWithButtonIndex:buttonIndex photoIndex:_currentPageIndex];
                return;
            }
        }
    }
    
    [self hideControlsAfterDelay]; // Continue as normal...
}

#pragma mark - pop Animation

- (void)animateView:(UIView *)view toFrame:(CGRect)frame completion:(void (^)(void))completion {
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    [animation setSpringBounciness:6];
    [animation setDynamicsMass:1];
    [animation setToValue:[NSValue valueWithCGRect:frame]];
    [view pop_addAnimation:animation forKey:nil];
    
    if (completion)
    {
        [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
            completion();
        }];
    }
}

#pragma mark - getter

- (UIView *)customBar {
    if (_customBar == nil) {
        //        _customBar was not provited
        _customBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 64)];
        _customBar.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        _customEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _customEffectView.frame = _customBar.frame;
        [_customBar addSubview:_customEffectView];
        //
        _doneButton = [self doneButton];
        [_customBar addSubview:_doneButton];
        
        [_customBar addSubview:self.currentIndexLabel];
        self.currentIndexLabel.center = CGPointMake(_customBar.center.x, 44);
    }
    return _customBar;
}

- (UIButton *)doneButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setFrame:[self frameForDoneButtonAtOrientation:[UIApplication sharedApplication].statusBarOrientation]];
    return button;
}
- (UILabel *)currentIndexLabel {
    if (_currentIndexLabel == nil) {
        _currentIndexLabel = [[UILabel alloc] init];
        _currentIndexLabel.frame = CGRectMake(0, 0, 200, 40);
        _currentIndexLabel.textColor = [UIColor whiteColor];
        _currentIndexLabel.font = [UIFont systemFontOfSize:15];
        _currentIndexLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentIndexLabel;
}

@end
