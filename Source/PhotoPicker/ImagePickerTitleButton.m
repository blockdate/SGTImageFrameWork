//
//  ImagePickerTitleButton.m
//  Demo
//
//  Created by 吴磊 on 2016/11/9.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "ImagePickerTitleButton.h"
#import "UIView+Extend.h"
#import "UIImage+Extend.h"

@implementation ImagePickerTitleButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.rt_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.width - 60.0f)/2.0f, (self.height - 18.0f)/2.0f, 60.0f, 18.0f)];
        _rt_titleLabel.numberOfLines = 1;
        _rt_titleLabel.textColor = [UIColor colorWithRed:81/255.0 green:81/255.0 blue:81/255.0 alpha:1];
        _rt_titleLabel.textAlignment = NSTextAlignmentCenter;
        _rt_titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _rt_titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _rt_titleLabel.userInteractionEnabled = NO;
        [self addSubview:_rt_titleLabel];
        
        self.rt_arrowView = [[UIImageView alloc]initWithFrame:CGRectMake(_rt_titleLabel.right + 10.0f,(self.height - 15.0f)/2.0f, 15.0f, 15.0f)];
        _rt_arrowView.image = [UIImage sgt_imageWithBundleName:@"SGTImagePickerBundle" imageName:@"title_imagepicker_arrow"];
        _rt_arrowView.contentMode = UIViewContentModeScaleAspectFill;
        _rt_arrowView.userInteractionEnabled = NO;
        [self addSubview:_rt_arrowView];
    }
    return self;
}

- (void)rt_setTitle:(NSString *)title arrowAppearance:(BOOL)appearance
{
    _rt_titleLabel.text = title;
    [_rt_titleLabel sizeToFit];
    _rt_titleLabel.frame = CGRectMake((self.width - _rt_titleLabel.width)/2.0f, (self.height - 18.0f)/2.0f, _rt_titleLabel.width, 18.0f);
    
    if(appearance) {
        _rt_arrowView.hidden = NO;
        _rt_arrowView.frame = CGRectMake(_rt_titleLabel.right + 10.0f,(self.height - 15.0f)/2.0f, 15.0f, 15.0f);
    } else {
        _rt_arrowView.hidden = YES;
    }
}

@end
