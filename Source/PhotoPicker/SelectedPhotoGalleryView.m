//
//  SelectedPhotoGalleryView.m
//  Demo
//
//  Created by 吴磊 on 2016/11/10.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SelectedPhotoGalleryView.h"
#import "SGTPhotoThumbCollectionViewCell.h"
#import "SGTPhotoProtocol.h"
#import <Masonry/Masonry.h>
#import "SGTPhotoMarco.h"
#import "SGTPhotoBrowserPicker.h"

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define kSizeThumbnailCollectionView  ([UIScreen mainScreen].bounds.size.width-10)/4

@interface SelectedPhotoGalleryView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong, nonnull) UICollectionView *photoCollectionView;
@property (nonatomic, strong, nonnull) NSMutableArray *photoArray;

@end

@implementation SelectedPhotoGalleryView

- (instancetype)init {
    self = [super init];
    _photoArray = [NSMutableArray array];
    [self addSubview:self.photoCollectionView];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    _photoArray = [NSMutableArray array];
    [self addSubview:self.photoCollectionView];
    return self;
}

- (void)layoutSubviews {
    [self.photoCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.photoCollectionView reloadData];
}
- (void)addPhoto:(id<SGTPhotoSelectProtocol>)photo {
    [_photoArray addObject:photo];
    [self.photoCollectionView reloadData];
    [self scrollerToBottom: YES];
    if ([self.delegate respondsToSelector:@selector(sgtSelectedPhotoGalleryView:statueChaned:photo:)]) {
        [self.delegate sgtSelectedPhotoGalleryView:self statueChaned:_photoArray.count-1 photo:photo];
    }
}

- (void)removePhoto:(id<SGTPhotoSelectProtocol>)photo {
    NSInteger index = [_photoArray indexOfObject:photo];
    
    [_photoArray removeObject:photo];
    [self.photoCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    
    if ([self.delegate respondsToSelector:@selector(sgtSelectedPhotoGalleryView:statueChaned:photo:)]) {
        [self.delegate sgtSelectedPhotoGalleryView:self statueChaned:index photo:photo];
    }
    
}

- (void)scrollerToBottom:(BOOL)animated {
    NSInteger rows = [self.photoCollectionView numberOfItemsInSection:0] - 1;
    [self.photoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:rows inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
}

#pragma mark - UICollectionView delegate and Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SGTPhotoThumbCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SGTPhotoThumbCollectionViewCell" forIndexPath:indexPath];
    CGSize itemSize = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
    CGSize targetSize = SGTCGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
    id<SGTPhotoSelectProtocol> photo = self.photoArray[indexPath.row];
    photo.preferSize = targetSize;
    [cell fillWithPhoto:photo];
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(kSizeThumbnailCollectionView, kSizeThumbnailCollectionView);
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SGTPhotoThumbCollectionViewCell *cell = (SGTPhotoThumbCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.selectPhotoHandle) {
        self.selectPhotoHandle(cell.imageView, indexPath.row);
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}
#pragma mark - Getter

- (UICollectionView *)photoCollectionView {
    if (nil == _photoCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 2.0;
        layout.minimumInteritemSpacing = 2.0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
        _photoCollectionView.backgroundColor = [UIColor clearColor];
        [_photoCollectionView registerClass:[SGTPhotoThumbCollectionViewCell class] forCellWithReuseIdentifier:@"SGTPhotoThumbCollectionViewCell"];
        _photoCollectionView.allowsMultipleSelection = NO;
        _photoCollectionView.alwaysBounceVertical = NO;
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
//        _photoCollectionView.showsHorizontalScrollIndicator = YES;
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
    }
    return _photoCollectionView;
}

@end
