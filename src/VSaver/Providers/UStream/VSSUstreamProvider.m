//
//  VSSUstreamProvider.m
//  VSaver
//
//  Created by Jarek Pendowski on 04/12/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSUstreamProvider.h"
#import "VSSDelayedOperation.h"
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
        [weakSelf completeWithURL:nil title:nil];
    }];
    
    frame.javaScriptContext[@"vsaverCompletion"] = ^(JSValue *urlValue, JSValue *titleValue) {
        [timeout cancel];
        [weakSelf completeWithURL:urlValue title:titleValue];
    };
    [frame.javaScriptContext evaluateScript:@"vsaverMain()"];
}

#pragma mark - Private

- (void)completeWithURL:(JSValue * _Nullable )urlValue title:(JSValue  * _Nullable )titleValue
{
    if (!urlValue.isString) {
        return [self callCompletion:nil];
    }
    
    NSString *url = [urlValue toString];
    NSString *liveString = [self.loadingURL.absoluteString containsString:@"/recorded/"] ? @"": @" [LIVE]";
    NSString *title = titleValue.isString ? [NSString stringWithFormat:@"UStream%@ %@: %@", liveString, [titleValue toString], self.loadingURL.absoluteString] : self.loadingURL.absoluteString;
    [self callCompletion:[[VSSURLItem alloc] initWithTitle:title url:[NSURL URLWithString:url]]];
}

@end
