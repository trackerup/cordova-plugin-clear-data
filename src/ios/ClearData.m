/*
 Copyright 2017 Dave Alden/Working Edge Ltd.
 
 Licensed under MIT.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of
 the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */


#import "ClearData.h"
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
#import <WebKit/WKWebsiteDataStore.h>
#endif

@implementation ClearData

@synthesize command;

-(void)cache:(CDVInvokedUrlCommand*)command
{
    @try {
        self.command = command;

        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        if ([self usingWKWebView]) {
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
            NSSet* dataTypes = [NSSet setWithArray:@[
                WKWebsiteDataTypeDiskCache,
                WKWebsiteDataTypeOfflineWebApplicationCache,
                WKWebsiteDataTypeMemoryCache
            ]];
            [self clearWKWebViewData:dataTypes success:^()
             {
                 [self sendPluginSuccess];
             }
             ];
#endif
        }else{
            [self sendPluginSuccess];
        }

    }@catch (NSException *exception) {
        [self handleException:exception];
    }
}

- (void)clearWKWebViewData:(NSSet*)dataTypes
                   success:(void (^)())successBlock
{
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:dataTypes modifiedSince:[NSDate dateWithTimeIntervalSince1970:0] completionHandler:^{
        @try {
            successBlock();
        }@catch (NSException *exception) {
            [self handleException:exception];
        }
    }];
#endif
}


- (void)sendPluginSuccess{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:self.command.callbackId];
}
                               
- (void)sendPluginError:(NSString*)message{
   CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                               messageAsString:[message stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
   [self.commandDelegate sendPluginResult:result callbackId:self.command.callbackId];
}

- (void)handleException:(NSException*)exception{
   [self sendPluginError:[NSString stringWithFormat:@"EXCEPTION: %@", exception.reason]];
}


- (bool)usingWKWebView{
    Class class = NSClassFromString(@"CDVWKWebViewEngine");
    return class != nil;
}

@end
