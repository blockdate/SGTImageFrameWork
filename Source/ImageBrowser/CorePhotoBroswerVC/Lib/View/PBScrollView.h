//
//  PBScrollView.h
//  CorePhotoBroswerVC
//
//  Created by block on 15/5/8.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBScrollView : UIScrollView

@property (nonatomic,assign) NSUInteger index;


/** 照片数组 */
@property (nonatomic,strong) NSArray *photoModels;



@end
