//
//  SGTImagePickerController.m
//  ImagePicker
//
//  Created by block on 15/2/10.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "SGTImagePickerController.h"
#import "SGTAlbumTableViewController.h"
#import "SGTImageFlowViewController.h"
#import "SGTImageAsset.h"

NSString *kDNImagePickerStoredGroupKey = @"com.dennis.kDNImagePickerStoredGroup";

ALAssetsFilter * ALAssetsFilterFromDNImagePickerControllerFilterType(SGTImagePickerFilterType type)
{
    switch (type) {
        default:
        case None:
            return [ALAssetsFilter allAssets];
            break;
        case Photos:
            return [ALAssetsFilter allPhotos];
            break;
        case Videos:
            return [ALAssetsFilter allVideos];
            break;
    }
}

@interface SGTImagePickerController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> navDelegate;
@property (nonatomic, assign) BOOL isDuringPushAnimation;

@end

@implementation SGTImagePickerController

- (void)dealloc
{
    NSLog(@"%s DNImagePickerController",__FUNCTION__);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.kDNImageFlowMaxSeletedNumber = 9;
    }
    return self;
}

- (instancetype)initWithMaxCount:(NSInteger)maxCount
{
    self = [super init];
    if (self) {
        self.kDNImageFlowMaxSeletedNumber = maxCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.delegate) {
        self.delegate = self;
    }
    
    self.interactivePopGestureRecognizer.delegate = self;
    
    NSString *propwetyID = [[NSUserDefaults standardUserDefaults] objectForKey:kDNImagePickerStoredGroupKey];

    if (propwetyID.length <= 0) {
        [self showAlbumList];
    } else {
        ALAssetsLibrary *assetsLibiary = [[ALAssetsLibrary alloc] init];
        [assetsLibiary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop)
         {
             if (assetsGroup == nil && *stop ==  NO) {
                 [self showAlbumList];
             }
             
             NSString *assetsGroupID= [assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
             if ([assetsGroupID isEqualToString:propwetyID]) {
                 *stop = YES;
                 NSURL *assetsGroupURL = [assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
                 SGTAlbumTableViewController *albumTableViewController = [[SGTAlbumTableViewController alloc] init];
                 SGTImageFlowViewController *imageFlowController = [[SGTImageFlowViewController alloc] initWithGroupURL:assetsGroupURL];

                 albumTableViewController.kDNImageFlowMaxSeletedNumber = self.kDNImageFlowMaxSeletedNumber;
                 imageFlowController.kDNImageFlowMaxSeletedNumber = self.kDNImageFlowMaxSeletedNumber;
                 [self setViewControllers:@[albumTableViewController,imageFlowController]];
             }
         }
                                   failureBlock:^(NSError *error)
         {
             [self showAlbumList];
         }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - priviate methods
- (void)showAlbumList
{
    SGTAlbumTableViewController *albumTableViewController = [[SGTAlbumTableViewController alloc] init];
    albumTableViewController.kDNImageFlowMaxSeletedNumber = self.kDNImageFlowMaxSeletedNumber;
    [self setViewControllers:@[albumTableViewController]];
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
