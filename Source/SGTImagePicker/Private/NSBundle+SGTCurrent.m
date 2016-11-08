//
//  NSBundle+SGTCurrent.m
//  Demo
//
//  Created by 吴磊 on 2016/11/7.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "NSBundle+SGTCurrent.h"
#import "SGTPhotoBrowser.h"
@implementation NSBundle (SGTCurrent)

+ (instancetype)sgt_currentBundle {
    return [NSBundle bundleForClass:[SGTPhotoBrowser class]];
}

@end
