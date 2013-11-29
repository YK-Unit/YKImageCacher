//
//  YKImageCacher.m
//  YKImageCacherDemo
//
//  Created by zhang zhiyu on 13-8-2.
//  Copyright (c) 2013年 York. All rights reserved.
//

#import "YKImageCacher.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>
#import "NSString+Hash.h"

#define defaultCacheDirectory @"com.york.unit"
#define CurrentCacheDirectoryName @"name_of_current_cache_directory"

@interface YKImageCacher(Private)
- (BOOL)createCacheDirectory:(NSString *)directoryName;
- (BOOL)removeCacheDirectory:(NSString *)directoryName;
- (NSString *)pathOfCurrentCacheDirectory;
- (NSString *)path4FileURLInCurrentCacheDirectory:(NSURL *)fileURL;
- (BOOL)createFileInCurrentCacheDirectory:(NSURL *)fileURL contents:(NSData *)contents attributes:(NSDictionary *)attributes;

- (void)scheduleBlock:(dispatch_block_t)block;

@end

@implementation YKImageCacher

static YKImageCacher *_ykCacher = nil;

- (id)init
{
    if (_ykCacher) {
        return _ykCacher;
    }else{
        self = [super init];
        if (self) {
            _taskQueue = dispatch_queue_create(class_getName([self class]), NULL);
            NSString *currentCacheDirectoryName = [[NSUserDefaults standardUserDefaults] objectForKey:CurrentCacheDirectoryName];
            if (currentCacheDirectoryName == nil) {
                [self setCacheDirectory:defaultCacheDirectory];
            }else{
                _cacheDirectory = [currentCacheDirectoryName copy];
            }
        }
        return  self;
    }
}

- (void)dealloc
{
    if (_cacheDirectory) {
        [_cacheDirectory release];
        _cacheDirectory = nil;
    }
    
    if (_taskQueue) {
        dispatch_release(_taskQueue);
    }
    
    [super dealloc];
}

+ (YKImageCacher *)sharedCacher
{
    if (!_ykCacher) {
        _ykCacher = [[self alloc]init];
    }
    
    return _ykCacher;
}

#pragma mark - private methods 
- (BOOL)createCacheDirectory:(NSString *)directoryName
{
    //获取沙盒中缓存文件目录
    NSArray *cacheDirectories =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *localCacheDirectory = [cacheDirectories objectAtIndex:0];
    
    NSString *yourCacheDirectoryPath = [localCacheDirectory stringByAppendingPathComponent:directoryName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:yourCacheDirectoryPath]) {
        return YES;
    }
    
    return [fileManager createDirectoryAtPath:yourCacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (BOOL)removeCacheDirectory:(NSString *)directoryName
{
    //获取沙盒中缓存文件目录
    NSArray *cacheDirectories =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *localCacheDirectory = [cacheDirectories objectAtIndex:0];
    
    NSString *yourCacheDirectoryPath = [localCacheDirectory stringByAppendingPathComponent:directoryName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    return [fileManager removeItemAtPath:yourCacheDirectoryPath error:nil];
}

- (NSString *)pathOfCurrentCacheDirectory
{
    NSArray *cacheDirectories =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *localCacheDirectory = [cacheDirectories objectAtIndex:0];
    
    NSString *yourCacheDirectoryPath = [localCacheDirectory stringByAppendingPathComponent:_cacheDirectory];
    
    return yourCacheDirectoryPath;
}

- (NSString *)path4FileURLInCurrentCacheDirectory:(NSURL *)fileURL
{
    NSString *cacheDirectoryPath = [self pathOfCurrentCacheDirectory];
    NSString *fileName = [[fileURL description] md5];
    NSString *filePath = [NSString stringWithFormat:@"%@/YK_%@",cacheDirectoryPath,fileName];
    return filePath;
}

- (BOOL)createFileInCurrentCacheDirectory:(NSURL *)fileURL contents:(NSData *)contents attributes:(NSDictionary *)attributes;
{
    NSString *filePath = [self path4FileURLInCurrentCacheDirectory:fileURL];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    return [fileManager createFileAtPath:filePath contents:contents attributes:attributes];
}

#pragma mark scheduleBlock
- (void)scheduleBlock:(dispatch_block_t)block
{
	dispatch_async(_taskQueue, ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		block();
		
		[pool drain];
	});
}

#pragma mark-
- (BOOL)setCacheDirectory:(NSString *)directoryName
{
    if (directoryName) {
        NSString *currentCacheDirectoryName = [[NSUserDefaults standardUserDefaults] objectForKey:CurrentCacheDirectoryName];
        
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSArray *cacheDirectories =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *localCacheDirectory = [cacheDirectories objectAtIndex:0];
        NSString *theCacheDirectoryPath = [localCacheDirectory stringByAppendingPathComponent:directoryName];
        
        _cacheDirectory = [directoryName copy];
        [[NSUserDefaults standardUserDefaults] setObject:directoryName forKey:CurrentCacheDirectoryName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([fileManager fileExistsAtPath:theCacheDirectoryPath]) {
            return YES;
        }else{
            if (!currentCacheDirectoryName) {
                [self removeCacheDirectory:currentCacheDirectoryName];
            }
            return [self createCacheDirectory:directoryName];
        }
    }
    return NO;
}

- (NSString *)currentCacheDirectory
{
    return [_cacheDirectory copy];
}

- (void)clearAllCaches
{
    [self removeCacheDirectory:_cacheDirectory];
    [self createCacheDirectory:_cacheDirectory];
}

- (BOOL)hasCachedImage:(NSURL *)imageURL
{
    NSString *filePath = [self path4FileURLInCurrentCacheDirectory:imageURL];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (NSData *)dataOfCachedImage:(NSURL *)imageURL
{
    NSString *filePath = [self path4FileURLInCurrentCacheDirectory:imageURL];
    NSData *cachedData = nil;
    if ([self hasCachedImage:imageURL]) {
        cachedData = [NSData dataWithContentsOfFile:filePath];
    }
    return cachedData;
}

- (void)addImageCachedTask:(NSURL *)imageURL
{
    [self scheduleBlock:^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        //用于判断获取的是不是正确的image文件数据
        UIImage *img = [UIImage imageWithData:imageData];
        if (img) {
            [self createFileInCurrentCacheDirectory:imageURL contents:imageData attributes:nil];
        }
    }];
}

- (void)addImageCachedTask:(NSURL *)imageURL withFinishedHandler:(void(^)(NSURL *imageURL))finishedHandler
{
    [self scheduleBlock:^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        //用于判断获取的是不是正确的image文件数据
        UIImage *img = [UIImage imageWithData:imageData];
        if (img) {
            [self createFileInCurrentCacheDirectory:imageURL contents:imageData attributes:nil];
            if (finishedHandler) {
                dispatch_async(dispatch_get_main_queue(),^{
                    ((void(^)(NSURL *imageURL))finishedHandler)(imageURL);
                });
            }
        }
    }];
}
@end
