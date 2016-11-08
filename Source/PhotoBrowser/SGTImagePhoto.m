//
//  SGTImagePhoto.m
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/2.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTImagePhoto.h"

@interface SGTPhoto()
- (void)imageLoadingComplete;
@end

@interface SGTImagePhoto()

@end

@implementation SGTImagePhoto

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.underlyingImage = image;
    }
    return self;
}

- (void)loadUnderlyingImageAndNotify {
    [super loadUnderlyingImageAndNotify];
//    image already set with init
    [self imageLoadingComplete];
}

- (void)unloadUnderlyingImage {
//    just release the image by super
    [super unloadUnderlyingImage];
}

@end
