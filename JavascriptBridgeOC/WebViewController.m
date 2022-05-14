//
//  WebViewController.m
//  JavascriptBridgeOC
//
//  Created by 1 on 2022/3/22.
//

#import "WebViewController.h"
#import "WebViewJavascriptBridge.h"
@interface WebViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;
@property (nonatomic, strong) UIButton *callSyncBtn;
@property (nonatomic, strong) UIButton *callAsyncBtn;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupNav];
    // Do any additional setup after loading the view.
}

- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"WebViewController enter");
    WKWebViewConfiguration * webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    // Allow cross domain
    [webViewConfiguration setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
    CGRect frame = CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 100);
    self.webView = [[WKWebView alloc] initWithFrame:frame configuration:webViewConfiguration];
    self.webView.navigationDelegate = self;
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView] ;
    self.bridge.consolePipeBlock = ^(id  _Nonnull water) {
        NSLog(@"Next line is javascript console.log------>>>>");
        NSLog(@"%@",water);
    };
    [self.bridge registerHandler:@"DeviceLoadJavascriptSuccess" handler:^(id  _Nonnull data, WVJBResponseCallback  _Nonnull responseCallback) {
        NSDictionary *response = @{@"result": @"iOS"};
        responseCallback(response);
    }];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"Demo" ofType:@"html"];
    NSURL *filePath = [NSURL fileURLWithPath:htmlPath];
    // Loading html in local ，This way maybe meet cross domain. So You should not forget to set
    // [webViewConfiguration setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
    // If you loading remote web server,That can be ignored.
    [self.webView loadFileURL:filePath allowingReadAccessToURL:filePath];
    [self.view addSubview:self.callSyncBtn];
    [self.view addSubview:self.callAsyncBtn];

}

- (void)setupNav {
    self.title = @"WebViewController";
}
- (void)callSyncFunction {
    NSDictionary *data = @{@"iOSKey": @"iOSValue"};
    [self.bridge callHandler:@"GetToken" data: data responseCallback:^(id  _Nonnull responseData) {
        NSLog(@"%@",responseData);

    }];
}

- (void)callAsyncFunction {
    NSDictionary *data = @{@"iOSKey": @"iOSValue"};
    [self.bridge callHandler:@"AsyncCall" data: data responseCallback:^(id  _Nonnull responseData) {
        NSLog(@"%@",responseData);
    }];
}

- (UIButton *)callSyncBtn {
    if (!_callSyncBtn) {
        _callSyncBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _callSyncBtn.frame = CGRectMake(40, [UIScreen mainScreen].bounds.size.height - 100, 150, 40);
        [_callSyncBtn setTitle:@"callSyncBtn" forState:UIControlStateNormal];
        _callSyncBtn.layer.masksToBounds = YES;
        _callSyncBtn.layer.cornerRadius = 6;
        _callSyncBtn.backgroundColor = [UIColor brownColor];
        [_callSyncBtn addTarget:self action:@selector(callSyncFunction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callSyncBtn;
}
- (UIButton *)callAsyncBtn {
    if (!_callAsyncBtn) {
        _callAsyncBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _callAsyncBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 200, [UIScreen mainScreen].bounds.size.height - 100, 150, 40);
        [_callAsyncBtn setTitle:@"callAsyncBtn" forState:UIControlStateNormal];
        _callAsyncBtn.layer.masksToBounds = YES;
        _callAsyncBtn.layer.cornerRadius = 6;
        _callAsyncBtn.backgroundColor = [UIColor brownColor];
        [_callAsyncBtn addTarget:self action:@selector(callAsyncFunction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callAsyncBtn;
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)dealloc {
    NSLog(@"WebViewController dealloc");
}
@end
