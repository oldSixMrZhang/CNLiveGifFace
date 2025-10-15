//
//  CNGifFaceListHeaderView.h
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/2/20.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCNGifFaceListHeaderView @"CNGifFaceListHeaderView"

NS_ASSUME_NONNULL_BEGIN

@interface CNGifFaceListHeaderView : UITableViewHeaderFooterView
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *textColor;
@property (nonatomic, copy) NSString *backgroundColor;
@property (nonatomic, assign) NSInteger textSize;
@property (nonatomic, assign) BOOL isHidden;

@end

NS_ASSUME_NONNULL_END
