//
//  CNLiveArchiveManager.h
//  Net++
//
//  Created by CNLive-zxw on 2018/9/1.
//  Copyright © 2018年 CNLive-zxw. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ManagerResultBlock

 @param hostPath 数组的文件夹路径
 @param array 图片数组
 */
typedef void (^ManagerResultBlock)(NSString *hostPath, NSArray *array);

@interface CNLiveArchiveManager : NSObject

@property (nonatomic, strong) NSString *cachesPath;
@property (nonatomic, strong) NSString *cachesFolderNamePath;

@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, copy) ManagerResultBlock resultBlock;

+ (instancetype)sharedInstance;

/**
 解压缩
 
 @param urlString 需要解压缩文件的本地路径
 @param folderName 解压缩完毕,文件存放的文件夹名
 */
- (void)releaseZipWithLocalPath:(NSString *)urlString folderName:(NSString *)folderName resultBlock:(ManagerResultBlock)resultBlock;
//cachesPath+folderName 就是解压缩完毕文件夹路径(cachesFolderNamePath)
- (void)releaseZipWithLocalPath:(NSString *)urlString folderName:(NSString *)folderName releaseZipFolderName:(NSString *)releaseZipFolderName resultBlock:(ManagerResultBlock)resultBlock;

- (NSArray *)getPicsWithFolderName:(NSString *)folderName;

@end
