//
//  CNChatGifDetailsViewController.m
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2018/10/22.
//  Copyright © 2018年 cnlive. All rights reserved.
//

#import "CNChatGifDetailsViewController.h"
#import "CNAttentionViewController.h"
#import "CNGifFaceAlbumViewController.h"
#import "CNLiveDownLoadManager.h"
#import "CNLiveArchiveManager.h"
#import "UIColor+CNLiveExtension.h"
#import "CNMessageForwardingController.h"
#import "CNGifFaceModel.h"

#import "CNLiveDefinesHeader.h"
#import <QMUIKit/QMUIKit.h>
#import <CNLiveRequestBastKit/CNLiveNetworking.h>
#import <YYKit/YYKit.h>

@interface CNChatGifDetailsViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) YYAnimatedImageView *webImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIImageView *coverImage;
@property (nonatomic, strong) UILabel *coverTitle;
@property (nonatomic, strong) UIButton *coverBtn;
@property (nonatomic, strong) UIProgressView *processView;


@property (nonatomic, strong) CNGifFaceModel *model;

@end

@implementation CNChatGifDetailsViewController
static const NSInteger margin = 10;
static const NSInteger ImageWidthHeight = 60;

#pragma mark - Data
//显示底部专辑
- (void)getData{
    TIMCustomElem *elem = (TIMCustomElem *)[self.msg.msg getElem:0];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:elem.data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSString *sectionId = dic[@"gifEmojiData"][@"groupId"];
    if (!sectionId || [sectionId isEqualToString:@""]) {
        _bottomView.hidden = YES;
        return;
    }
    NSDictionary *params = @{@"sectionId":sectionId};
    [CNLiveNetworking setAllowRequestDefaultArgument:YES];
    [CNLiveNetworking requestNetworkWithMethod:CNLiveRequestMethodPOST URLString:CNGetGifFacePackageUrl Param:params CacheType:CNLiveNetworkCacheTypeNetworkOnly CompletionBlock:^(NSURLSessionTask *requestTask, id responseObject, NSError *error) {
        if (!error) {
            self.model = [CNGifFaceModel mj_objectWithKeyValues:responseObject[@"data"][@"section"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_coverImage sd_setImageWithURL:[NSURL URLWithString:_model.coverPic] completed:nil];
                _coverTitle.text = _model.title;
                
            });

        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //底部图片
                [_coverImage sd_setImageWithURL:[NSURL URLWithString:self.url] completed:nil];
                _bottomView.hidden = YES;
            });
            
        }
        
    }];
    
}
//已下载  ->   已缓存  ->  下载
- (void)showGifFaceData {
    //表情名字
    TIMCustomElem *elem = (TIMCustomElem *)[self.msg.msg getElem:0];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:elem.data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (dic[@"gifEmojiData"][@"faceName"]) {
        _nameLabel.text = dic[@"gifEmojiData"][@"faceName"];
        
    }
    
    //表情GIF
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *names = [dic[@"gifEmojiData"][@"faceId"] componentsSeparatedByString:@"_"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(names.count >= 2){
        NSString *filePath1 = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/Download/%@/gif/%@.gif",[UserInformationModel manager].uid,names[0],dic[@"gifEmojiData"][@"faceId"]]];

        BOOL isDownoad = [fileManager fileExistsAtPath:filePath1];
        _coverBtn.selected = isDownoad;
        _coverBtn.layer.borderColor = isDownoad? CNLiveColorWithHexString(@"D9D9D9").CGColor:CNLiveColorWithHexString(@"23D41E").CGColor;
        _coverBtn.userInteractionEnabled = !isDownoad;
        
        //本地存在 已下载
        if(isDownoad){
            NSData *imageData = [NSData dataWithContentsOfFile:filePath1];
            _webImageView.image = [YYImage imageWithData:imageData];
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            return;
            
        }
    }
    
    NSString *filePath2 = [[CNTools newChatGifFacePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",dic[@"gifEmojiData"][@"faceId"]]];
    BOOL isCahce = [fileManager fileExistsAtPath:filePath2];
    //本地存在 已缓存
    if(isCahce){
        NSData *imageData = [NSData dataWithContentsOfFile:filePath2];
        _webImageView.image = [YYImage imageWithData:imageData];
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        return;
        
    }
    
    //本地不存在
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    __block CNChatGifDetailsViewController *blockSelf = self;
    
    [self.webImageView setImageWithURL:dic[@"gifEmojiData"][@"faceGifUrl"] placeholder:nil options:YYWebImageOptionProgressiveBlur|YYWebImageOptionShowNetworkActivity  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (receivedSize > 0 && expectedSize > 0) {
            CGFloat progress = (CGFloat)receivedSize / expectedSize;
            NSLog(@"-----fff%.2f",progress);

        }
        
    } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (stage == YYWebImageStageFinished) {
            [blockSelf.activityIndicator stopAnimating];
            blockSelf.activityIndicator.hidden = YES;
            for (UIGestureRecognizer *ges in blockSelf.webImageView.gestureRecognizers) {
                ges.delegate = blockSelf;
            }
            
        }
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //底部专辑数据
    [self getData];

    //导航栏
    [self createNavigationBar];
    //UI
    [self createUI];

    //GIF表情数据
    [self showGifFaceData];
    
    // Do any additional setup after loading the view.
}

#pragma mark - UI
- (void)createNavigationBar{
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"xx_liaotianshezhi"] style:UIBarButtonItemStylePlain target:self action:@selector(moreButton:)];
    self.navigationItem.rightBarButtonItem = rightBtn;

}

//改变导航栏颜色
- (UIImage *)navigationBarBackgroundImage{
    return [UIImage imageWithColor:kWeChatBgColor];
}
- (void)createUI{
    [self.view addSubview:self.webImageView];
    [self.webImageView addSubview:self.activityIndicator];
    [self.view addSubview:self.nameLabel];

    [self.view addSubview:self.bottomView];

    [self.bottomView addSubview:self.line];
    [self.bottomView addSubview:self.coverImage];
    [self.bottomView addSubview:self.coverTitle];
    [self.bottomView addSubview:self.coverBtn];
    [self.bottomView addSubview:self.processView];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods
//下载
- (void)download:(NSString *)downloadUrl{
//    NSString *downloadUrl = @"https://wjj.ys1.cnliveimg.com/769/emoticon/archive/section0.zip";
    NSLog(@"%@",downloadUrl);
    [[CNLiveDownLoadManager sharedInstance] downLoadWithURL:downloadUrl progress:^(NSString *url, float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // UI更新代码
            [_processView setProgress:progress animated:YES];
            
        });
        
    } success:^(NSString *url, NSString *fileStorePath) {
        ///var/mobile/Containers/Data/Application/27248574-1177-4075-B200-7E8B2D052FB5/Library/Caches/0e3a18a25dcf490bfcab448fc362e82e
        //下载结束储存地址
        NSLog(@"fileStorePath----%@",fileStorePath);
        [self releaseZip:fileStorePath];
        [self refreshUI];
        
    } faile:^(NSString *url, NSError *error) {
        
    }];
}
//解压
- (void)releaseZip:(NSString *)fileStorePath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    [CNLiveArchiveManager sharedInstance].cachesPath = [path stringByAppendingPathComponent:[UserInformationModel manager].uid];
    
    //下载
    ///var/mobile/Containers/Data/Application/1DFB750A-35BE-4FE0-9CDC-E0DB6E84F7FB/Documents/10514405/GifFace/DownLoad
    
    //缓存
    ///var/mobile/Containers/Data/Application/1DFB750A-35BE-4FE0-9CDC-E0DB6E84F7FB/Documents/10514405/GifFace/Cache
    
    //GIF本地管理plist
    ///var/mobile/Containers/Data/Application/94E0C70B-9F4D-4716-8EAF-7BF0C53AEAEE/Documents/10514405/GifFace/GifFaceList.plist
    
    [[CNLiveArchiveManager sharedInstance]releaseZipWithLocalPath:fileStorePath folderName:@"GifFace/Download" releaseZipFolderName:[[self.model.downloadUrl lastPathComponent] stringByDeletingPathExtension] resultBlock:^(NSString *hostPath, NSArray *array) {
        
        NSString *totalLengthPlist = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"totalLength.plist"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:totalLengthPlist];
        [dict removeObjectForKey:self.model.downloadUrl.md5String];
        [dict writeToFile:totalLengthPlist atomically:YES];
        
        //解压结束储存地址
        NSLog(@"hostPath----%@",hostPath);
        
        //创建文件
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/GifFace/%@",[UserInformationModel manager].uid,@"GifFaceList.plist"]];
        ///var/mobile/Containers/Data/Application/94E0C70B-9F4D-4716-8EAF-7BF0C53AEAEE/Documents/10514405/GifFace/GifFaceList.plist
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //移除下载表情包
        [fileManager removeItemAtPath:fileStorePath error:nil];
        
        BOOL result = [fileManager fileExistsAtPath:filePath];
        if(result){
            //读取已存在的表情包列表
            NSMutableArray *data = [NSMutableArray arrayWithContentsOfFile:filePath];
            NSString *str = [[self.model.downloadUrl lastPathComponent] stringByDeletingPathExtension];
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
            [data addObject:[[self.model.downloadUrl lastPathComponent] stringByDeletingPathExtension]];
            if([data writeToFile:filePath atomically:YES]){
                NSLog(@"写入成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GifFaceDownLoadSuccess" object:nil];
            }
        }
        
    }];
}
- (void)refreshUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        // UI更新代码
        _processView.hidden = YES;
        _coverBtn.hidden = NO;
        
        _coverBtn.selected = YES;
        _coverBtn.layer.borderColor = CNLiveColorWithHexString(@"D9D9D9").CGColor;
        _coverBtn.userInteractionEnabled = NO;
        
    });
}
#pragma mark - Methods
- (void)moreButton:(UIButton *)btn{
    [self.view createAlertViewTitleArray:@[@"发送给朋友"] textColor:UIColorMake(11, 190, 6) font:[UIFont systemFontOfSize:18] actionBlock:^(UIButton *button, NSInteger didRow) {
        if(didRow == 0){
            CNMessageForwardingController *vc= [[CNMessageForwardingController alloc] init];
            vc.msgsArray = @[self.msg];
            vc.conversation = self.conversation;
            vc.chatVc = self.chatVc;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];
    
}
- (void)clickAddBtn:(UIButton *)btn{
    if(!_coverBtn.selected){
        _processView.hidden = NO;
        _coverBtn.hidden = YES;
        //下载
        [self download:self.model.downloadUrl];
    }
    
}
- (void)bottomViewTap:(UITapGestureRecognizer *)tap{
    CNGifFaceAlbumViewController *vc = [[CNGifFaceAlbumViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Getter and Setter
- (YYAnimatedImageView *)webImageView{
    if (!_webImageView) {
        _webImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        _webImageView.centerX = self.view.centerX;
        _webImageView.centerY = self.view.centerY-15;
        _webImageView.contentMode = UIViewContentModeScaleToFill;
        _webImageView.clipsToBounds = YES;
        _webImageView.backgroundColor = [UIColor clearColor];
        
    }
    return _webImageView;
}
- (UILabel *)nameLabel{
    if(_nameLabel == nil){
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _webImageView.bottom, kMainScreenWidth, 30)];
        _nameLabel.centerX = self.view.centerX;
        _nameLabel.textColor = CNLiveColorWithHexString(@"888888");
        _nameLabel.font = UIFontCNMake(16);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.userInteractionEnabled = YES;
        
    }
    return _nameLabel;
    
}
- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        //设置小菊花颜色
        _activityIndicator.color = [UIColor lightGrayColor];
        //设置背景颜色
        _activityIndicator.backgroundColor = [UIColor clearColor];
        _activityIndicator.frame= CGRectMake(0, 0, 100, 100);
        _activityIndicator.center = self.view.center;

    }
    return _activityIndicator;
}
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kMainScreenHeight-ImageWidthHeight-kVerticalBottomSafeHeight, kMainScreenWidth, ImageWidthHeight)];
        _bottomView.backgroundColor = [UIColor whiteColor];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bottomViewTap:)];
