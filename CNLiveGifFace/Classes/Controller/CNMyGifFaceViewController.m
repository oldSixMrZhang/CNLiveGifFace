//
//  CNMyGifFaceViewController.m
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/2/18.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import "CNMyGifFaceViewController.h"
#import "CNGifFaceListHeaderView.h"
#import "CNMyGifFaceTableViewCell.h"
#import "CNGifFaceModel.h"
#import "Masonry.h"
#import "MJExtension.h"
#import "CNLiveDefinesHeader.h"
#import "CNUserInfoManager.h"

@interface CNMyGifFaceViewController ()<UITableViewDelegate,UITableViewDataSource,CNMyGifFaceTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation CNMyGifFaceViewController
#pragma mark - Data
- (void)reloadDatas{
    dispatch_async(dispatch_get_main_queue(), ^{
        _data = nil;
        [self.tableView reloadData];
        
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDatas) name:@"GifFaceDownLoadSuccess" object:nil];

    [self createUI];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GifFaceDownLoadSuccess" object:nil];

}

#pragma mark - UI
- (void)createUI {
    self.title = @"我的表情";
    [self.view addSubview:self.tableView];
    
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(kNavigationBarHeight);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        
    }];
    
}
#pragma mark - CNMyGifFaceTableViewCellDelegate
- (void)refreshGifFaceTableView:(CNMyGifFaceTableViewCell *)cell{
    if(self.data.count > 0){
        [self.data removeObject:cell.groupName];
        [self.tableView reloadData];
    }
  
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CNMyGifFaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCNMyGifFaceTableViewCell forIndexPath:indexPath];
    cell.groupName = self.data[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20+40*RATIO;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;  // 注意要设置为0.1，不能设置为0
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45*RATIO;  // 注意要设置为0.1，不能设置为0
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CNGifFaceListHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kCNGifFaceListHeaderView];
    header.text = @"聊天面板中的整套表情";
    header.textColor = @"999999";
    header.backgroundColor = @"F2F2F2";
    header.textSize = 14;
    return header;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Action
- (void)clickedVersionBtn:(UIButton *)btn{
    
}

#pragma mark - Lazy loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = RGB(242, 242, 242);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        [_tableView registerClass:[CNMyGifFaceTableViewCell class] forCellReuseIdentifier:kCNMyGifFaceTableViewCell];
        [_tableView registerClass:[CNGifFaceListHeaderView class] forHeaderFooterViewReuseIdentifier:kCNGifFaceListHeaderView];

    }
    return _tableView;
}

- (NSMutableArray *)data{
    if (!_data) {
        _data = [[NSMutableArray alloc] init];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/%@",CNUserShareModelUid,@"GifFaceList.plist"]];
        ///var/mobile/Containers/Data/Application/94E0C70B-9F4D-4716-8EAF-7BF0C53AEAEE/Documents/10514405/GifFace/GifFaceList.plist
        BOOL result = [fileManager fileExistsAtPath:filePath];
        if(result){
            //读取已存在的表情包列表
            _data = [NSMutableArray arrayWithContentsOfFile:filePath];
        }
    }
    return _data;
}

@end
