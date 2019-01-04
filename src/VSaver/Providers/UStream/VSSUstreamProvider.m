//
//  VSSUstreamProvider.m
//  VSaver
//
//  Created by Jarek Pendowski on 04/12/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSUstreamProvider.h"
#import "VSSDelayedOperation.h"
#import "VSSLogger.h"
@import WebKit;
@import JavaScriptCore;

@implementation VSSUstreamProvider

- (instancetype)init
{
    self = [super initWithScriptName:@"ustream"];
    return self;
}

#pragma mark - Properties

- (NSString *)name
{
    return @"UStream";
}

- (BOOL)isValidURL:(NSURL *_Nonnull)url
{
    return [url.host containsString:@"ustream.tv"];
}

- (void)handleLoadedPage:(WebFrame *)frame
{
    __weak typeof(self) weakSelf = self;
    VSSDelayedOperation *timeout = [[VSSDelayedOperation alloc] initWithDelay:30 block:^{
        VSSLog(@"UStream - timeout for %@", weakSelf.loadingURL);
        [weakSelf completeWithURL:nil title:nil frame:frame];
    }];
    
    __weak typeof(frame) weakFrame = frame;
    frame.javaScriptContext[@"vsaverCompletion"] = ^(JSValue *urlValue, JSValue *titleValue) {
        [timeout cancel];
        [weakSelf completeWithURL:urlValue title:titleValue frame:weakFrame];
    };
    [frame.javaScriptContext evaluateScript:@"vsaverMain()"];
}

#pragma mark - Private

- (void)completeWithURL:(JSValue * _Nullable )urlValue title:(JSValue  * _Nullable )titleValue frame:(WebFrame *)frame
{
    if (!urlValue.isString) {
        NSString *htmlDump = [self htmlInFrame:frame];
        VSSLog(@"UStream - failed to load info. Dumping: %@", VSSLogFile(@"UStream.html", [htmlDump dataUsingEncoding:NSUTF8StringEncoding]));
        return [self callCompletion:nil];
    }
    
    NSString *url = [urlValue toString];
    NSString *liveString = [self.loadingURL.absoluteString containsString:@"/recorded/"] ? @"": @" [LIVE]";
    NSString *title = titleValue.isString ? [NSString stringWithFormat:@"UStream%@ %@: %@", liveString, [titleValue toString], self.loadingURL.absoluteString] : self.loadingURL.absoluteString;
    [self callCompletion:[[VSSURLItem alloc] initWithTitle:title url:[NSURL URLWithString:url]]];
}

@end
