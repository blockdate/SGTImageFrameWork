//
//  PhotoThumbCollectionViewCell.m
//  Demo
//
//  Created by 吴磊 on 2016/11/10.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTPhotoThumbCollectionViewCell.h"
#import "UIImage+Extend.h"
#import <Masonry/Masonry.h>
#import "SGTPhotoProtocol.h"

@interface SGTPhotoThumbCollectionViewCell()



@end
@implementation SGTPhotoThumbCollectionViewCell

#pragma mark - Object

- (void)dealloc {
    [_photo unloadUnderlyingImage];
    self.imageView.image = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews {
    UIView *superView = self.contentView;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
    [super layoutSubviews];
}
- (void)fillWithPhoto:(id<SGTPhotoSelectProtocol>)asset {
    __weak typeof(self) weakSelf = self;
    _photo = asset;
    [_photo loadUnderlyImageFinished:^(id<SGTPhotoProtocol> _Nonnull photo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.imageView.image = [photo underlyingImage];
    }];
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}
@end
