//
//  MainViewController.m
//  bet365
//
//  Created by bet001 on 2018/8/10.
//  Copyright © 2018年 Bet365. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

#pragma mark - ControllerLoadLife
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    [self setUIFrameWithMasonry];
    
    [self setSVProgressConfiguration];
    [self webViewLoadRequest];
    if (@available(iOS 10.0, *)) {
        self.view.backgroundColor = [UIColor colorWithDisplayP3Red:55/255.0 green:125/255.0 blue:97/255.0 alpha:1.0f];
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:55/255.0 green:125/255.0 blue:97/255.0 alpha:1.0f];
    }
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

/** KVO监听 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setAlpha:1.0f];  //0.10000000000000001起
        
        NSString *kk = @"%";
        NSLog(@"已加载：%.f%@", self.webView.estimatedProgress * 100, kk);
        
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
                
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
}

/** 设置SVProgress的配置 */
- (void)setSVProgressConfiguration {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack]; // 整个后面的背景选择
    [SVProgressHUD setFont:[UIFont systemFontOfSize:18]]; // 字体
    [SVProgressHUD setMinimumDismissTimeInterval:1.f];  // 显示的最短时间
}

#pragma mark - WKNavigationDelegate
/** 当webView加载完成时调用 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"结束加载");
    [SVProgressHUD dismiss];
}

/** webView加载失败时调用 (【web视图加载内容时】发生错误) */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
}

/** 在发送请求之前，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (navigationAction.targetFrame == nil) {
        NSLog(@"----------------终于调用我了-------------------");
        [webView loadRequest:navigationAction.request];
    }
    
    // ------  对scheme:相关的scheme处理 -------
    // 若遇到微信、支付宝、QQ支付等相关scheme，则跳转到本地App
    NSString *scheme = navigationAction.request.URL.scheme;
    
    // 判断scheme是否是 http或者https，并返回BOOL的值
    BOOL urlOpen = [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"about"];
    
    if (!urlOpen) {
        // 跳转相关客户端
        BOOL bSucc = [[UIApplication sharedApplication]openURL:navigationAction.request.URL];
        
        // 如果跳转失败，则弹窗提示客户
        if (!bSucc) {
            // 设置弹窗
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到该客户端，请您安装后重试。" preferredStyle:UIAlertControllerStyleAlert];
            // 确定按键不带点击事件
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    // 确认可以跳转，必须实现该方法，不实现会报错
    decisionHandler(WKNavigationActionPolicyAllow);
}

/** 证书验证处理 https 可以自签名 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        // 如果没有错误的情况下，创建一个凭证，并使用证书
        if (challenge.previousFailureCount == 0) {
            //创建一个凭证，并使用证书
            NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }else {
            //验证失败，取消本次验证
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }else {
        //验证失败，取消本次验证
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark - WKUIDelegate
/** 创建新的webView（打开新窗口） */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    /** 创建新的wenview窗口有点浪费资源，直接在原有窗口进行加载即可 */
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame] || frameInfo == nil) {
        [SVProgressHUD showWithStatus:@"加载中..."];
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

/** 以下三个代理都是与界面弹出提示框相关，分别针对web界面的三种提示框（警告框、确认框、输入框）的代理，如果不实现网页的alert函数无效 */
/** 警告框 【显示 JavaScript 弹窗alert】 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    // 初始化 alertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    // 添加 action 按键
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    // 弹出一个新视图 可以带动画效果，完成后可以做相应的执行函数经常为nil
    [self presentViewController:alertController animated:YES completion:nil];
}

/** 选择框 【测试JS代码：confirm（"confirm message"）】 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    // 初始化 alertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    // 添加 action 按键
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    // 弹出一个新视图 可以带动画效果，完成后可以做相应的执行函数经常为nil
    [self presentViewController:alertController animated:YES completion:nil];
}

/** 输入框 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    // 初始化 alertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    // alertController 添加 TextField 输入框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    // 添加 action
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    // 弹出一个新视图 可以带动画效果，完成后可以做相应的执行函数经常为nil
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - WebViewLoadRequest
/** WKWebView 加载 */
- (void)webViewLoadRequestWithUrlStr:(NSString *)urlStr {
    
    NSURL *requestURL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20];
    NSData *dataContent = [NSData dataWithContentsOfURL:requestURL];
    
    NSURLCache *cache = [NSURLCache sharedURLCache];
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:requestURL MIMEType:@"text/html" expectedContentLength:0 textEncodingName:@"UT-8"];
    NSCachedURLResponse *cacheURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:dataContent];
    [cache storeCachedResponse:cacheURLResponse forRequest:request];
    
    [self.webView loadRequest:request];
    
    // 请求的url
    self.currenWeb_Url = urlStr;
    NSLog(@"当前加载：%@", self.currenWeb_Url);
}



