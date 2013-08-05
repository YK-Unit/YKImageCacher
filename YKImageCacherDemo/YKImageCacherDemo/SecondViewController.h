//
//  SecondViewController.h
//  YKImageCacherDemo
//
//  Created by zhang zhiyu on 13-8-2.
//  Copyright (c) 2013年 York. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController
<UITableViewDataSource>
{
    NSArray *imageArray;
}
@property (retain, nonatomic) IBOutlet UITableView *myTableView;

@end
