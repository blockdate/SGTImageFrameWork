//
//  SGTNavViewController.m
//  Demo
//
//  Created by 吴磊 on 2016/11/4.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "SGTNavViewController.h"

@interface SGTNavViewController ()

@end

@implementation SGTNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

@end
