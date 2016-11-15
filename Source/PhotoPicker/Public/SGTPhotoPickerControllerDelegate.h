//
//  SGTPhotoPickerControllerDelegate.h
//  Demo
//
//  Created by 吴磊 on 2016/11/8.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGTPhotoProtocol.h"

@class SGTPhotoPickerController;

@protocol SGTPhotoPickerControllerDelegate <NSObject>
@optional
- (void)sgtphotoPickFinishedWithImages:(NSArray<SGTPhotoSelectProtocol>*)photos otherInfo:(NSDictionary *)info;
- (void)sgtphotoPickCancled:(SGTPhotoPickerController *)controller;

@end
