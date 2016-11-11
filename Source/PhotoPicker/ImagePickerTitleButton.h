//
//  ImagePickerTitleButton.h
//  Demo
//
//  Created by 吴磊 on 2016/11/9.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickerTitleButton : UIButton

@property (nonatomic, strong) UILabel       *rt_titleLabel;
@property (nonatomic, strong) UIImageView   *rt_arrowView;

- (void)rt_setTitle:(NSString *)title arrowAppearance:(BOOL)appearance;

@end
