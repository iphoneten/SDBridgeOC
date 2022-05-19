![](Resource/SDBridgeOC.png)
![language](https://img.shields.io/badge/Language-ObjectiveC-green)
![language](https://img.shields.io/badge/support-Javascript/Async/Await-green)
[![Support](https://img.shields.io/badge/support-iOS%209%2B%20-FB7DEC.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![CocoaPods](https://img.shields.io/badge/pod-v1.0.4-green)](http://cocoapods.org/pods/SDBridgeOC)

[SDBridgeSwift](https://github.com/SDBridge/SDBridgeSwift) is [here](https://github.com/SDBridge/SDBridgeSwift).

If your h5 partner confused about how to deal with iOS and Android.
[This Demo maybe help](https://github.com/SDBridge/TypeScriptDemo).

### Installation with CocoaPods
Add this to your [podfile](https://guides.cocoapods.org/using/getting-started.html) and run `pod install` to install:

```ruby
pod 'SDBridgeOC', '~> 1.0.4'
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
    // Allow cross domain
    [webViewConfiguration setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
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
    // Loading html in local ，This way maybe meet cross domain. So You should not forget to set
    // [webViewConfiguration setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
    // If you loading remote web server,That can be ignored.
    [self.webView loadFileURL:filePath allowingReadAccessToURL:filePath];
}
```

2)  In ObjC, and call a Javascript sync function:

```objc
 - (void)callSyncFunction {
    NSDictionary *data = @{@"iOSKey": @"iOSValue"};
    [self.bridge callHandler:@"GetToken" data: data responseCallback:^(id  _Nonnull responseData) {
        NSLog(@"%@",responseData);

    }];
```

3) In ObjC, and call a Javascript Async function:
```objc
 - (void)callAsyncFunction {
    NSDictionary *data = @{@"iOSKey": @"iOSValue"};
    [self.bridge callHandler:@"AsyncCall" data: data responseCallback:^(id  _Nonnull responseData) {
        NSLog(@"%@",responseData);
    }];
}
```
4) In javascript file or typescript and html file like :

```javascript
<script>
    console.log("1111111111111");
    const bridge = window.WebViewJavascriptBridge;
    // JS tries to call the native method to judge whether it has been loaded successfully and let itself know whether its user is in android app or IOS app
    bridge.callHandler('DeviceLoadJavascriptSuccess', {key: 'JSValue'}, function(response) {
        let result = response.result
        if (result === "iOS") {
            console.log("Javascript was loaded by IOS and successfully loaded.");
            window.iOSLoadJSSuccess = true;
            } else if (result === "Android") {
            console.log("Javascript was loaded by Android and successfully loaded.");
            window.AndroidLoadJSSuccess = true;
       }
   });
    // JS register method is called by native
    bridge.registerHandler('GetToken', function(data, responseCallback) {
        console.log(data);
        let result = {token: "I am javascript's token"}
        //JS gets the data and returns it to the native
        responseCallback(result)
    });
    
    bridge.registerHandler('AsyncCall', function(data, responseCallback) {
        console.log(data);
        //Call await function must with  (async () => {})();
        (async () => {
            const callback = await generatorLogNumber(1);
            let result = {token: callback};
            responseCallback(result);
        })();
    });

    function generatorLogNumber(n){
        return new Promise(res => {
        setTimeout(() => {
            res("Javascript async/await callback Ok");
              }, 1000);
        });
   }
</script>
```
# Contact

- Email: housenkui@gmail.com

## License

SDBridgeOC is released under the MIT license. [See LICENSE](https://github.com/SDBridge/SDBridgeOC/blob/master/LICENSE) for details.
