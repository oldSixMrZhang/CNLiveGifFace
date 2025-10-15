//
//  CNLiveDownLoadManager.h
//  DownLoadManager
//
//  Created by CNLive-zxw on 2018/9/11.
//  Copyright © 2018年 CNLive-zxw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^successBlock) (NSString *url, NSString *fileStorePath);
typedef void (^faileBlock) (NSString *url, NSError *error);
typedef void (^progressBlock) (NSString *url, float progress);

@interface CNLiveDownLoadManager : NSObject <NSURLSessionDataDelegate>
//@property (nonatomic, assign) BOOL isDownload;
@property (nonatomic, strong) NSMutableArray *downloads;

@property (nonatomic, copy) successBlock  successBlock;
@property (nonatomic, copy) faileBlock    failedBlock;
@property (nonatomic, copy) progressBlock progressBlock;

//@property (nonatomic, copy) NSString *cachesPath;

+ (instancetype)sharedInstance;

- (void)downLoadWithURL:(NSString *)URL progress:(progressBlock)progressBlock success:(successBlock)successBlock faile:(faileBlock)faileBlock;

- (void)stopTask;

@end
