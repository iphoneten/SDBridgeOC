//
//  WebViewController.m
//  JavascriptBridgeOC
//
//  Created by Office-2060 on 2022/3/22.
//

#import "WebViewController.h"
#import "WebViewJavascriptBridge.h"
@interface WebViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;

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
    [self.webView loadFileURL:filePath allowingReadAccessToURL:filePath];
}

- (void)setupNav {
    self.title = @"WebViewController";
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSDictionary *data = @{@"iOSKey": @"iOSValue"};
    [self.bridge callHandler:@"GetToken" data: data responseCallback:^(id  _Nonnull responseData) {
        NSLog(@"%@",responseData);

    }];
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
