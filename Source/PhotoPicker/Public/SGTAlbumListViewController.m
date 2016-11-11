//
//  SGTAlbumListViewController.m
//  Demo
//
//  Created by 吴磊 on 2016/11/8.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import <Photos/Photos.h>
#import "SGTAlbumListViewController.h"
#import "SGTPhotoFlowViewController.h"

@interface SGTAlbumListViewController () {
//    PHFetchResult<PHAssetCollection *> *_photoCollectionList;
//    NSArray<PHAssetCollection *> *_additionCollections;
}
@property (nonatomic, nonnull, strong) NSArray *photoClollectionArray;
@end

@implementation SGTAlbumListViewController

#pragma mark - Object

- (instancetype)initWithPhotoCollections:(NSMutableArray<PHAssetCollection *> *)photoCollectionArray {
    self = [super init];
    if (self) {
        _photoClollectionArray = photoCollectionArray;
    }
    return self;
}

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SGTAlbumListViewController_Cell"];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    [footer setBackgroundColor:[UIColor lightTextColor]];
    self.tableView.tableFooterView = footer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Datas

- (void)initializeData {
    
}

- (void)updatePhotoCollections:(NSMutableArray<PHAssetCollection *> *)photoCollectionArray {
    self.photoClollectionArray = photoCollectionArray;
    [self.tableView reloadData];
}

#pragma mark - TableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photoClollectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SGTAlbumListViewController_Cell"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    PHAssetCollection *collection = self.photoClollectionArray[indexPath.row];
    
    PHFetchResult<PHAsset *> *photos = [PHAsset fetchKeyAssetsInAssetCollection:collection options:nil];
    PHAsset *assert = [photos firstObject];
    if (assert) {
        [[PHImageManager defaultManager] requestImageDataForAsset:assert options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image = [UIImage imageWithData:imageData];
            cell.imageView.image = image;
            [cell setNeedsLayout];
        }];
    }
    NSString *title = collection.localizedTitle;
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    NSString *count = [NSString stringWithFormat:@" (%ld)",result.count];
    NSMutableAttributedString *ms = [[NSMutableAttributedString alloc] initWithString:title];
    [ms appendAttributedString:[[NSMutableAttributedString alloc] initWithString:count attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
    
    cell.textLabel.attributedText = ms;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.photoFlowViewController) {
        [self.photoFlowViewController showPhotoCollection:self.photoClollectionArray[indexPath.row]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
