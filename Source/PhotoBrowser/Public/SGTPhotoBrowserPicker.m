//
//  SGTPhotoBrowserPicker.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/7.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTPhotoBrowserPicker.h"
#import "SGTZoomingScrollView.h"
#import "UIImage+Extend.h"
#import "NSBundle+SGTCurrent.h"
#import "SGTSendButton.h"
#import "SGTFullImageButton.h"

@interface SGTPhotoBrowser()

@property(nonatomic, nonnull, strong) NSMutableArray<SGTPhotoProtocol> *photos;
@property(nonatomic, nonnull, strong) UIView *customBar;
@property(nonatomic, nullable, strong) UIVisualEffectView *customEffectView;
@property(nonatomic, nullable, strong) UILabel *currentIndexLabel;
@property(nonatomic, nonnull, strong) NSMutableSet *visiblePages;
@property(nonatomic) NSUInteger currentPageIndex;

- (CGRect)frameForDoneButtonAtOrientation:(UIInterfaceOrientation)orientation;
- (void)doneButtonPressed:(id)sender;
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)updateToolbar;
- (NSUInteger)numberOfPhotos;
- (BOOL)isControllerPushed;

@end

@interface SGTPhotoBrowserPicker ()

@property (nonatomic, nonnull, strong) UIView *customBottomBar;
@property (nonatomic, nonnull, strong) UIButton *checkButton;
@property (nonatomic, nonnull, strong) UIButton *cancleButton;
@property (nonatomic, strong) SGTFullImageButton *fullImageButton;
@property (nonatomic, nonnull, strong) UILabel *currentSelectCountLabel;
@property (nonatomic, nonnull, strong) NSMutableArray <SGTPhotoSelectProtocol>* allPhotos;
@property (nonatomic, nonnull, strong) NSMutableArray <SGTPhotoSelectProtocol>* selectPhotos;
@property (nonnull, nonatomic, strong) SGTSendButton *sendButton;
@end

@implementation SGTPhotoBrowserPicker
@synthesize customBar = _customBar,customEffectView=_customEffectView,currentIndexLabel=_currentIndexLabel,visiblePages=_visiblePages;

#pragma mark - Object
- (void)dealloc {
    
}
- (instancetype)initWithSelectedPhotos:(NSArray<SGTPhotoSelectProtocol> *)photos {
    self = [super initWithPhotos:photos];
    if (self) {
        _allPhotos = [NSMutableArray<SGTPhotoSelectProtocol> arrayWithArray:photos];
        _selectPhotos = [NSMutableArray<SGTPhotoSelectProtocol> array];
        self.disableVerticalSwipe = true;
    }
    return self;
}
- (instancetype)initWithSelectedPhotos:(NSArray<SGTPhotoSelectProtocol> *)photos animatedFromView:(UIView* _Nonnull)view{
    self = [super initWithPhotos:photos animatedFromView:view];
    if (self) {
        _allPhotos = [NSMutableArray<SGTPhotoSelectProtocol> arrayWithArray:photos];
        _selectPhotos = [NSMutableArray<SGTPhotoSelectProtocol> array];
        self.disableVerticalSwipe = true;
    }
    return self;
}

#pragma mark - view lifrCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.customBottomBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.hideBottomBar) {
        self.customBottomBar.hidden = true;
        [self.cancleButton setTitle:@"确定" forState:UIControlStateNormal];
    }
}

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
        self.customBottomBar.alpha = alpha;
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

#pragma mark - ToolBar

- (void)updateToolbar {
    if ([self numberOfPhotos] > 1) {
        _currentIndexLabel.text = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(self.currentPageIndex+1), @"/", (unsigned long)[self numberOfPhotos]];
    } else {
        _currentIndexLabel.text = nil;
    }
    id<SGTPhotoSelectProtocol> photo = self.photos[self.currentPageIndex];
    self.checkButton.selected = photo.isSelect;
    if (photo.isSelect) {
        
    }
}

#pragma mark - picker action

- (void)checkButtonAction
{
    id<SGTPhotoSelectProtocol> photo = self.photos[self.currentPageIndex];
    photo.isSelect = !photo.isSelect;
    self.checkButton.selected = photo.isSelect;
    if (photo.isSelect) {
        [self.selectPhotos addObject:photo];
    }else {
        [self.selectPhotos removeObject:photo];
    }
    if ([self.photoPickdelegate respondsToSelector:@selector(sgtPhotoBrowserPickStatuChaned:atIndex:photo:)]) {
        [self.photoPickdelegate sgtPhotoBrowserPickStatuChaned:self atIndex:self.currentPageIndex photo:photo];
    }
    
    [self updateSelestedNumber];
}

