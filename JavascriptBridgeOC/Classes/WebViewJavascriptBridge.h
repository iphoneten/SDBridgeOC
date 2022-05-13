//
//  WebViewJavascriptBridge.h
//  TestPod
//
//  Created by 1 on 2020/4/29.
//  Copyright © 2020 1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridgeBase.h"
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef void (^ConsolePipeBlock)(id water);
@interface WebViewJavascriptBridge : NSObject<WebViewJavascriptBridgeBaseDelegate,WKScriptMessageHandler>
@property (nullable,copy,nonatomic) ConsolePipeBlock consolePipeBlock;
+ (instancetype)bridgeForWebView:(WKWebView *)webView;
+ (instancetype)bridgeForWebView:(WKWebView *)webView
                consolePipeBlock:(nullable ConsolePipeBlock)consolePipeBlock;
+ (instancetype)bridgeForWebView:(WKWebView *)webView
                   anotherJavascriptCode:(nullable NSString *)anotherJavascriptCode
                consolePipeBlock:(nullable ConsolePipeBlock)consolePipeBlock;
- (void)registerHandler:(NSString*)handlerName handler:(nullable WVJBHandler)handler;
- (void)removeHandler:( NSString* )handlerName;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(nullable id)data;
- (void)callHandler:(NSString*)handlerName data:(nullable id)data responseCallback:(nullable  WVJBResponseCallback)responseCallback;
@end

NS_ASSUME_NONNULL_END
