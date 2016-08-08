
/*
 CTAssetsPickerController.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */


#import "CTAssetsPickerController.h"
#import "CTAssetsGroupViewController.h"
#pragma mark - Interfaces

@interface CTAssetsPickerController (){
    CTAssetsGroupViewController *groupViewController;
}

@end

@implementation CTAssetsPickerController

- (id)init
{
    groupViewController = [[CTAssetsGroupViewController alloc] init];
    if (self = [super initWithRootViewController:groupViewController])
    {
        _maximumNumberOfSelection   = NSIntegerMax;
        _assetsFilter               = [ALAssetsFilter allPhotos];
        _showsCancelButton          = YES;
        
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setCreatAlbumSourceController:(UIViewController *)creatAlbumSourceController {
    _creatAlbumSourceController = creatAlbumSourceController;
    groupViewController.creatAlbumSourceController = self.creatAlbumSourceController;
}

- (void)setShouldDismissWhenFinished:(BOOL)shouldDismissWhenFinished {
    _shouldDismissWhenFinished = shouldDismissWhenFinished;
    groupViewController.shouldDismissWhenFinished = shouldDismissWhenFinished;
}

@end