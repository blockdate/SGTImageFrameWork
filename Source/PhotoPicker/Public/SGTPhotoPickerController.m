//
//  SGTPhotoPickerController.m
//  Demo
//
//  Created by 吴磊 on 2016/11/8.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <Photos/Photos.h>
#import "SGTPhotoPickerController.h"
#import "SGTAlbumListViewController.h"
#import "SGTPhotoFlowViewController.h"

NSString * _Nonnull sgtImagePickerStoredGroupKey = @"sgtImagePickerStoredGroupKey";

@interface SGTPhotoPickerController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> navDelegate;
@property (nonatomic, assign) BOOL isDuringPushAnimation;

@end

@implementation SGTPhotoPickerController

- (void)dealloc
{
    NSLog(@"%s SGTPhotoPickerController",__FUNCTION__);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxPickCount = 9;
    }
    return self;
}

- (instancetype)initWithMaxPickCount:(NSInteger)count{
    self = [super init];
    if (self) {
        self.maxPickCount = count;
    }
    return self;
}

- (instancetype)initWithMaxPickCount:(NSInteger)count pickerDelegate:(id<SGTPhotoPickerControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.maxPickCount = count;
        self.photoPickerDelegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.delegate) {
        self.delegate = self;
    }
    
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if(status == PHAuthorizationStatusAuthorized) {
                    [self authorizadSuccess];
                }else {
                    [self showUnAuthorizaView];
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized:{
            [self authorizadSuccess];
        }
            break;
        default:
            [self showUnAuthorizaView];
            break;
    }
    
    self.interactivePopGestureRecognizer.delegate = self;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - priviate methods

- (void)authorizadSuccess {
    NSString *propwetyID = [[NSUserDefaults standardUserDefaults] objectForKey:sgtImagePickerStoredGroupKey];
    
    if (propwetyID.length <= 0) {
        [self showAlbumList];
    } else {
        PHFetchResult<PHAssetCollection *> *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        if (collection != nil && collection.count <= 0) {
            [collection enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
            }];
        }else {
            [self showAlbumList];
        }
    }
}

- (void)showAlbumList
{
    SGTPhotoFlowViewController *c = [[SGTPhotoFlowViewController alloc] init];
    c.photoPickerDelegate = self.photoPickerDelegate;
    [self setViewControllers:@[c]];
}

- (void)showUnAuthorizaView {
    
}

#pragma mark - UINavigationController

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    [super setDelegate:delegate ? self : nil];
    self.navDelegate = delegate != self ? delegate : nil;
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated __attribute__((objc_requires_super))
{
    self.isDuringPushAnimation = YES;
    [super pushViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    self.isDuringPushAnimation = NO;
    if ([self.navDelegate respondsToSelector:_cmd]) {
        [self.navDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return [self.viewControllers count] > 1 && !self.isDuringPushAnimation;
    } else {
        return YES;
    }
}

#pragma mark - Delegate Forwarder

- (BOOL)respondsToSelector:(SEL)s
{
    return [super respondsToSelector:s] || [self.navDelegate respondsToSelector:s];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)s
{
    return [super methodSignatureForSelector:s] ?: [(id)self.navDelegate methodSignatureForSelector:s];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    id delegate = self.navDelegate;
    if ([delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:delegate];
    }
}

@end	
