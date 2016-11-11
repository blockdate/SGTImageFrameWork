//
//  PhotoThumbCollectionViewCell.h
//  Demo
//
//  Created by 吴磊 on 2016/11/10.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SGTPhotoSelectProtocol;

@interface SGTPhotoThumbCollectionViewCell : UICollectionViewCell

@property (nonatomic, nonnull, strong) UIImageView *imageView;
@property (nonatomic, strong, nullable) id<SGTPhotoSelectProtocol> photo;
- (void)fillWithPhoto:(id<SGTPhotoSelectProtocol> _Nonnull)asset;

@end
