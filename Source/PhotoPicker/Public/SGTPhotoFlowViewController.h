//
//  SGTPhotoFlowViewController.h
//  Demo
//
//  Created by 吴磊 on 2016/11/8.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SGTPhotoPickerControllerDelegate;

@class PHAssetCollection;

@interface SGTPhotoFlowViewController : UIViewController

/**
 the max pick count of the photo
 */
@property (nonatomic) NSInteger maxPickCount;

/**
 asset allow select type, now only image was avaliable
 */
@property (nonatomic, nonnull, strong) NSArray *assetCollectionSubtypes;

@property (nonatomic, nullable, weak) id<SGTPhotoPickerControllerDelegate> photoPickerDelegate;
/**
 show the direct photoCollection

 @param photoCollection the photoCollection to show
 */
- (void)showPhotoCollection:(PHAssetCollection * _Nonnull)photoCollection;

@end
