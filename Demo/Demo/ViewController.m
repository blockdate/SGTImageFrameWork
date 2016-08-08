//
//  ViewController.m
//  Demo
//
//  Created by 磊吴 on 16/8/8.
//  Copyright © 2016年 磊吴. All rights reserved.
//

#import "ViewController.h"
#import "SGTImagePickerController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    SGTImagePickerController *c = [[SGTImagePickerController alloc] initWithMaxCount:9];
    [self presentViewController:c animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
