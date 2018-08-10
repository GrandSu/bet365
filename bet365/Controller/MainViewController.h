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
@property (nonatomic, strong) NSString *currentUrl;

@end
