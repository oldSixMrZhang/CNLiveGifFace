//
//  CNLiveArchiveManager.m
//  Net++
//
//  Created by CNLive-zxw on 2018/9/1.
//  Copyright © 2018年 CNLive-zxw. All rights reserved.
//

#import "CNLiveArchiveManager.h"
#import "SSZipArchive.h"

typedef void (^ManagerStringBlock)(NSString *string);
@interface CNLiveArchiveManager()<SSZipArchiveDelegate>

@end
@implementation CNLiveArchiveManager
static CNLiveArchiveManager *_instance = nil;

/* 单例控制器 */
+ (instancetype)sharedInstance {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        
//        self->_cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        self->_cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

//        self->_cachesFolderNamePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        self->_cachesFolderNamePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

        self->_fileManager = [NSFileManager defaultManager];
        
    });
    return _instance;
}


#pragma mark - 公开方法
#pragma mark - 从本地路径获取对应文件

- (void)releaseZipWithLocalPath:(NSString *)urlString folderName:(NSString *)folderName resultBlock:(ManagerResultBlock)resultBlock
{
    self.resultBlock = resultBlock;
    __weak __typeof(self)weakSelf = self;
    
    _cachesFolderNamePath = [_cachesPath stringByAppendingPathComponent:folderName];
    
    // 文件夹路径
    NSString *folderPath = [_cachesPath stringByAppendingPathComponent:folderName];

    if ([self directoryExists:folderPath]) {
        // 存在文件夹则之间返回
        if (self.resultBlock) {
            self.resultBlock(folderPath, [self fileList:folderPath]);
        }
        
    }else{
        // 不存在文件夹则创建、解压
        
        if ([weakSelf createFolderWithPath:folderPath]) {
            [weakSelf releaseZipFiles:urlString unzipPath:folderPath];
            
        }else{
            // 创建文件夹失败
            NSLog(@"创建文件夹失败");
        }
        
    }
    
}

- (void)releaseZipWithLocalPath:(NSString *)urlString folderName:(NSString *)folderName releaseZipFolderName:(NSString *)releaseZipFolderName resultBlock:(ManagerResultBlock)resultBlock{
    
    self.resultBlock = resultBlock;
    __weak __typeof(self)weakSelf = self;
    
    _cachesFolderNamePath = [_cachesPath stringByAppendingPathComponent:folderName];
    
    // 文件夹路径
    NSString *folderPath = [_cachesPath stringByAppendingPathComponent:folderName];
    NSString *existsFolderPath = [folderPath stringByAppendingPathComponent:releaseZipFolderName];

    if ([self directoryExists:existsFolderPath]) {
        // 存在文件夹则之间返回
        if (self.resultBlock) {
            self.resultBlock(folderPath, [self fileList:folderPath]);
        }
        
    }else{
        // 不存在文件夹则创建、解压
        
        if ([weakSelf createFolderWithPath:folderPath]) {
            [weakSelf releaseZipFiles:urlString unzipPath:folderPath];
            
        }else{
            // 创建文件夹失败
            NSLog(@"创建文件夹失败");
        }
        
    }
}


#pragma mark - 获取指定文件夹名字的内容
- (NSArray *)getPicsWithFolderName:(NSString *)folderName{
    
    _cachesFolderNamePath = [_cachesPath stringByAppendingPathComponent:folderName];
    
    NSString *folderPath = [_cachesPath stringByAppendingPathComponent:folderName];
    
    if ([self directoryExists:folderPath]) {
        // 存在文件夹则之间返回
        return [self fileList:folderPath];

    }
    NSLog(@"创建文件夹不存在");

    return nil;
}

#pragma mark - 文件处理
#pragma mark - 检测目录文件夹是否存在
/**
 检测目录文件夹是否存在
 
 @param directoryPath 目录路径
 @return 是否存在
 */
- (BOOL)directoryExists:(NSString *)directoryPath
{
    BOOL isDir = NO;
    BOOL isDirExist = [_fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if (isDir && isDirExist) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 获取文件夹下所有文件列表。
- (NSArray *)fileList:(NSString *)directoryPath
{
    return [[_fileManager contentsOfDirectoryAtPath:directoryPath error:nil] mutableCopy];
}

#pragma mark - 创建文件夹。下载完文件，文件需要解压到这个文件夹
- (BOOL)createFolderWithPath:(NSString *)folderPath
{
    // 在路径下创建文件夹
    return [_fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
}

#pragma mark - SSZipArchive
#pragma mark - 解压
- (void)releaseZipFiles:(NSString *)zipPath unzipPath:(NSString *)unzipPath{
    if ([SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath delegate:self]) {
        
    }else {
        NSLog(@"解压失败");
    }
}

#pragma mark - SSZipArchiveDelegate
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    // 解压会出现多余的文件夹__MACOSX，删除掉吧
    NSString *invalidFolder = [unzippedPath stringByAppendingPathComponent:@"__MACOSX"];
    [_fileManager removeItemAtPath:invalidFolder error:nil];
    /*
     // 或者过滤数组，只取所需要的png文件名
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @".png"];
     NSArray *reslutFilteredArray = [fileList filteredArrayUsingPredicate:predicate];
     */
    NSArray *fileList = [self fileList:unzippedPath];
    if (self.resultBlock) {
        self.resultBlock(unzippedPath, fileList);
    }
}

@end
