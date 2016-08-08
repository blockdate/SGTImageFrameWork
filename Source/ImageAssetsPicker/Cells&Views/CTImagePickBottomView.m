//
//  CTImagePickBottomView.m
//  QianKr
//
//  Created by 磊吴 on 15/6/30.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import "CTImagePickBottomView.h"
#import "Masonry.h"
#import "CTAssetHead.h"

@interface CTImagePickBottomView()

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation CTImagePickBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self setupUI];
//        [self bindViewModel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rightButton.layer.cornerRadius = self.rightButton.frame.size.height/2;
}

- (void)setupUI {
    _limitCount = @10;
    
    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftButton setTitle:@"预览" forState:UIControlStateNormal];
    _leftButton.tag = 0;
    _leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _leftButton.titleLabel.font = FontOfSize(12);
    [_leftButton addTarget:self action:@selector(taped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftButton];
    
    _rightButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setTitle:@"确定" forState:UIControlStateNormal];
    _rightButton.tag = 1;
    _rightButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _rightButton.layer.borderWidth = 1;
    _rightButton.titleLabel.font = FontOfSize(12);
    _rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_rightButton addTarget:self action:@selector(taped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightButton];
    
    [self layoutMasonry];
}

- (void)layoutMasonry {
    UIView *superView = self;
    [_leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superView.mas_left).offset(15);
        make.centerY.equalTo(superView.mas_centerY);
        make.height.equalTo(@35);
        make.width.equalTo(@75);
    }];
    
    [_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superView.mas_right).offset(-15);
        make.centerY.equalTo(superView.mas_centerY);
        make.height.equalTo(@35);
        make.width.equalTo(@75);
    }];
}

//- (void)bindViewModel {
////    RAC(self,leftButton.enabled) = [self enableSignal];
////    RAC(self,rightButton.enabled) = [self enableSignal];
////    WS(weakSelf);
////    [RACObserve(self, count) subscribeNext:^(NSNumber *value) {
////        if ([value integerValue]<=0) {
////            [weakSelf.rightButton setTitle:FormatString(@"确定") forState:UIControlStateNormal];
////            weakSelf.rightButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
////        }else {
////            [weakSelf.rightButton setTitle:FormatString(@"确定（%@/%@）",value,_limitCount) forState:UIControlStateNormal];
////            weakSelf.rightButton.layer.borderColor = [UIColor whiteColor].CGColor;
////        }
////
////    }];
//}
//
//- (RACSignal *)enableSignal {
//    return [RACObserve(self, count) map:^id(NSNumber *value) {
//        if ([value integerValue]<=0) {
//            return @NO;
//        }
//        return @YES;
//    }];
//}

- (void)taped:(UIButton *)tap{
    NSInteger index = tap.tag;
    
    if (_delegate && [_delegate respondsToSelector:@selector(ctImagePickBottomView:tapButtonAtIndex:)]) {
        [_delegate ctImagePickBottomView:self tapButtonAtIndex:index];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    [self drawImageSelectBottomViewWithFrame:rect rightText:FormatString(@"确定：%@", @(_count))];;
}

@end
