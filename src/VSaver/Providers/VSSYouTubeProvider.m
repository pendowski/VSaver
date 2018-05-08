//
//  VSSYouTubeProvider.m
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSYouTubeProvider.h"
@import WebKit;
@import JavaScriptCore;

@interface VSSYouTubeProvider () <WebFrameLoadDelegate>
@property (nonnull, nonatomic, strong) WebView *webView;
@property (nullable, nonatomic, copy) NSString *script;
@property (nullable, nonatomic, strong) NSURL *loadingURL;
@property (nullable, nonatomic, copy) void (^completion)(VSSURLItem *);
@end

@implementation VSSYouTubeProvider

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.webView = [[WebView alloc] init];
        self.webView.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.2 Safari/605.1.15";
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *path = [bundle pathForResource:@"youtube" ofType:@"js"];
        NSError *error;
        NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        self.script = script;
        
        NSAssert(!error && script.length > 0, @"Script not loaded");
        
        self.webView.frameLoadDelegate = self;
    }
    return self;
}

- (NSString *)name {
    return @"YouTube";
}

- (BOOL)isValidURL:(NSURL *)url {
    return self.script.length > 0 && ([url.host containsString:@"youtube.com"] || [url.host containsString:@"youtu.be"]);
}

- (void)getVideoFromURL:(NSURL *)url completion:(void (^)(VSSURLItem * _Nullable))completion {
    [self.webView stopLoading:nil];
    
    self.completion = completion;
    self.loadingURL = url;
    
    [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - WebFrameLoadDelegate

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    WebFrame *mainFrame = sender.mainFrame;
    
    if (!mainFrame || !self.loadingURL || !self.script) {
        [self callCompletion:nil];
        return;
    }
    
    [frame.javaScriptContext evaluateScript:self.script];
    
    JSValue *urlValue = [frame.javaScriptContext evaluateScript:@"vsaverGetURL();"];
    JSValue *titleValue = [frame.javaScriptContext evaluateScript:@"vsaverGetTitle();"];
    
    if (!urlValue.isString) {
        [self callCompletion:nil];
        return;
    }
    
    NSString *title = titleValue.isString ? [@[[titleValue toString], self.loadingURL.absoluteString] componentsJoinedByString:@" 📽"] : self.loadingURL.absoluteString;
    [self callCompletion:[[VSSURLItem alloc] initWithTitle:title url:[NSURL URLWithString:[urlValue toString]]]];
    
    [mainFrame stopLoading];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    if (self.loadingURL != nil) {
        [self callCompletion:nil];
    }
    self.loadingURL = nil;
}

#pragma mark - Private

- (void)callCompletion: (VSSURLItem * _Nullable)item {
//    NSAssert(self.completion != nil, @"Completion already called");
    if (self.completion) {
        self.completion(item);
    }
    self.completion = nil;
}

@end
