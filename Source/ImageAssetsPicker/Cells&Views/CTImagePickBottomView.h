//
//  CTImagePickBottomView.h
//  QianKr
//
//  Created by 磊吴 on 15/6/30.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CTImagePickBottomView;
@protocol CTImagePickBottomViewDelegate <NSObject>

- (void)ctImagePickBottomView:(CTImagePickBottomView *)view tapButtonAtIndex:(NSInteger)index ;

@end

@interface CTImagePickBottomView : UIView

@property (nonatomic, copy) NSNumber *limitCount;

@property (nonatomic, copy) NSNumber *count;

@property (nonatomic, weak) id<CTImagePickBottomViewDelegate> delegate;

@end
