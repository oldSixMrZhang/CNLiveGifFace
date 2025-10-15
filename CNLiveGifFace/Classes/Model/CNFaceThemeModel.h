//
//  CNFaceThemeModel.h
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2018/10/15.
//  Copyright © 2018年 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, FaceThemeStyle)
{
    FaceThemeStyleSystemEmoji,       //30*30
    FaceThemeStyleCustomEmoji,       //40*40
    FaceThemeStyleGif                //60*60
};

@interface CNFaceModel : NSObject

/** 表情图片 */
@property (nonatomic, copy)   NSString *themeId;//主题id
@property (nonatomic, copy)   NSString *faceId;//表情id
@property (nonatomic, copy)   NSString *faceName;//表情名字
@property (nonatomic, copy)   NSString *faceDesc;//表情描述

@property (nonatomic, copy)   NSString *faceGifUrl;//表情gif url
@property (nonatomic, copy)   NSString *facePngUrl;//表情png url

@property (nonatomic, copy)   NSString *faceIconGif;//表情gif 本地
@property (nonatomic, copy)   NSString *faceIconPng;//表情png 本地

@property (nonatomic, copy)   NSString *faceProgress;
@property (nonatomic, copy)   NSString *type;
@property (nonatomic, assign) FaceThemeStyle themeStyle;

@end

/** 表情标题 */
@interface CNFaceThemeModel : NSObject
@property (nonatomic, copy)   NSString *themeId;
@property (nonatomic, copy)   NSString *themeIcon;
@property (nonatomic, copy)   NSString *themeName;
@property (nonatomic, copy)   NSString *themeDesc;
@property (nonatomic, copy)   NSString *themeAuther;
@property (nonatomic, copy)   NSString *downLoadUrl;
@property (nonatomic, copy)   NSString *number;
@property (nonatomic, strong) NSArray  *faceModels;
@property (nonatomic, assign) FaceThemeStyle themeStyle;


@end

NS_ASSUME_NONNULL_END
