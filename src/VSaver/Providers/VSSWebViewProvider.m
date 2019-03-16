//
//  VSSWebViewProvider.m
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSWebViewProvider.h"
#import "VSSScriptUpdater.h"
@import JavaScriptCore;

@interface VSSWebViewProvider () <WebFrameLoadDelegate>
@property (nonnull, nonatomic, strong) WebView *webView;
@property (nonnull, nonatomic, copy) NSString *scriptName;
@property (nullable, nonatomic, copy) NSString *script;
@property (nullable, nonatomic, strong) NSURL *loadingURL;
@property (nullable, nonatomic, copy) void (^ completion)(VSSURLItem *);
@end

@implementation VSSWebViewProvider

- (instancetype)initWithScriptName:(NSString *)scriptName
{
    self = [super init];

    if (self) {
        self.webView = [[WebView alloc] init];
        self.webView.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.2 Safari/605.1.15";
        [self.webView.preferences setPlugInsEnabled:NO];
        self.webView.frameLoadDelegate = self;

        self.scriptName = [scriptName stringByAppendingPathExtension:@"js"];
    }
    return self;
}

- (NSString *)name
{
    return @"INVALID";
}

- (BOOL)isValidURL:(NSURL *)url
{
    return NO;
}

- (void)getVideoFromURL:(NSURL *)url completion:(void (^)(VSSURLItem *_Nullable))completion
{
    [self.webView stopLoading:nil];

    self.completion = completion;
    self.loadingURL = url;
    
    [self refreshScriptIfNeededAndLoadURL:url];
}

- (void)callCompletion:(VSSURLItem *_Nullable)item
{
    if (self.completion) {
        self.completion(item);
    }
    self.completion = nil;
    [self.webView.mainFrame stopLoading];
}

- (void)handleLoadedPage:(WebFrame *)mainFrame
{
    // NOOP - should be implemented in the subclass
}

- (NSString *)htmlInFrame:(WebFrame *)frame
{
    if (!frame) {
        return @"";
    }
    return [frame.javaScriptContext evaluateScript:@"document.documentElement.outerHTML"].toString ?: @"";
}

#pragma mark - WebFrameLoadDelegate

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)aFrame
{
    WebFrame *mainFrame = sender.mainFrame;
    if (aFrame != mainFrame) {
        return;
    }

    if (!mainFrame || !self.loadingURL || !self.script) {
        [self callCompletion:nil];
        return;
    }

    if (self.script) {
        [mainFrame.javaScriptContext evaluateScript:self.script];
    }
    [self handleLoadedPage:mainFrame];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if (frame != sender.mainFrame) {
        return;
    }
    
    if (self.loadingURL != nil) {
        [self callCompletion:nil];
    }
    self.loadingURL = nil;
}

- (void)refreshScriptIfNeededAndLoadURL:(NSURL *)url
{
    [[VSSScriptUpdater sharedInstance] scriptWithPath:self.scriptName completion:^(NSString * _Nonnull script) {
        if (script) {
            self.script = script;
        }
        [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
    }];
}

@end
