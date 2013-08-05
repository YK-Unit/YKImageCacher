//
//  YKImageCacher.h
//  YKImageCacherDemo
//
//  Created by zhang zhiyu on 13-8-2.
//  Copyright (c) 2013年 York. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YKImageCacher : NSObject
{
    @private
    NSString *_cacheDirectory;

    dispatch_queue_t _taskQueue;
}

+ (YKImageCacher *)sharedCacher;

- (BOOL)setCacheDirectory:(NSString *)directoryName;

- (NSString *)currentCacheDirectory;

- (void)clearAllCaches;

- (BOOL)hasCachedImage:(NSURL *)imageURL;

- (NSData *)dataOfCachedImage:(NSURL *)imageURL;

- (void)addImageCachedTask:(NSURL *)imageURL;

- (void)addImageCachedTask:(NSURL *)imageURL withFinishedHandler:(void(^)(NSURL *imageURL))finishedHandler;

@end
