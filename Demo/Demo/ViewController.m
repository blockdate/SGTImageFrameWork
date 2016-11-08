//
//  ViewController.m
//  Demo
//
//  Created by 磊吴 on 16/8/8.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "ViewController.h"
#import "SGTImagePickerController.h"
#import "PhotoBroswerVC.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "SGTPhoto.h"
#import "SGTPhotoBrowser.h"
#import "SGTPhotoBrowserPicker.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedImage:)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedImage:)];
    [_imageView1 addGestureRecognizer:tap];
    [_imageView2 addGestureRecognizer:tap2];
}


- (void)tapedImage:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    NSInteger index = [view isEqual:_imageView1] ? 0 : 1;
    NSMutableArray<SGTPhotoProtocol> *photos = [NSMutableArray<SGTPhotoProtocol> new];
    id<SGTPhotoProtocol> photo = [SGTPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo1l" ofType:@"jpg"]];
    [photos addObject:photo];
    photo = [SGTPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]];
    
    [photos addObject:photo];
    photo = [SGTPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg"]];
    [photos addObject:photo];
    SGTPhotoBrowser *p = [[SGTPhotoBrowser alloc] initWithPhotos:photos animatedFromView:view];
    [p setInitialPageIndex:index];
    [self presentViewController:p animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self openLocalPhotoPicker];
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            [self test];
        }else if (indexPath.row == 1) {
            
        }else {
            
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)openLocalPhotoPicker {
    SGTImagePickerController *c = [[SGTImagePickerController alloc] initWithMaxCount:9];
    [self presentViewController:c animated:true completion:nil];
}

- (void)test {
    NSMutableArray<SGTPhotoSelectProtocol> *photos = [NSMutableArray<SGTPhotoSelectProtocol> new];
    id<SGTPhotoSelectProtocol> photo = [SGTPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]];
    
    [photos addObject:photo];
    photo = [SGTPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg"]];
    
    [photos addObject:photo];
    SGTPhotoBrowserPicker *browser = [[SGTPhotoBrowserPicker alloc] initWithSelectedPhotos:photos];
//    browser.disableVerticalSwipe = true;
    browser.forceHideStatusBar = NO;
//    [self.navigationController pushViewController:browser animated:true];
    browser.finishHandle = ^(BOOL finish, NSArray<SGTPhotoSelectProtocol>*photos) {
        NSLog(@"pick image finished count : %ld", photos.count);
    };
    [self presentViewController:browser animated:YES completion:nil];
}

@end
