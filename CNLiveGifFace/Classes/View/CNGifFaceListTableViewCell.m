//
//  CNGifFaceListTableViewCell.m
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/1/26.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import "CNGifFaceListTableViewCell.h"
#import "CNGifFaceModel.h"
#import "UIColor+CNLiveExtension.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "CNLiveDefinesHeader.h"
#import <QMUIKit/QMUIKit.h>
#import <CNLiveRequestBastKit/CNLiveNetworking.h>

@interface CNGifFaceListTableViewCell()
@property (nonatomic, strong) UIImageView *leftImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *line;

@end
@implementation CNGifFaceListTableViewCell
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
- (void)setModel:(CNGifFaceModel *)model{
    _model = model;
    [_leftImage sd_setImageWithURL:[NSURL URLWithString:model.coverPic] placeholderImage:nil];
    _titleLabel.text = model.title;
    _contentLabel.text = model.desc;
    
    if([model.isDownload isEqualToString:@"1"]){
        //已下载
        _addBtn.selected = YES;
        _addBtn.layer.borderColor = CNLiveColorWithHexString(@"D9D9D9").CGColor;
        _addBtn.userInteractionEnabled = NO;

    }else{
        //未下载
        _addBtn.selected = NO;
        _addBtn.layer.borderColor = CNLiveColorWithHexString(@"23D41E").CGColor;
        _addBtn.userInteractionEnabled = YES;
        [_processView setProgress:0 animated:NO];

    }

}

#pragma mark - UI
- (void)setupUI{
    [self.contentView addSubview:self.leftImage];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.contentLabel];

    [self.contentView addSubview:self.addBtn];
    [self.contentView addSubview:self.line];
    [self.contentView addSubview:self.processView];

}
- (void)layoutSubviews{
    [super layoutSubviews];

    [_leftImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(margin);
        make.left.equalTo(self.contentView.mas_left).with.offset(margin);
        make.width.offset(60*RATIO*3/4.0);
        make.height.offset(60*RATIO);

    }];
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(margin);
        make.left.equalTo(_leftImage.mas_right).with.offset(margin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-(2*margin+60));
        make.height.offset(30*RATIO);
        
    }];
    
    [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).with.offset(0);
        make.left.equalTo(_leftImage.mas_right).with.offset(margin);
        make.right.equalTo(_titleLabel.mas_right);
        make.height.offset(30*RATIO);

    }];
    
    [_addBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-margin);
        make.centerY.equalTo(_leftImage.mas_centerY);
        make.height.offset(30*RATIO);
        make.width.offset(60);
    }];
    
    [_processView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-margin);
        make.centerY.equalTo(_leftImage.mas_centerY);
        make.height.offset(6);
        make.width.offset(60);
    }];
    
    [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-0);
        make.left.equalTo(self.contentView.mas_right).with.offset(margin);
        make.right.equalTo(self.contentView);
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
- (void)refreshCell{
    // UI更新代码
    //        [QMUITips hideAllTipsInView:AppKeyWindow];
    _model.isDownload = @"1";
    _processView.hidden = YES;
    _addBtn.hidden = NO;
    
    _addBtn.selected = YES;
    _addBtn.layer.borderColor = CNLiveColorWithHexString(@"D9D9D9").CGColor;
    _addBtn.userInteractionEnabled = NO;
    
//    QMUITips *tips = [QMUITips showSucceed:@"添加成功" inView:AppKeyWindow hideAfterDelay:1];
//    tips.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    
}
#pragma mark - Action
- (void)clickAddBtn:(UIButton *)btn{
    if(![CNLiveNetworking isNetworking]){
        [QMUITips showWithText:@"无法连接网络" inView:[UIApplication sharedApplication].delegate.window hideAfterDelay:1];
        return ;
    }
    
    _addBtn.hidden = YES;
    _processView.hidden = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickedAddBtn:)]) {
        [self.delegate clickedAddBtn:self.model.downloadUrl];//滑动响应实现
    }

}

#pragma mark - Lazy loading
- (UIImageView *)leftImage{
    if (!_leftImage) {
        _leftImage = [[UIImageView alloc] init];
        _leftImage.userInteractionEnabled = YES;

    }
    return _leftImage;
}
- (UILabel *)titleLabel{
    if(_titleLabel == nil){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = CNLiveColorWithHexString(@"000000");
        _titleLabel.font = UIFontCNMake(17);
        _titleLabel.userInteractionEnabled = YES;

    }
    return _titleLabel;
    
}
- (UILabel *)contentLabel{
    if(_contentLabel == nil){
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = CNLiveColorWithHexString(@"888888");
        _contentLabel.font = UIFontCNMake(13);
        
    }
    return _contentLabel;
    
}
- (UIButton *)addBtn{
    if(_addBtn == nil){
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.titleLabel.font = UIFontCNMake(14);
        _addBtn.layer.cornerRadius = 15*RATIO;
        _addBtn.layer.masksToBounds = YES;
        _addBtn.layer.borderWidth = 1;
        [_addBtn addTarget:self action:@selector(clickAddBtn:) forControlEvents:UIControlEventTouchUpInside];

        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addBtn setTitleColor:CNLiveColorWithHexString(@"23D41E") forState:UIControlStateNormal];
        _addBtn.layer.borderColor = CNLiveColorWithHexString(@"23D41E").CGColor;

        [_addBtn setTitle:@"已添加" forState:UIControlStateSelected];
        [_addBtn setTitleColor:CNLiveColorWithHexString(@"D9D9D9") forState:UIControlStateSelected];

    }
    return _addBtn;
    
}
- (UIProgressView *)processView{
    if(_processView == nil){
        _processView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _processView.trackTintColor = CNLiveColorWithHexString(@"D9D9D9");
        _processView.progressTintColor = CNLiveColorWithHexString(@"23D41E");
        _processView.hidden = YES;
    }
    return _processView;
}
- (UIView *)line{
    if(_line == nil){
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    }
    return _line;
}

@end
