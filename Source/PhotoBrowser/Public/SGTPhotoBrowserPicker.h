//
//  SGTPhotoBrowserPicker.h
//  SGTImageFramework
//
//  Created by 吴磊 on 2016/11/7.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTPhotoBrowser.h"
#import "SGTPhotoBrowserDelegate.h"

@interface SGTPhotoBrowserPicker : SGTPhotoBrowser <SGTPhotoBrowserPickerProtocol>

@property (nonatomic, copy, nullable) void(^finishHandle)(BOOL finish, NSArray<SGTPhotoSelectProtocol>* _Nonnull photos) ;
@property (nonatomic, nullable, strong) UIImage *cancleImage;

@end
