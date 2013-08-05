//
//  SecondViewController.m
//  YKImageCacherDemo
//
//  Created by zhang zhiyu on 13-8-2.
//  Copyright (c) 2013年 York. All rights reserved.
//

#import "SecondViewController.h"
#import "YKImageCacher.h"

@interface SecondViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Images" ofType:@"plist"];
    imageArray = [[NSArray arrayWithContentsOfFile:path] retain];
    
    self.myTableView.dataSource = self;
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_myTableView release];
    [imageArray release];
    [super dealloc];
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [imageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SecondCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SecondCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageURLStr = [imageArray objectAtIndex:indexPath.row];
    NSURL *imageURL = [NSURL URLWithString:imageURLStr];
    UIImageView *imgv = (UIImageView *)[cell viewWithTag:200];
    
    if (![[YKImageCacher sharedCacher] hasCachedImage:imageURL]) {
        [[YKImageCacher sharedCacher] addImageCachedTask:imageURL withFinishedHandler:^(NSURL *imageURL){
            NSData *imageData = [[YKImageCacher sharedCacher] dataOfCachedImage:imageURL];
            [imgv setImage:[UIImage imageWithData:imageData]];
        }];
    }else{
        NSData *imageData = [[YKImageCacher sharedCacher] dataOfCachedImage:imageURL];
        [imgv setImage:[UIImage imageWithData:imageData]];
    }
    
    UILabel *lb_index = (UILabel *)[cell viewWithTag:300];
    lb_index.text = [NSString stringWithFormat:@"%d",indexPath.row];
}
@end
