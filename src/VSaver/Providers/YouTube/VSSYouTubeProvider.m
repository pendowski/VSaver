//
//  VSSYouTubeProvider.m
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSYouTubeProvider.h"
#import "NSArray+Extended.h"
@import WebKit;
@import JavaScriptCore;

@implementation VSSYouTubeProvider

- (instancetype)init
{
    self = [super initWithScriptName:@"youtube"];
    return self;
}

- (NSString *)name
{
    return @"YouTube";
}

- (BOOL)isValidURL:(NSURL *)url
{
    return [url.host containsString:@"youtube.com"] || [url.host containsString:@"youtu.be"];
}

- (void)handleLoadedPage:(WebFrame *)frame
{
    JSValue *urlValue = [frame.javaScriptContext evaluateScript:@"vsaverGetURL();"];
    JSValue *titleValue = [frame.javaScriptContext evaluateScript:@"vsaverGetTitle();"];

    if (!urlValue.isString) {
        [self callCompletion:nil];
        return;
    }

    NSString *title = titleValue.isString ? [@[[titleValue toString], self.loadingURL.absoluteString] componentsJoinedByString:@" 📽"] : self.loadingURL.absoluteString;
    VSSURLItem *item = [[VSSURLItem alloc] initWithTitle:title url:[NSURL URLWithString:[urlValue toString]]];
    item.beginTime = [self timeFromURL];
    [self callCompletion:item];
}

- (NSUInteger)timeFromURL {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self.loadingURL resolvingAgainstBaseURL:NO];
    NSURLQueryItem *timeItem = [components.queryItems vss_filter:^BOOL(NSURLQueryItem *_Nonnull obj) {
        return [obj.name isEqualToString:@"t"];
    }].firstObject;
    
    if (!timeItem || timeItem.value.length == 0) {
        return 0;
    }
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:timeItem.value];
    NSInteger time = 0;
    if (![scanner scanInteger:&time]) {
        return 0;
    }
    return time;
}

@end
