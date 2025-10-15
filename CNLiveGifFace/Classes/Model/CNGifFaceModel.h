//
//  CNGifFaceModel.h
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/1/26.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNGifFaceModel : NSObject
@property (nonatomic, copy) NSString *sectionId;
@property (nonatomic, copy) NSString *coverPic;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *isDownload;

@end

NS_ASSUME_NONNULL_END
