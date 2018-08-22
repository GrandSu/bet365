//
//  MainViewController.h
//  bet365
//
//  Created by bet001 on 2018/8/10.
//  Copyright © 2018年 Bet365. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <WKUIDelegate, WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *currenWeb_Url;
@property (nonatomic, strong) NSMutableArray *urlMuArray;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIView *bgView;

- (void)viewDidLoad;
/** KVO监听 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;
/** 设置SVProgress的配置 */
- (void)setSVProgressConfiguration;

#pragma mark - WKNavigationDelegate
/** 当webView加载完成时调用 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
/** webView加载失败时调用 (【web视图加载内容时】发生错误) */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;
/** 在发送请求之前，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
/** 证书验证处理 https 可以自签名 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;

#pragma mark - WKUIDelegate
/** 创建新的webView（打开新窗口） */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;
/** 以下三个代理都是与界面弹出提示框相关，分别针对web界面的三种提示框（警告框、确认框、输入框）的代理，如果不实现网页的alert函数无效 */
/** 警告框 【显示 JavaScript 弹窗alert】 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
/** 选择框 【测试JS代码：confirm（"confirm message"）】 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler;
/** 输入框 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler;


#pragma mark - WebViewLoadRequest
/** WKWebView 加载 */
- (void)webViewLoadRequestWithUrlStr:(NSString *)urlStr;
/** 加载webView主页的方法 */
- (void)webViewLoadRequest;

#pragma mark - Masonry
- (void)setUIFrameWithMasonry;

#pragma mark - LazyLoading
- (WKWebView *)webView;
- (UIProgressView *)progressView;
- (NSMutableArray *)urlMuArray;

@end
