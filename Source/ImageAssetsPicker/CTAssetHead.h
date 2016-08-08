//
//  CTAssetHead.h
//  QianKr
//
//  Created by 磊吴 on 15/6/30.
//  Copyright (c) 2015年 block. All rights reserved.
//

#ifndef QianKr_CTAssetHead_h
#define QianKr_CTAssetHead_h

#import <AssetsLibrary/AssetsLibrary.h>
#import "NSDate+TimeInterval.h"
#define IS_IOS7             ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
#define kThumbnailLength    78.0f
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)
#define kPopoverContentSize CGSizeMake(320, 480)
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define FontOfSize(size) [UIFont systemFontOfSize:size]

#endif
