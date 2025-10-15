//
//  CNChatGifDetailsViewController.h
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2018/10/22.
//  Copyright © 2018年 cnlive. All rights reserved.
//

#import "CNCommonViewController.h"
#import "CNChatViewController.h"
#import "TIMAdapter.h"
#import "CommonLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@interface CNChatGifDetailsViewController : CNCommonViewController
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) IMAMsg *msg;//需要转发的消息
@property (nonatomic, strong) IMAConversation *conversation;
@property (nonatomic, weak) CNChatViewController *chatVc;

@end

NS_ASSUME_NONNULL_END
