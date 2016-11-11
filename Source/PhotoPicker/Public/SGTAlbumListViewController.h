//
//  SGTAlbumListViewController.h
//  Demo
//
//  Created by 吴磊 on 2016/11/8.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHFetchResult,PHAssetCollection,SGTPhotoFlowViewController;

@interface SGTAlbumListViewController : UITableViewController

@property (nonatomic) NSInteger maxPickCount;
@property (nonatomic, weak, nullable) SGTPhotoFlowViewController *photoFlowViewController;

- (instancetype _Nonnull)initWithPhotoCollections:(NSMutableArray<PHAssetCollection *> *_Nonnull)photoCollectionArray;

- (void)updatePhotoCollections:(NSMutableArray<PHAssetCollection *> *_Nonnull)photoCollectionArray;

@end
