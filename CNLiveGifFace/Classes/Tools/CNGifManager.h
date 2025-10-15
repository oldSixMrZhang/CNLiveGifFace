//
//  CNGifManager.h
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/2/26.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <CoreServices/CoreServices.h>
#import <WebKit/WebKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CNGifManager : NSObject
/**
 *  将本地视频转换成Gif图
 *
 *  @param videoURL          本地视频的url 使用系统 + (NSURL *)fileURLWithPath:(NSString *)path;将本地path转url
 *  @param frameCount        一共切多少张
 *  @param delayTime         每一张几秒钟显示
 *  @param loopCount         是否循环
 *  @param isNeedCompression 是否需要压缩
 *  @param compressionWidth  压缩尺寸 宽
 *  @param compressionHeight 压缩尺寸 高
 *  @param fileName         生成gif 的文件名
 *  @param completionBlock   成功回调 会返回 gif tmp文件下本地路径
 */
+ (void)makingGIFWithURL:(NSURL*)videoURL frameCount:(int)frameCount delayTime:(float)delayTime loopCount:(int)loopCount needCompression:(BOOL)isNeedCompression compressionWidth:(float)compressionWidth compressionHeight:(float)compressionHeight fileName:(NSString*)fileName completion:(void(^)(NSString *GifPath))completionBlock;


//设置
//demo 中video.mp4 为18s 视频 希望gif 帧数位8， 所以 FrameCount ＝ 18 ＊ 8 ; delayTime ＝ 1/8;

//位置
///var/mobile/Containers/Data/Application/3EAE8373-82FF-49C0-A700-89C73303E4D7/Documents/123456/GifFace/DownLoad/Personal/1551168120065.gif
+ (void)makingGIFWithURL:(NSURL*)videoURL frameCount:(int)frameCount delayTime:(float)delayTime loopCount:(int)loopCount needCompression:(BOOL)isNeedCompression compressionWidth:(float)compressionWidth compressionHeight:(float)compressionHeight completion:(void(^)(NSString *GifPath))completionBlock;


@end

NS_ASSUME_NONNULL_END
