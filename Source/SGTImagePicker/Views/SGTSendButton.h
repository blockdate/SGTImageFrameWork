//
//  DNSendButton.h
//  ImagePicker
//
//  Created by block on 15/2/24.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGTSendButton : UIView

@property (nonatomic, strong) NSString *badgeValue;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addTaget:(id)target action:(SEL)action;

@end
