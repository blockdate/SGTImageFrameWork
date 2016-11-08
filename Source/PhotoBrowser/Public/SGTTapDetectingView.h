//
//  SGTTapDetectingView.h
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGTTapDetectingViewDelegate.h"


@interface SGTTapDetectingView : UIView

@property (nonatomic, weak) id <SGTTapDetectingViewDelegate> delegate;
- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;

@end
