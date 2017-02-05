//
//  UIImageView+SD.m
//  CoreSDWebImage
//
//  Created by block on 15/5/6.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "UIImageView+SD.h"
#import "UIImageView+WebCache.h"


@implementation UIImageView (SD)

/**
 *  imageView展示网络图片
 *
 *  @param urlStr  图片地址
 *  @param phImage 占位图片
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(UIImage *)phImage{
    
    if(urlStr==nil) return;
    
    NSURL *n = [NSURL URLWithString:urlStr relativeToURL:[NSURL URLWithString:@"http://182.92.85.57/"]];
    [self sd_setImageWithURL:n placeholderImage:phImage];
}



/**
 *  带有进度的网络图片展示
 *
 *  @param urlStr         图片地址
 *  @param phImage        占位图片
 *  @param progressBlock  进度
 *  @param completedBlock 完成
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(UIImage *)phImage progressBlock:(SDWebImageDownloaderProgressBlock)progressBlock completedBlock:(SDExternalCompletionBlock)completedBlock{
    
    if(urlStr==nil) return;
    
    NSURL *url=[NSURL URLWithString:urlStr relativeToURL:[NSURL URLWithString:@"http://182.92.85.57/"]];
    
    SDWebImageOptions options = SDWebImageLowPriority | SDWebImageRetryFailed;

    [self sd_setImageWithURL:url placeholderImage:phImage options:options progress:progressBlock completed:completedBlock];
}


@end
