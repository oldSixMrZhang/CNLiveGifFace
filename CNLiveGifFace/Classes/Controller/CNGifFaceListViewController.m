//
//  CNGifFaceListViewController.m
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/1/26.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import "CNGifFaceListViewController.h"
#import "CNMyGifFaceViewController.h"
#import "CNGifFaceListHeaderView.h"
#import "CNGifFaceListTableViewCell.h"
#import "CNGifFaceModel.h"
#import "CNLiveDownLoadManager.h"
#import "CNLiveArchiveManager.h"
#import <AFNetworking/AFNetworking.h>
//#import "CNUserAgreementRequst.h"
//#import "CNReportAndComplaintWebController.h"
#import "UIColor+CNLiveExtension.h"
//#import "CNNavigationController.h"
#import <QMUIKit/QMUIKit.h>
#import "CNUserInfoManager.h"
#import "CNLiveDefinesHeader.h"

@interface CNGifFaceListViewController ()<UITableViewDelegate, UITableViewDataSource, CNGifFaceListTableViewCellDelegate>{
    BOOL _isDownload;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *datas;
//@property (nonatomic, weak) UIImageView *logo;

@property (nonatomic, weak) UILabel *author;
@property (nonatomic, weak) YYLabel *version;

@end

@implementation CNGifFaceListViewController
#pragma mark - Data
- (void)loadData{
    NSDictionary *params = @{@"appId":AppId,
                             @"plat":@"i",
                             @"sid":[UserInformationModel manager].uid};
    [CNLiveNetworking setAllowRequestDefaultArgument:YES];
    [QMUITips showLoadingInView:AppKeyWindow];
    [CNLiveNetworking requestNetworkWithMethod:CNLiveRequestMethodPOST URLString:CNGifFaceShopListUrl Param:params CacheType:CNLiveNetworkCacheTypeCacheNetwork CompletionBlock:^(NSURLSessionTask *requestTask, id responseObject, NSError *error) {
        [QMUITips hideAllTipsInView:AppKeyWindow];
        [self hideEmptyView];
        if (error) {
            if (self.data.count == 0) {
                if (error.code == -1001) {
                    [self showEmptyViewWithImage:[UIImage imageNamed:@"dd_wlcw"] text:@"无法连接网络" detailText:@"别紧张，试试看刷新页面~" buttonTitle:@"     重试     " buttonAction:@selector(loadData)];
                    [self setCNAPIErrorEmptyView];
                }else{
                    [self showEmptyViewWithImage:[UIImage imageNamed:@"wufalianjie"] text:@"接口请求错误" detailText:@"别紧张，试试看刷新页面~" buttonTitle:@"     重试     " buttonAction:@selector(loadData)];
                    [self setCNAPIErrorEmptyView];
                }
            }
            return;
        }
        self.data = [CNGifFaceModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"sections"]];
        [self checkForDownload];
        [self.tableView reloadData];
        if (self.data.count == 0) {//显示empty
            [self showEmptyViewWithImage:[UIImage imageNamed:@"zhuangtai_kong"] text:@"您现在没有相关内容哦" detailText:@"" buttonTitle:@"" buttonAction:nil];
            [self setCNNoDataEmptyView];
            self.tableView.tableFooterView = nil;
        }
    }];

}
//检查是否下载
- (void)checkForDownload{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/%@",[UserInformationModel manager].uid,@"GifFaceList.plist"]];
    ///var/mobile/Containers/Data/Application/94E0C70B-9F4D-4716-8EAF-7BF0C53AEAEE/Documents/10514405/GifFace/GifFaceList.plist
    BOOL result = [fileManager fileExistsAtPath:filePath];
    if(result){
        //读取已存在的表情包列表
        NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:filePath];
        if(arr.count > 0){
            [arr enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.data enumerateObjectsUsingBlock:^(CNGifFaceModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([str isEqualToString:model.sectionId]){
                        model.isDownload = @"1";
                        *stop = YES;
                    }
                }];
            }];
        }
    }
}

