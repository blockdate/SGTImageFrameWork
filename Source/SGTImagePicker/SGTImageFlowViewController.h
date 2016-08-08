//
//  DNImageFlowViewController.h
//  ImagePicker
//
//  Created by block on 15/2/11.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface SGTImageFlowViewController : UIViewController

@property (nonatomic, assign) NSInteger kDNImageFlowMaxSeletedNumber;

- (instancetype)initWithGroupURL:(NSURL *)assetsGroupURL;
@end