/** 加载webView主页的方法 */
- (void)webViewLoadRequest {
    [SVProgressHUD showWithStatus:@"加载中..."];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DefaultLaunchImage.png"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    // 设置网络请求超时时间
    manager.requestSerializer.timeoutInterval = 6.0;
    [manager GET:BaseURL_bet365 parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [UIView animateWithDuration:2 animations:^{
            [bgImageView setAlpha:0];
        }];
        
        
        [SVProgressHUD showWithStatus:@"请稍后..."];
        NSLog(@"加载成功");
        // 转模型 存数据
        WebModel *model = [[WebModel alloc] init];
        [model setValuesForKeysWithDictionary:responseObject];
        [self webViewLoadRequestWithUrlStr:[model.dataUrl firstObject]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [bgImageView setHidden:YES];
        [SVProgressHUD showWithStatus:@"加载备用线路中..."];
        NSLog(@"加载失败");
        [self webViewLoadRequestWithUrlStr:Base_URL];
    }];
}

#pragma mark - Masonry
- (void)setUIFrameWithMasonry {
    
    // 需要在block里面操作，所以先将 self 设为弱指针
    __weak typeof(self)weakSelf = self;
    
    // 添加webView到当前视图上（使用masonry需要先添加到父视图上才可以，不然会崩溃）
    [self.view addSubview:self.webView];
    
    // 设置webView 的 masonry 约束
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        // iOS 11 适配（iPhoneX最低都是iOS 11）
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(weakSelf.view.mas_top).with.offset(20);
        }
        make.bottom.equalTo(weakSelf.view.mas_bottom);
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
    }];
    
    // 设置progress的 masonry 约束 （需要注意的是父视图webview是已经加载并约束完的，不然会报错）
    [self.webView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.webView.mas_top);
        make.width.equalTo(weakSelf.webView.mas_width);
        // 设置高度为3个像素
        make.height.mas_equalTo(@2);
    }];
}

#pragma mark - LazyLoading
- (WKWebView *)webView {
    if (!_webView) {
        
        // 初始化
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 设置偏好设置
        config.preferences = [[WKPreferences alloc] init];
        // 是否支持 JavaScript
        config.preferences.javaScriptEnabled = YES;
        // 设置最小字体大小
        config.preferences.minimumFontSize = 8;
        // 是否可以不通过用户交互打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        // 代理
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        // 支持左滑后退
        _webView.allowsBackForwardNavigationGestures = YES;
        
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = YES;
        _webView.userInteractionEnabled = YES;
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        
        // 未加载进度颜色
        _progressView.trackTintColor = [UIColor clearColor];
        // 加载进度颜色
        _progressView.progressTintColor = [UIColor redColor];
        
        _progressView.progressViewStyle = UIProgressViewStyleBar;
    }
    return _progressView;
}

- (NSMutableArray *)urlMuArray {
    if (!_urlMuArray) {
        _urlMuArray = [[NSMutableArray alloc] init];
    }
    return _urlMuArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//在ViewController销毁时移除KVO观察者，同时清除所有的html缓存
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self clearCache];
}

/** 清理缓存的方法，这个方法会清除缓存类型为HTML类型的文件*/
- (void)clearCache {
    /* 取得Library文件夹的位置*/
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
    /* 取得bundle id，用作文件拼接用*/
    NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
    /*
     * 拼接缓存地址，具体目录为App/Library/Caches/你的APPBundleID/fsCachedData
     */
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
    
    NSError *error;
    /* 取得目录下所有的文件，取得文件数组*/
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:webKitFolderInCachesfs error:&error];
    /* 遍历文件组成的数组*/
    for(NSString * fileName in fileList){
        /* 定位每个文件的位置*/
        NSString * path = [[NSBundle bundleWithPath:webKitFolderInCachesfs] pathForResource:fileName ofType:@""];
        /* 将文件转换为NSData类型的数据*/
        NSData * fileData = [NSData dataWithContentsOfFile:path];
        /* 如果FileData的长度大于2，说明FileData不为空*/
        if(fileData.length >2){
            /* 创建两个用于显示文件类型的变量*/
            int char1 =0;
            int char2 =0;
            
            [fileData getBytes:&char1 range:NSMakeRange(0,1)];
            [fileData getBytes:&char2 range:NSMakeRange(1,1)];
            /* 拼接两个变量*/
            NSString *numStr = [NSString stringWithFormat:@"%i%i",char1,char2];
            /* 如果该文件前四个字符是6033，说明是Html文件，删除掉本地的缓存*/
            if([numStr isEqualToString:@"6033"]){
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",webKitFolderInCachesfs,fileName]error:&error];
                continue;
            }
        }
    }
}

@end
