//
//  SGTPhotoMarco.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/2.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#ifndef _SGTPHOTOMARCO_H_
#define _SGTPHOTOMARCO_H_

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

const NSString *const SGT_Photo_loading_Finish_Notification = @"SGT_Photo_loading_Finish_Notification";
const int sgt_padding = 10;

CGSize SGTCGSizeScale(CGSize size, CGFloat scale) {
    return CGSizeMake(size.width * scale, size.height * scale);
}

#endif