//未下载完成,继续下载
- (void)continueToDownload{
    _isDownload = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/%@",[UserInformationModel manager].uid,@"GifFaceNotList.plist"]];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    if(result){
        self.datas = [NSMutableArray arrayWithContentsOfFile:filePath];
    }
    if(_datas.count > 0){
        for(NSString *url in self.datas){
            [self clickedAddBtn:url];
        }
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isDownload = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:@"RemoveGifFacePackageSuccess" object:nil];
    [self loadData];
    [self createUI];
    
    //网络监听
    [self listenNetwork];

}
- (void)dealloc{
    NSLog(@"CNGifFaceListViewController -- dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (void)refreshTableView:(NSNotification *)infoNotification{
    NSDictionary *dic = [infoNotification userInfo];
    NSString *sectionId = [dic objectForKey:@"sectionId"];
    [self.data enumerateObjectsUsingBlock:^(CNGifFaceModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if([sectionId isEqualToString:model.sectionId]){
            model.isDownload = @"0";
            *stop = YES;
        }
    }];
    [self.tableView reloadData];
    
}
#pragma mark - UI
- (void)createUI {
    self.title = @"表情管理";
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 30, 44);
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    closeButton.titleLabel.font = UIFontCNMake(16*KScreenWidth/375.0);
    [closeButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingButton.frame = CGRectMake(0, 0, 30, 44);
    [settingButton setImage:[UIImage imageNamed:@"xx_liaotianshezhi"] forState:UIControlStateNormal];
    [settingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.view addSubview:self.tableView];

//    UIImageView *logo = [[UIImageView alloc]init];
//    logo.image = [UIImage imageNamed:@"gif_logo_version"];
//    [self.view addSubview:logo];
//    _logo = logo;
    UILabel *author = [[UILabel alloc] init];
    author.textAlignment = NSTextAlignmentCenter;
    author.font = UIFontMake(12*KScreenWidth/375.0);
    author.textColor = CNLiveColorWithHexString(@"9F9F9F");
    author.text = @"Copyright © 网家家";
    [self.view addSubview:author];
    _author = author;

    YYLabel *version = [[YYLabel alloc] init];
    version.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"服务声明    侵权投诉"];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;//对齐方式
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    
    text.color = CNLiveColorWithHexString(@"23D41E");
    text.font = UIFontMake(12*KScreenWidth/375.0);
    [version sizeToFit];
    
    MJWeakSelf
    [text setTextHighlightRange:NSMakeRange(0, 4) color:CNLiveColorWithHexString(@"23D41E") backgroundColor:kClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        CNUserAgreementRequst *requst = [[CNUserAgreementRequst alloc] init];
        [requst getAgreementH5WithType:CNAgreementEmojiService success:^(NSString *h5, NSString *title) {
            CNReportAndComplaintWebController *webVC = [[CNReportAndComplaintWebController alloc] initWithUrl:h5 webType:CNFeedbackWebType pageTitle:title];
            CNNavigationController *nav = [[CNNavigationController alloc] initWithRootViewController:webVC];
            [weakSelf presentViewController:nav animated:NO completion:NULL];
            
        } failure:^(NSError *error) {
            [QMUITips showError:error.localizedDescription inView:self.view hideAfterDelay:1.5];
        }];
        
    }];
    
    [text setTextHighlightRange:NSMakeRange(text.length-4, 4) color:CNLiveColorWithHexString(@"23D41E") backgroundColor:kClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        CNUserAgreementRequst *requst = [[CNUserAgreementRequst alloc] init];
        [requst getAgreementH5WithType:CNAgreementEmojiComplaints success:^(NSString *h5, NSString *title) {
            CNReportAndComplaintWebController *webVC = [[CNReportAndComplaintWebController alloc] initWithUrl:h5 webType:CNFeedbackWebType pageTitle:title];
            CNNavigationController *nav = [[CNNavigationController alloc] initWithRootViewController:webVC];
            [weakSelf presentViewController:nav animated:NO completion:NULL];
            
        } failure:^(NSError *error) {
            [QMUITips showError:error.localizedDescription inView:weakSelf.view hideAfterDelay:1.5];
            
        }];
        
    }];
    version.attributedText = text;
    [self.view addSubview:version];
    _version = version;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(kNavigationBarHeight);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        
    }];
    [_version mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-(kVerticalBottomSafeHeight+10));
        make.left.right.bottom.equalTo(self.view);
        make.height.offset(18);
        
    }];
    [_author mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_version.mas_top).offset(-5);
        make.centerX.equalTo(self.view);
        make.height.offset(30);
        make.width.offset(200);
        
    }];
