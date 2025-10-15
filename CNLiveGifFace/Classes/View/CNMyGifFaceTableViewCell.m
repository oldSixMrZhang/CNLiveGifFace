//
//  CNMyGifFaceTableViewCell.m
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/2/18.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import "CNMyGifFaceTableViewCell.h"

#import "CNGifFaceModel.h"
#import "CNLiveDownLoadManager.h"
#import "CNLiveArchiveManager.h"
#import "UIColor+CNLiveExtension.h"
#import "CNFaceThemeModel.h"
#import "Masonry.h"
#import "MJExtension.h"
#import "CNUserInfoManager.h"
#import "CNLiveDefinesHeader.h"
#import <QMUIKit/QMUIKit.h>

@interface CNMyGifFaceTableViewCell()
@property (nonatomic, strong) UIImageView *leftImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *removeBtn;
@property (nonatomic, strong) UIView *line;

@end
@implementation CNMyGifFaceTableViewCell
static const NSInteger margin = 10;

#pragma mark - Init
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setupUI];
        
    }
    return self;
}
#pragma mark - Data
- (void)setGroupName:(NSString *)groupName{
    _groupName = groupName;
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/Download/%@",CNUserShareModelUid,groupName]];
    
    //设置图片
    NSString *image = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_left0",groupName]];
    _leftImage.image = [UIImage imageNamed:image];
    
    //设置标题
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",groupName]]];
    if(data){
        // 对数据进行JSON格式化并返回字典形式
        NSDictionary *faceDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        CNFaceThemeModel *themeModel = [CNFaceThemeModel mj_objectWithKeyValues:faceDic];
        _titleLabel.text = themeModel.themeName;
    }
    
}
#pragma mark - UI
- (void)setupUI{
    [self.contentView addSubview:self.leftImage];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.removeBtn];
    
    [self.contentView addSubview:self.line];
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [_leftImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(margin);
        make.left.equalTo(self.contentView.mas_left).with.offset(margin);
        make.width.offset(30*RATIO);
        make.height.offset(40*RATIO);

    }];
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_leftImage.mas_centerY);
        make.left.equalTo(_leftImage.mas_right).with.offset(margin);
        make.height.offset(30*RATIO);
        
    }];
    
    [_removeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-margin);
        make.centerY.equalTo(_leftImage.mas_centerY);
        make.height.offset(30*RATIO);
        make.width.offset(60*RATIO);
        
    }];
    
    [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-0);
        make.right.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_right).with.offset(margin);
        make.height.offset(0.5);
        
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
#pragma mark - Private Methods

#pragma mark - Action
- (void)clickRemoveBtn:(UIButton *)btn{
    [QMUITips showLoading:@"移除中..." inView:[UIApplication sharedApplication].delegate.window];
    
    //1先删除plist文件
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath1 = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/%@",CNUserShareModelUid,@"GifFaceList.plist"]];
    ///var/mobile/Containers/Data/Application/94E0C70B-9F4D-4716-8EAF-7BF0C53AEAEE/Documents/10514405/GifFace/GifFaceList.plist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result1 = [fileManager fileExistsAtPath:filePath1];
    
    if(result1){
        //读取已存在的表情包列表
        NSMutableArray *data = [NSMutableArray arrayWithContentsOfFile:filePath1];
        [data removeObject:_groupName];
        if([data writeToFile:filePath1 atomically:YES]){
            NSLog(@"删除plist文件的数据并写入成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GifFaceDownLoadSuccess" object:nil];

        }
        
    }
    //2然后删除文件夹中的表情包
    NSString *filePath2 = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/Download/%@",CNUserShareModelUid,_groupName]];
    BOOL result2 = [fileManager fileExistsAtPath:filePath2];
    if(result2){
        //读取已存在的表情包列表
        if([fileManager removeItemAtPath:filePath2 error:nil]){
            NSLog(@"删除表情包的数据成功");

        }

    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshGifFaceTableView:)]) {
        [self.delegate refreshGifFaceTableView:self];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveGifFacePackageSuccess" object:nil userInfo:@{@"sectionId":_groupName}];
    }
    [QMUITips hideAllTipsInView:[UIApplication sharedApplication].delegate.window];
//    QMUITips *tips = [QMUITips showSucceed:@"移除成功" inView:AppKeyWindow hideAfterDelay:1];
//    tips.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];

}
#pragma mark - Lazy loading
- (UIImageView *)leftImage{
    if (!_leftImage) {
        _leftImage = [[UIImageView alloc] init];
        _leftImage.userInteractionEnabled = YES;
//        _leftImage.contentMode = UIViewContentModeScaleAspectFill;
//        _leftImage.layer.masksToBounds = YES;
    }
    return _leftImage;
}
- (UILabel *)titleLabel{
    if(_titleLabel == nil){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = UIFontCNMake(17);
        _titleLabel.userInteractionEnabled = YES;
        
    }
    return _titleLabel;
    
}

- (UIButton *)removeBtn{
    if(_removeBtn == nil){
        _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _removeBtn.titleLabel.font = UIFontCNMake(14);
        _removeBtn.backgroundColor = CNLiveColorWithHexString(@"FAFAFA");
        _removeBtn.layer.cornerRadius = 15*RATIO;
        _removeBtn.layer.masksToBounds = YES;
        _removeBtn.layer.borderColor = CNLiveColorWithHexString(@"C6C6C6").CGColor;
        _removeBtn.layer.borderWidth = 1;
        [_removeBtn addTarget:self action:@selector(clickRemoveBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [_removeBtn setTitle:@"移除" forState:UIControlStateNormal];
        [_removeBtn setTitleColor:CNLiveColorWithHexString(@"999999") forState:UIControlStateNormal];
        
    }
    return _removeBtn;
    
}

- (UIView *)line{
    if(_line == nil){
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    }
    return _line;
}

@end
