//
//  SGTTapDetectingImageViewDelegate.h
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SGTTapDetectingImageViewDelegate <NSObject>
@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;
@end
