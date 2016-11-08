//
//  SGTTapDetectingImageView.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/3.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTTapDetectingImageView.h"

@implementation SGTTapDetectingImageView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if ((self = [super initWithImage:image highlightedImage:highlightedImage])) {
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
    if (_delegate && [_delegate respondsToSelector:@selector(imageView:singleTapDetected:)])
        [_delegate imageView:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    if (_delegate && [_delegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
        [_delegate imageView:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
    if (_delegate && [_delegate respondsToSelector:@selector(imageView:tripleTapDetected:)])
        [_delegate imageView:self tripleTapDetected:touch];
}

@end
