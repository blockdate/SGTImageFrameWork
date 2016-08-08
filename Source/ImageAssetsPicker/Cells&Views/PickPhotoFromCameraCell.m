//
//  PickPhotoFromCameraCell.m
//  QianKr
//
//  Created by 磊吴 on 15/6/30.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import "PickPhotoFromCameraCell.h"
#import "Masonry.h"

@implementation PickPhotoFromCameraCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_Camera"]];
    UIGraphicsBeginImageContext(CGSizeMake(40, 30));
    [@"+" drawInRect:CGRectMake(0, 0, 40, 30) withAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:30]}];
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image.image = image2;
    [self.contentView addSubview:image];
    UIView *superView = self.contentView;
    superView.backgroundColor = [UIColor colorWithRed:0.102 green:0.071 blue:0.059 alpha:1.000];
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(superView);
        make.size.width.sizeOffset(CGSizeMake(40, 30));
    }];
}

- (void)layoutMasonry {
    
}

- (void)bindViewModel {
    
}

@end