//    [_logo mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(_version.mas_top).offset(-5);
//        make.centerX.equalTo(self.view);
//        make.height.offset(30);
//        make.width.offset(80);
//
//    }];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CNGifFaceListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCNGifFaceListTableViewCell forIndexPath:indexPath];
    cell.model = self.data[indexPath.row];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20+60*RATIO;
    
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
    header.text = @"推荐表情";
    header.textColor = @"000000";
    header.backgroundColor = @"FFFFFF";
    header.textSize = 17;
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
- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)settingButtonClicked{
    CNMyGifFaceViewController *vc = [[CNMyGifFaceViewController alloc]init];
    [[AppDelegate sharedAppDelegate] pushViewController:vc withBackTitle:@"返回"];

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
        [_tableView registerClass:[CNGifFaceListTableViewCell class] forCellReuseIdentifier:kCNGifFaceListTableViewCell];
        [_tableView registerClass:[CNGifFaceListHeaderView class] forHeaderFooterViewReuseIdentifier:kCNGifFaceListHeaderView];
        
    }
    return _tableView;
}

- (NSMutableArray *)data{
    if (!_data) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

- (NSMutableArray *)datas{
    if (!_datas) {
        _datas = [[NSMutableArray alloc] init];
    
    }
    return _datas;
}

#pragma mark - 下载
- (void)clickedAddBtn:(NSString *)url{

    [self createGifFaceNotList:url];
    
    if(![[CNLiveDownLoadManager sharedInstance].downloads containsObject:url]){
        [[CNLiveDownLoadManager sharedInstance].downloads addObject:url];

    }
    
    if(!_isDownload){
        _isDownload = YES;
        [self download:url];

    }
}

#pragma mark - Private Methods
//网络监听
- (void)listenNetwork {
    __weak typeof(self) weakSelf = self;
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        weakSelf.netStatus = status;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"4G网络");
                [weakSelf continueToDownload];
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi网络");
                [weakSelf continueToDownload];
                
                break;
            default:
                break;
        }
    }];
    [manager startMonitoring];
}
- (void)createGifFaceNotList:(NSString *)url{
    //创建文件管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/%@",[UserInformationModel manager].uid,@"GifFaceNotList.plist"]];
    ///var/mobile/Containers/Data/Application/94E0C70B-9F4D-4716-8EAF-7BF0C53AEAEE/Documents/10514405/GifFace/GifFaceList.plist
    BOOL result = [fileManager fileExistsAtPath:filePath];
    if(result){
        //读取已存在的表情包未下载列表
        NSMutableArray *data = [NSMutableArray arrayWithContentsOfFile:filePath];
        if([data containsObject:url]){//存在
            
        }else{//不存在
            [data addObject:url];
        }
        if([data writeToFile:filePath atomically:YES]){
            
        }
        
    }else{
        //不存在的表情包未下载列表
        NSMutableArray *data = [NSMutableArray array];
        [data addObject:url];
        if([data writeToFile:filePath atomically:YES]){
        }
    }
}
//下载
- (void)download:(NSString *)downloadUrl{
    MJWeakSelf
    [[CNLiveDownLoadManager sharedInstance] downLoadWithURL:downloadUrl progress:^(NSString *url, float progress) {
        [weakSelf.data enumerateObjectsUsingBlock:^(CNGifFaceModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model.downloadUrl isEqualToString:downloadUrl]) {
                // 主线程更新cell进度
                dispatch_async(dispatch_get_main_queue(), ^{
                    CNGifFaceListTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    cell.addBtn.hidden = YES;
                    cell.processView.hidden = NO;
                    [cell.processView setProgress:progress];
                    if(progress >= 1.0f){
                        [cell refreshCell];
                    }
                });
                
                *stop = YES;
            }
        }];
        
    } success:^(NSString *url, NSString *fileStorePath) {
        ///var/mobile/Containers/Data/Application/27248574-1177-4075-B200-7E8B2D052FB5/Library/Caches/0e3a18a25dcf490bfcab448fc362e82e
        //下载结束储存地址
        NSLog(@"fileStorePath----%@",fileStorePath);
        
        [weakSelf releaseZip:fileStorePath downloadUrl:downloadUrl];
        
        _isDownload = NO;
        NSMutableArray *data = [CNLiveDownLoadManager sharedInstance].downloads;
        if(data.count > 0){
            [data removeObjectAtIndex:0];
            
        }
        if(data.count > 0 && !_isDownload){
            _isDownload = YES;
            [weakSelf download:data[0]];
            
        }
        
    } faile:^(NSString *url, NSError *error) {
        _isDownload = NO;
        NSMutableArray *data = [CNLiveDownLoadManager sharedInstance].downloads;
        if(data.count > 0){
            [data removeObjectAtIndex:0];
            
        }
        if(data.count > 0 && !_isDownload){
            _isDownload = YES;
            [weakSelf download:data[0]];
            
        }
    }];
    
}

