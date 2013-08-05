//
//  FirstViewController.m
//  YKImageCacherDemo
//
//  Created by zhang zhiyu on 13-8-2.
//  Copyright (c) 2013年 York. All rights reserved.
//

#import "FirstViewController.h"
#import "YKImageCacher.h"

@interface FirstViewController ()
- (void)doCachedImage;
@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self doCachedImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doCachedImage
{
    UIImageView *imgv_1 = (UIImageView *)[self.view viewWithTag:200];
    UIImageView *imgv_2 = (UIImageView *)[self.view viewWithTag:201];

    NSURL *imageURL_1 = [NSURL URLWithString:@"http://g.hiphotos.baidu.com/album/w%3D2048/sign=4106f3c3d000baa1ba2c40bb7328b812/0e2442a7d933c8950f78a654d01373f08202009e.jpg"];
    NSURL *imageURL_2 = [NSURL URLWithString:@"http://b.hiphotos.baidu.com/album/w%3D2048/sign=6481e88450da81cb4ee684cd665ed116/eac4b74543a9822606132b578b82b9014b90ebf4.jpg"];

    if (![[YKImageCacher sharedCacher] hasCachedImage:imageURL_1]) {
        [[YKImageCacher sharedCacher] addImageCachedTask:imageURL_1 withFinishedHandler:^(NSURL *imageURL){
            NSData *imageData = [[YKImageCacher sharedCacher] dataOfCachedImage:imageURL];
            [imgv_1 setImage:[UIImage imageWithData:imageData]];
            NSLog(@"imageURL1:%@",[imageURL description]);
        }];
    }else{
        NSData *imageData = [[YKImageCacher sharedCacher] dataOfCachedImage:imageURL_1];
        [imgv_1 setImage:[UIImage imageWithData:imageData]];
    }
    
    [[YKImageCacher sharedCacher] addImageCachedTask:imageURL_2 withFinishedHandler:^(NSURL *imageURL){
        NSData *imageData = [[YKImageCacher sharedCacher] dataOfCachedImage:imageURL];
        [imgv_2 setImage:[UIImage imageWithData:imageData]];
        NSLog(@"imageURL2:%@",[imageURL description]);
    }];

}
- (IBAction)doClearCaches:(id)sender {
    [[YKImageCacher sharedCacher] clearAllCaches];
}
@end
