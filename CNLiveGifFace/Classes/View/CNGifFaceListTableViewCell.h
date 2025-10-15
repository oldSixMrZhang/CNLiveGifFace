//
//  CNGifFaceListTableViewCell.h
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/1/26.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCNGifFaceListTableViewCell @"CNGifFaceListTableViewCell"

NS_ASSUME_NONNULL_BEGIN
@class CNGifFaceModel;
@class CNGifFaceListTableViewCell;

@protocol CNGifFaceListTableViewCellDelegate<NSObject>
- (void)clickedAddBtn:(NSString *)url;

@end

@interface CNGifFaceListTableViewCell : UITableViewCell
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIProgressView *processView;
@property (nonatomic, strong) CNGifFaceModel *model;
@property (nonatomic, weak) id<CNGifFaceListTableViewCellDelegate> delegate;
- (void)refreshCell;

@end

NS_ASSUME_NONNULL_END
