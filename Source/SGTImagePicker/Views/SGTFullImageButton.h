//
//  DNFullImageButton.h
//  ImagePicker
//
//  Created by block on 15/3/2.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGTFullImageButton : UIView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) NSString *text;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)addTarget:(id)target action:(SEL)action;
- (void)shouldAnimating:(BOOL)animate;
@end
