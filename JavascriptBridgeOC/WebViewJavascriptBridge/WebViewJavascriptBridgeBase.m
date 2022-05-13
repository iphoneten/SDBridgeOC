//
//  WebViewJavascriptBridgeBase.m
//  TestPod
//
//  Created by 1 on 2020/4/29.
//  Copyright © 2020 1. All rights reserved.
//

#import "WebViewJavascriptBridgeBase.h"
@implementation WebViewJavascriptBridgeBase {
     long _uniqueId;
}
- (instancetype)init {
    if (self = [super init]) {
        self.messageHandlers = [NSMutableDictionary dictionary];
        self.responseCallbacks = [NSMutableDictionary dictionary];
        _uniqueId = 0;
    }
    return self;
}

- (void)sendData:(id)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    
    if (data) {
        message[@"data"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    [self dispatchMessage:message];
}

- (void)flushMessageQueue:(NSString *)messageQueueString{
    if (messageQueueString == nil || messageQueueString.length == 0) {
        NSLog(@"WebViewJavascriptBridge: WARNING: ObjC got nil while fetching the message queue JSON from webview. This can happen if the WebViewJavascriptBridge JS is not currently present in the webview, e.g if the webview just loaded a new page.");
        return;
    }
    WVJBMessage * message = [self deserializeMessageJSON: messageQueueString];
    if (![message isKindOfClass:[WVJBMessage class]]) {
        NSLog(@"WebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
    }
    NSString* responseId = message[@"responseId"];
    if (responseId) {
        WVJBResponseCallback responseCallback = _responseCallbacks[responseId];
        responseCallback(message[@"responseData"]);
        [self.responseCallbacks removeObjectForKey:responseId];
    } else {
        WVJBResponseCallback responseCallback = NULL;
        NSString* callbackId = message[@"callbackId"];
        if (callbackId) {
            responseCallback = ^(id responseData) {
                if (responseData == nil) {
                    responseData = [NSNull null];
                }
                WVJBMessage* msg = @{ @"responseId":callbackId, @"responseData":responseData };
                [self dispatchMessage:msg];
            };
        } else {
            responseCallback = ^(id ignoreResponseData) {
                // Do nothing
            };
        }
        WVJBHandler handler = self.messageHandlers[message[@"handlerName"]];
        
        if (!handler) {
            NSLog(@"WVJBNoHandlerException, No handler for message from JS: %@", message);
        }
        handler(message[@"data"], responseCallback);
    }
}

- (NSString *)serializeMessage:(id)message pretty:(BOOL)pretty{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
}

- (WVJBMessage *)deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)evaluateJavascript:(NSString *)javascriptCommand {
    [self.delegate _evaluateJavascript:javascriptCommand];
}

- (void)dispatchMessage:(WVJBMessage*)message {
    NSString *messageJSON = [self serializeMessage:message pretty:NO];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge.handleMessageFromNative('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [self evaluateJavascript:javascriptCommand];

    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self evaluateJavascript:javascriptCommand];
        });
    }
}
@end
