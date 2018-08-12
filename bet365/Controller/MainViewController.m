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

- (WKWebView *)webView {
    if (!_webView) {
        
        NSLog(@"初始化wkwebview");
        
        // 初始化
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 是否支持 JavaScript
        config.preferences.javaScriptEnabled = YES;
        // 是否可以不通过用户交互打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        
        
        
        _webView = [[WKWebView alloc] initWithFrame:mainWebViewFrame configuration:config];
        
        // 代理
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        // 支持左滑后退
        _webView.allowsBackForwardNavigationGestures = YES;
        
        // 使用Autoresizing进行横屏适配
        [_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_webView setAutoresizesSubviews:YES];
        
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (NSMutableArray *)urlMuArray {
    if (!_urlMuArray) {
        _urlMuArray = [[NSMutableArray alloc] init];
    }
    return _urlMuArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"webTitle:%@", self.webView.title);
    if (!self.webView.title) {
        [self.webView reload];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self webViewLoadRequestWithUrl:Base_URL];
    
}

#pragma mark - WKNavigationDelegate
/** 页面开始加载webView内容时调用 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载webView内容");
}

/** 当webView内容开始返回时调用 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"webView内容开始返回");
}

/** 当webView加载完成时调用 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"webView加载完成");
}

/** webView加载失败时调用 (【web视图加载内容时】发生错误) */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"webView加载失败");
}

/** webView导航过程中发生错误时调用 */
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"webView导航加载错误");
    NSLog(@"Error:%@", error);
}

/** 当webView内容进程终止时调用 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"webView终止加载内容");
}

/** 在发送请求之前，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    NSLog(@"发送请求前,决定是否跳转");
    NSLog(@"发送请求前加载：%@/n", [navigationAction.request valueForKey:@"URL"]);
    
    // 确认可以跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}

/** 在收到响应后，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
//    NSLog(@"在收到响应后，决定是否跳转");
    NSLog(@"在收到响应后加载：%@/n", navigationResponse.response.URL);
    
    // 确认可以跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/** 收到服务器重定向之后调用（接收到服务器跳转请求）*/
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
//    NSLog(@"接收到服务器跳转请求");
    NSLog(@"接收到服务器跳转请求:%@/n", webView.URL);
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
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    NSLog(@"创建了一个新的窗口！！！！");
    return nil;
}

/** 关闭webView */
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"关闭webView");
}

/** 以下三个代理都是与界面弹出提示框相关，分别针对web界面的三种提示框（警告框、确认框、输入框）的代理，如果不实现网页的alert函数无效 */
/** 警告框 【显示 JavaScript 弹窗alert】 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    NSLog(@"警告框");
    
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
    
    NSLog(@"选择框");
    
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
    
    NSLog(@"输入框");
    
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


#pragma mark - LoadDataWithURL
/** WKWebView 加载 */
- (void)webViewLoadRequestWithUrl:(NSString *)urlStr {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:request];
    
    NSLog(@"URL:%@", url);
    NSLog(@"URL:%@", request.URL);
    NSLog(@"URL:%@", self.webView.URL);
    
    // 请求的url
    self.baseWeb_Url = urlStr;
    NSLog(@"当前加载：%@", self.baseWeb_Url);
}

- (void)loadUrlData {
    
    NSURL * url = [NSURL URLWithString:BseeUrl_bet36];
    
    NSString * data = [NSString stringWithContentsOfURL:url encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) error:nil];
    NSLog(@"%@", data);
    if (data == nil) {
        NSLog(@"下载服务器列表失败");
    }else {
        NSLog(@"下载服务器列表成功");
        NSArray * dataArr = [data componentsSeparatedByString:@","];
        [self testHost:dataArr];
    }
}

/** 检查更新*/
- (void)testHost:(NSArray *)testHostArr {
    // 测试配置文件上的主机名
    
    NSLog(@"检查服务器");
    [self.urlMuArray removeAllObjects];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_queue_t dispatchQueue = dispatch_queue_create("TestHost", DISPATCH_QUEUE_CONCURRENT);
    for (NSString * host in testHostArr) {
        
        // 并发执行并行队列
        dispatch_group_async(dispatchGroup, dispatchQueue, ^{
            
            // 测试
            NSURL *testHost = [NSURL URLWithString:host];
            
            NSString * test = [NSString stringWithContentsOfURL:testHost encoding:NSUTF8StringEncoding error:nil];
            
            NSLog(@"host:%@", host);
            NSLog(@"testHost:%@", testHost);
//            NSLog(@"test:%@", test);
            
            if (test) {
                [self.urlMuArray addObject:host];
            }
            
        });
    }
    NSLog(@"运行到这里了");
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        NSLog(@"检查服务器成功");
        NSLog(@"已更新%lu个服务器/n %@", (unsigned long)self.urlMuArray.count, self.urlMuArray);
        // 更新服务器通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"TESTHOST" object:nil userInfo:@{@"testhost":self.urlMuArray}];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
