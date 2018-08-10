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
        
        // 初始化
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 是否支持 JavaScript
        config.preferences.javaScriptEnabled = YES;
        // 是否可以不通过用户交互打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        
        _webView = [[WKWebView alloc] initWithFrame:mainWebViewFrame configuration:config];
        
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        // 使用Autoresizing进行横屏适配
        [_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_webView setAutoresizesSubviews:YES];
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
