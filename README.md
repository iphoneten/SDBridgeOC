![](Resource/SDBridgeOC.png)
[![language](https://img.shields.io/badge/Language-ObjectiveC-green)];
[![License MIT](https://img.shields.io/badge/license-MIT-FC89CD.svg?style=flat)](https://github.com/SDBridge/SDBridgeOC/blob/master/JavascriptBridgeOC/LICENSE)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%209%2B%20-FB7DEC.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![CocoaPods](https://img.shields.io/badge/pod-v1.0.1-green)](http://cocoapods.org/pods/SDBridgeOC)


### Installation with CocoaPods
Add this to your [podfile](https://guides.cocoapods.org/using/getting-started.html) and run `pod install` to install:

```ruby
pod 'SDBridgeOC', '~> 1.0.1'
```
If you can't find the last version, maybe you need to update local pod repo.
```ruby
pod repo update
```

### Manual installation
Drag the `Classes` folder into your project.

In the dialog that appears, uncheck "Copy items into destination group's folder" and select "Create groups for any folders".

Usage
-----
1) Import the header file and declare an ivar property:

```objc
#import "WebViewJavascriptBridge.h"
```
```objc
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;
```

```objc
- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    WKWebViewConfiguration * webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    CGRect frame = CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 100);
    self.webView = [[WKWebView alloc] initWithFrame:frame configuration:webViewConfiguration];
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView] ;
    
    // This can get javascript console.log
    self.bridge.consolePipeBlock = ^(id  _Nonnull water) {
        NSLog(@"Next line is javascript console.log------>>>>");
        NSLog(@"%@",water);
    };
    // This register for javascript call
    [self.bridge registerHandler:@"DeviceLoadJavascriptSuccess" handler:^(id  _Nonnull data, WVJBResponseCallback  _Nonnull responseCallback) {
        NSDictionary *response = @{@"result": @"iOS"};
        responseCallback(response);
    }];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"Demo" ofType:@"html"];
    NSURL *filePath = [NSURL fileURLWithPath:htmlPath];
    // Loading html in local 
    [self.webView loadFileURL:filePath allowingReadAccessToURL:filePath];
}
```

2) Register a handler in ObjC, and call a JS handler:

```objc
 - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSDictionary *data = @{@"iOSKey": @"iOSValue"};
    [self.bridge callHandler:@"GetToken" data: data responseCallback:^(id  _Nonnull responseData) {
        NSLog(@"%@",responseData);
    }];
}
```
3) In javascript file or html file like :
	
```javascript
<script>
    console.log("1111111111111");
    const bridge = window.WebViewJavascriptBridge;
    // JS尝试调用原生方法，用来判断自身是否被原生加载成功,并且让自己知道自己使用者是在安卓的App中还是在iOS的App中
    bridge.callHandler('DeviceLoadJavascriptSuccess', {key: 'JSValue'}, function(response) {
    let result = response.result
    if (result === "iOS") {
    console.log("Javascript was loaded by IOS and successfully loaded.");
    window.iOSLoadJSSuccess = true;
} else if (result === "Android") {
    console.log("Javascript was loaded by Android and successfully loaded.");
    window.AndroidLoadJSSuccess = true;
}
})
    // JS注册方法让原生来调用
    bridge.registerHandler('GetToken', function(data, responseCallback) {
    console.log(data);
    let result = {token: "I am javascript's token"}
    //JS拿到数据，返回给原生
    responseCallback(result)
})
</script>
```
That all. Thanks for read.
