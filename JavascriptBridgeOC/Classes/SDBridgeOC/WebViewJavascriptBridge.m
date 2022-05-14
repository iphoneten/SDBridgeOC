//
//  WebViewJavascriptBridge.m
//  TestPod
//
//  Created by 1 on 2020/4/29.
//  Copyright © 2020 1. All rights reserved.
//

#import "WebViewJavascriptBridge.h"
#import "WebViewJavascriptLeakAvoider.h"
#import "SDJavascriptCode.h"
static NSString * const PipeTypeNormal = @"normal";
static NSString * const PipeTypeConsole = @"console";
@interface WebViewJavascriptBridge()
@property (strong,nonatomic) WebViewJavascriptBridgeBase *base;
@property (weak,nonatomic) WKWebView *webView;
@property (strong,nonatomic) NSArray *javascriptFiles;
@end
@implementation WebViewJavascriptBridge
+ (instancetype)bridgeForWebView:(WKWebView *)webView {
    return  [self bridgeForWebView:webView consolePipeBlock:nil];
}
+ (instancetype)bridgeForWebView:(WKWebView *)webView
                consolePipeBlock:(nullable ConsolePipeBlock)consolePipeBlock {
    return  [self bridgeForWebView:webView anotherJavascriptCode:nil consolePipeBlock:consolePipeBlock];
}
+ (instancetype)bridgeForWebView:(WKWebView *)webView
                   anotherJavascriptCode:(nullable NSString *)anotherJavascriptCode
                consolePipeBlock:(nullable ConsolePipeBlock)consolePipeBlock {
    WebViewJavascriptBridge *bridge = [[self alloc] init];
    bridge.webView = webView;
    bridge.consolePipeBlock = consolePipeBlock;
    [bridge setupInstance];
    [bridge injectJavascriptCode:anotherJavascriptCode];
    return bridge;
}
- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self.base sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    self.base.messageHandlers[handlerName] = [handler copy];
}

- (void)removeHandler:(NSString *)handlerName {
    [self.base.messageHandlers removeObjectForKey:handlerName];
}

- (void)setupInstance {
    self.base = [[WebViewJavascriptBridgeBase alloc] init];
    self.base.delegate = self;

    [self addScriptMessageHandler];
    [self injectJavascriptFile];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *name = message.name;
    if ([name isEqualToString:PipeTypeConsole]) {
        if (self.consolePipeBlock) {
            self.consolePipeBlock(message.body);
        }
    } else if ([name isEqualToString:PipeTypeNormal]) {
        NSString * body = (NSString * )message.body;
        [self.base flushMessageQueue:body];
    }
}
- (void)injectJavascriptFile {
    [self injectJavascriptCode:[SDJavascriptCode bridge]];
    [self injectJavascriptCode:[SDJavascriptCode hookConsole]];
}
- (void)injectJavascriptCode:(NSString *)javascriptCode {
    if (!javascriptCode){
        return;
    }
    if (![javascriptCode isKindOfClass:[NSString class]]) {
        return ;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimedString = [javascriptCode stringByTrimmingCharactersInSet:set];
    if ([trimedString length] == 0) {
        return;
    }
    WKUserScript *userScript = [[WKUserScript alloc]initWithSource:javascriptCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [self.webView.configuration.userContentController addUserScript:userScript];
}
- (void)addScriptMessageHandler {
    WebViewJavascriptLeakAvoider *leakAvoider = [[WebViewJavascriptLeakAvoider alloc] initWithDelegate:self];
    [self.webView.configuration.userContentController addScriptMessageHandler:leakAvoider name:PipeTypeConsole];
    [self.webView.configuration.userContentController addScriptMessageHandler:leakAvoider name:PipeTypeNormal];
}
- (void)removeScriptMessageHandler {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:PipeTypeConsole];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:PipeTypeNormal];
}
- (NSString*)_evaluateJavascript:(NSString*)javascriptCommand {
    [self.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    return NULL;
}
- (NSArray *)javascriptFiles {
    if (!_javascriptFiles) {
        _javascriptFiles = @[@"bridge",@"hookConsole"];
    }
    return _javascriptFiles;
}
- (void)dealloc {
    NSLog(@"WebViewJavascriptBridge dealloc");
    [self removeScriptMessageHandler];
}
@end
