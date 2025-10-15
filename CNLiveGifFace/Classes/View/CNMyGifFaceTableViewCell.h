//
//  CNMyGifFaceTableViewCell.h
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/2/18.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCNMyGifFaceTableViewCell @"CNMyGifFaceTableViewCell"

NS_ASSUME_NONNULL_BEGIN
@class CNMyGifFaceTableViewCell;

@protocol CNMyGifFaceTableViewCellDelegate<NSObject>
- (void)refreshGifFaceTableView:(CNMyGifFaceTableViewCell *)cell;

@end

@interface CNMyGifFaceTableViewCell : UITableViewCell
@property (nonatomic, weak) id<CNMyGifFaceTableViewCellDelegate> delegate;
@property (nonatomic, copy) NSString *groupName;

@end

NS_ASSUME_NONNULL_END