//        [_bottomView addGestureRecognizer:tap];
    }
    return _bottomView;
}
- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 0.5)];
        _line.backgroundColor = CNLiveColorWithHexString(@"D9D9D9");

    }
    return _line;
}
- (UIImageView *)coverImage{
    if (!_coverImage) {
        _coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(margin, _line.bottom+margin, (ImageWidthHeight-2*margin)*3/4.0, ImageWidthHeight-2*margin)];
        _coverImage.contentMode = UIViewContentModeScaleToFill;
        _coverImage.clipsToBounds = YES;

    }
    return _coverImage;
}
- (UIButton *)coverBtn{
    if(_coverBtn == nil){
        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverBtn.frame = CGRectMake(kMainScreenWidth-2*margin-60, _line.bottom+(_bottomView.height-25)/2.0, 60, 25);
        _coverBtn.titleLabel.font = UIFontCNMake(13);
        _coverBtn.layer.cornerRadius = 5;
        _coverBtn.layer.masksToBounds = YES;
        _coverBtn.layer.borderWidth = 1;
        [_coverBtn addTarget:self action:@selector(clickAddBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [_coverBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_coverBtn setTitleColor:CNLiveColorWithHexString(@"23D41E") forState:UIControlStateNormal];
        _coverBtn.layer.borderColor = CNLiveColorWithHexString(@"23D41E").CGColor;
        
        [_coverBtn setTitle:@"已添加" forState:UIControlStateSelected];
        [_coverBtn setTitleColor:CNLiveColorWithHexString(@"D9D9D9") forState:UIControlStateSelected];
        
        
    }
    return _coverBtn;
    
}
- (UILabel *)coverTitle{
    if (!_coverTitle) {
        _coverTitle = [[UILabel alloc]initWithFrame:CGRectMake(_coverImage.right+margin, _coverImage.top, kMainScreenWidth-3*margin-_coverImage.right-_coverBtn.width, _coverImage.height)];
        _coverTitle.font = UIFontCNMake(16);
        _coverTitle.textColor = [UIColor blackColor];
    }
    return _coverTitle;
}
- (UIProgressView *)processView{
    if(_processView == nil){
        _processView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _processView.frame = CGRectMake(0, 0, 60, 10);
        _processView.center = _coverBtn.center;
        _processView.trackTintColor = CNLiveColorWithHexString(@"D9D9D9");
        _processView.progressTintColor = CNLiveColorWithHexString(@"23D41E");
        _processView.hidden = YES;
    }
    return _processView;
}

@end