//解压
- (void)releaseZip:(NSString *)fileStorePath downloadUrl:(NSString *)downloadUrl{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    [CNLiveArchiveManager sharedInstance].cachesPath = [path stringByAppendingPathComponent:[UserInformationModel manager].uid];
    
    //下载
    ///var/mobile/Containers/Data/Application/1DFB750A-35BE-4FE0-9CDC-E0DB6E84F7FB/Documents/10514405/GifFace/DownLoad
    
    //缓存
    ///var/mobile/Containers/Data/Application/1DFB750A-35BE-4FE0-9CDC-E0DB6E84F7FB/Documents/10514405/GifFace/Cache
    
    ///var/mobile/Containers/Data/Application/94E0C70B-9F4D-4716-8EAF-7BF0C53AEAEE/Documents/10514405/GifFace/GifFaceList.plist
    
    [[CNLiveArchiveManager sharedInstance]releaseZipWithLocalPath:fileStorePath folderName:@"GifFace/Download" releaseZipFolderName:[[downloadUrl lastPathComponent] stringByDeletingPathExtension] resultBlock:^(NSString *hostPath, NSArray *array) {
        //解压结束储存地址
        NSLog(@"hostPath----%@",hostPath);
        
        //下载成功删除点断续传的已下载长度
        NSString *totalLengthPlist = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"totalLength.plist"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:totalLengthPlist];
        [dict removeObjectForKey:downloadUrl.md5String];
        [dict writeToFile:totalLengthPlist atomically:YES];
        
        //创建文件管理
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

        //下载成功删除表情压缩包
        [fileManager removeItemAtPath:fileStorePath error:nil];
        
        //下载成功删除url
        NSString *filePathNot = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/%@",[UserInformationModel manager].uid,@"GifFaceNotList.plist"]];
        NSMutableArray *data = [NSMutableArray arrayWithContentsOfFile:filePathNot];
        [data removeObject:downloadUrl];
        [data writeToFile:filePathNot atomically:YES];

        //下载成功添加本地已下载列表
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/%@",[UserInformationModel manager].uid,@"GifFaceList.plist"]];
        
        ///var/mobile/Containers/Data/Application/94E0C70B-9F4D-4716-8EAF-7BF0C53AEAEE/Documents/10514405/GifFace/GifFaceList.plist
        BOOL result = [fileManager fileExistsAtPath:filePath];
        if(result){
            //读取已存在的表情包列表
            NSMutableArray *data = [NSMutableArray arrayWithContentsOfFile:filePath];
            NSString *str = [[downloadUrl lastPathComponent] stringByDeletingPathExtension];
            if([data containsObject:str]){//存在
                return ;
            }else{//不存在
                [data addObject:str];
            }
            if([data writeToFile:filePath atomically:YES]){
                NSLog(@"写入成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GifFaceDownLoadSuccess" object:nil];
            }
            
        }else{
            //不存在的表情包列表
            NSMutableArray *data = [NSMutableArray array];
            [data addObject:[[downloadUrl lastPathComponent] stringByDeletingPathExtension]];
            if([data writeToFile:filePath atomically:YES]){
                NSLog(@"写入成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GifFaceDownLoadSuccess" object:nil];
            }
        }
        
    }];
}

@end