- (void)updateSelestedNumber {
    NSInteger selectedNumber = 0;
    selectedNumber = self.selectPhotos.count;
    NSString * s = [NSString stringWithFormat:@"%ld",selectedNumber];
    NSLog(@"click");
    self.sendButton.badgeValue = s;
}

- (void)sendButtonAction:(id)sender {
    if (nil != _finishHandle) {
        _finishHandle(YES,[[self selectPhotos] copy]);
    }
    [self doneButtonPressed:sender];
}

- (void)fullImageButtonAction
{
    self.fullImageButton.selected = !self.fullImageButton.selected;
//    self.fullImage = self.fullImageButton.selected;
//    if ([self.delegate respondsToSelector:@selector(photoBrowser:seleteFullImage:)]) {
//        [self.delegate photoBrowser:self seleteFullImage:self.fullImageButton.selected];
//    }
    if (self.fullImageButton.selected) {
//        [self updateNavigationBarAndToolBar];
//        BOOL success = [self.delegate photoBrowser:self seletedAsset:self.photoDataSources[self.currentIndex]];
//        if (success) {
//            [self updateSelestedNumber];
//            [self updateNavigationBarAndToolBar];
//        }
    }
}

#pragma mark - getter

- (UIView *)customBar {
    if (_customBar == nil) {
        _customBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 64)];
        _customBar.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        _customEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _customEffectView.frame = _customBar.frame;
        [_customBar addSubview:_customEffectView];
        
        [_customBar addSubview:[self checkButton]];
        [_customBar addSubview:[self cancleButton]];
        
        [_customBar addSubview:self.currentIndexLabel];
        self.currentIndexLabel.center = CGPointMake(_customBar.center.x, 44);
    }
    return _customBar;
}

- (UIView *)customBottomBar {
    if (_customBottomBar == nil) {
        _customBottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-49, [UIScreen mainScreen].applicationFrame.size.width, 49)];
        _customBottomBar.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        
        UIVisualEffectView *customEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        customEffectView.frame = _customBottomBar.bounds;
        [_customBottomBar addSubview:customEffectView];
        
        _sendButton = [self sendButton];
        [_customBottomBar addSubview:_sendButton];
        
    }
    return _customBottomBar;
}

- (SGTFullImageButton *)fullImageButton
{
    if (nil == _fullImageButton) {
        _fullImageButton = [[SGTFullImageButton alloc] initWithFrame:CGRectZero];
        [_fullImageButton addTarget:self action:@selector(fullImageButtonAction)];
        _fullImageButton.selected = false;
    }
    return _fullImageButton;
}

- (SGTSendButton *)sendButton {
    if (_sendButton == nil) {
        CGRect screenBound = [UIScreen mainScreen].bounds;
        CGFloat screenWidth = screenBound.size.width;
        _sendButton = [[SGTSendButton alloc] initWithFrame:CGRectZero];
        _sendButton.frame = CGRectMake(screenWidth-60, 11.5, 58, 26);
        [_sendButton addTaget:self action:@selector(sendButtonAction:)];
    }
    return _sendButton;
}

- (UIButton *)cancleButton {
    if (nil == _cancleButton) {
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if ([self isControllerPushed]) {
            _cancleButton.frame = CGRectMake(10, 30, 25, 25);
            UIImage *cancleImage = self.cancleImage ? self.cancleImage : [UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"back_normal"];
            [_cancleButton setImage:cancleImage forState:UIControlStateNormal];
        }else {
            _cancleButton.titleLabel.font = [UIFont systemFontOfSize:15];
            _cancleButton.frame = CGRectMake(10, 30, 42, 25);
            [_cancleButton setTitle:@"取消" forState:UIControlStateNormal];
            [_cancleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [_cancleButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleButton;
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

- (UILabel *)currentSelectCountLabel {
    if (_currentSelectCountLabel == nil) {
        _currentSelectCountLabel  = [[UILabel alloc] initWithFrame:CGRectMake(10, 11.5, 100, 26)];
        _currentSelectCountLabel.font = [UIFont systemFontOfSize:15];
        _currentSelectCountLabel.backgroundColor = [UIColor clearColor];
    }
    return _currentSelectCountLabel;
}

- (UIButton *)checkButton
{
    if (nil == _checkButton) {
        CGRect screenBound = [UIScreen mainScreen].bounds;
        CGFloat screenWidth = screenBound.size.width;
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.frame = CGRectMake(screenWidth - 40, 30, 25, 25);
        [_checkButton setBackgroundImage:[UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"photo_check_selected"] forState:UIControlStateSelected];
        [_checkButton setBackgroundImage:[UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"photo_check_default"] forState:UIControlStateNormal];
        [_checkButton addTarget:self action:@selector(checkButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}

@end
