//
//  CTAssetsViewController.h
//  QianKr
//
//  Created by 磊吴 on 15/6/30.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CTAssetsViewController : UIViewController

@property (nonatomic, weak) UIViewController *creatAlbumSourceController;

@property (nonatomic, assign) BOOL shouldDismissWhenFinished;

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end
