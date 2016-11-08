//
//  SGTTapDetectingView.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTTapDetectingView.h"

@implementation SGTTapDetectingView


- (id)init {
    if ((self = [super init])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            [self handleSingleTap:touch];
            break;
        case 2:
            [self handleDoubleTap:touch];
            break;
        case 3:
            [self handleTripleTap:touch];
            break;
        default:
            break;
    }
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
    if (_delegate && [_delegate respondsToSelector:@selector(view:singleTapDetected:)])
        [_delegate view:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    if (_delegate && [_delegate respondsToSelector:@selector(view:doubleTapDetected:)])
        [_delegate view:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
    if (_delegate && [_delegate respondsToSelector:@selector(view:tripleTapDetected:)])
        [_delegate view:self tripleTapDetected:touch];
}

@end
