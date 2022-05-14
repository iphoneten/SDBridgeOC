//
//  SDJavascriptCode.m
//  JavascriptBridgeOC
//
//  Created by HSK on 2022/5/14.
//

#import "SDJavascriptCode.h"
#define kSDToString(x)  @#x
@implementation SDJavascriptCode
+ (NSString *)bridge {
    return kSDToString(;(function(window) {
        window.WebViewJavascriptBridge = {
            registerHandler: registerHandler,
            callHandler: callHandler,
            handleMessageFromNative: handleMessageFromNative
        };
        var messageHandlers = {};
        var responseCallbacks = {};
        var uniqueId = 1;
        function registerHandler(handlerName, handler) {
            messageHandlers[handlerName] = handler;
        }
        function callHandler(handlerName, data, responseCallback) {
            if (arguments.length === 2 && typeof data == 'function') {
                responseCallback = data;
                data = null;
            }
            doSend({ handlerName:handlerName, data:data }, responseCallback);
        }
        function doSend(message, responseCallback) {
            if (responseCallback) {
                var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
                responseCallbacks[callbackId] = responseCallback;
                message['callbackId'] = callbackId;
            }
            window.webkit.messageHandlers.normal.postMessage(JSON.stringify(message));
        }
        function handleMessageFromNative(messageJSON) {
            var message = JSON.parse(messageJSON);
            var messageHandler;
            var responseCallback;

            if (message.responseId) {
                responseCallback = responseCallbacks[message.responseId];
                if (!responseCallback) {
                    return;
                }
                responseCallback(message.responseData);
                delete responseCallbacks[message.responseId];
            } else {
                if (message.callbackId) {
                    var callbackResponseId = message.callbackId;
                    responseCallback = function(responseData) {
                        doSend({ handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData });
                    };
                }
                var handler = messageHandlers[message.handlerName];
                if (!handler) {
                    console.log("WebViewJavascriptBridge: WARNING: no handler for message from ObjC:", message);
                } else {
                    handler(message.data, responseCallback);
                }
            }
        }
    })(window);
);
}
+ (NSString *)hookConsole{
    return kSDToString(;(function(window) {
        let printObject = function (obj) {
            let output = "";
            if (obj === null) {
                output += "null";
            }
            else  if (typeof(obj) == "undefined") {
                output += "undefined";
            }
            else if (typeof obj ==='object'){
                output+="{";
                for(let key in obj){
                    let value = obj[key];
                    output+= "\""+key+"\""+":"+"\""+value+"\""+",";
                }
                output = output.substr(0, output.length - 1);
                output+="}";
            }
            else {
                output = "" + obj;
            }
            return output;
        };
        window.console.log = (function (oriLogFunc,printObject) {
            return function (str) {
                str = printObject(str);
                window.webkit.messageHandlers.console.postMessage(str);
                oriLogFunc.call(window.console, str);
            }
        })(window.console.log,printObject);

    })(window);
);
}
@end
