//
//  SGTPhotoAssetViewCell.m
//  Demo
//
//  Created by 吴磊 on 2016/11/10.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTPhotoAssetViewCell.h"
#import "SGTPhotoProtocol.h"
#import "UIImage+Extend.h"
#import <Masonry/Masonry.h>
@interface SGTPhotoAssetViewCell()<SGTPhotoSelectStatueChangeDelegate>


@property (nonatomic, nonnull, strong) UIButton *selectStatuButton;
@property (nonatomic, strong) UIImageView *checkImageView;

@end

@implementation SGTPhotoAssetViewCell

#pragma mark - Object

- (void)dealloc {
    [_photo unloadUnderlyingImage];
    self.imageView.image = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.checkImageView];
        [self.contentView addSubview:self.selectStatuButton];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.checkImageView];
        [self.contentView addSubview:self.selectStatuButton];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.checkImageView];
        [self.contentView addSubview:self.selectStatuButton];
    }
    return self;
}

- (void)layoutSubviews {
    UIView *superView = self.contentView;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
    [self.checkImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.equalTo(superView);
        make.width.and.height.equalTo(@(25));
    }];
    [self.selectStatuButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.equalTo(superView);
        make.width.and.height.equalTo(superView).multipliedBy(0.5);
    }];
    
    [super layoutSubviews];
}

#pragma mark - ViewLiftCycle

- (void)prepareForReuse {
    [_photo unloadUnderlyingImage];
    _photo.delegate = nil;
    self.imageView.image = nil;
    [super prepareForReuse];
}

#pragma mark View Change

- (void)selectButtonClickAction:(UIButton *)sender {
    self.photo.isSelect = !self.photo.isSelect;
}

- (void)fillWithPhoto:(id<SGTPhotoSelectProtocol>)asset {
    __weak typeof(self) weakSelf = self;
    _photo = asset;
    [self updateSelectButton];
    _photo.delegate = self;
    [_photo loadUnderlyImageFinished:^(id<SGTPhotoProtocol> _Nonnull photo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.imageView.image = [photo underlyingImage];
    }];
}

- (void)updateSelectButton {
    if (self.photo.isSelect) {
        self.checkImageView.image = [UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"photo_check_selected"];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.checkImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.2 animations:^{
                                 self.checkImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             }];
                         }];
    } else {
        self.checkImageView.image = [UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"photo_check_default"];
    }
}

#pragma mark - SGTPhotoSelectStatueChangeDelegate

-(void)sgtPhotoStatuChanged:(id<SGTPhotoSelectProtocol>)photo {
    [self updateSelectButton];
    if ([self.delegate respondsToSelector:@selector(sgtPhotoAssetViewCellStatuChanged:)]) {
        [self.delegate sgtPhotoAssetViewCellStatuChanged:self];
    }
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

- (UIImageView *)checkImageView {
    if (nil == _checkImageView) {
        _checkImageView = [[UIImageView alloc] init];
    }
    return  _checkImageView;
}

- (UIButton *)selectStatuButton {
    if (nil == _selectStatuButton) {
        _selectStatuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectStatuButton.backgroundColor = [UIColor clearColor];
        [_selectStatuButton addTarget:self action:@selector(selectButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectStatuButton;
}

@end
