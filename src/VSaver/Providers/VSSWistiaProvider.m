//
//  VSSWistiaProvider.m
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSWistiaProvider.h"
#import "NSURLSession+VSSExtended.h"
@import JavaScriptCore;

@interface VSSWistiaProvider ()
@property (nonnull, nonatomic, strong) JSContext *jsContext;
@end

@implementation VSSWistiaProvider

- (instancetype)init
{
    self = [super initWithScriptName:@"wistia"];
    if (self) {
        self.jsContext = [[JSContext alloc] initWithVirtualMachine:[JSVirtualMachine new]];
    }
    return self;
}

- (NSString *)name
{
    return @"Wistia";
}

- (BOOL)isValidURL:(NSURL *)url
{
    return [url.host containsString:@"wistia.com"];
}

- (void)handleLoadedPage:(WebFrame *)mainFrame
{
    NSString *videoID = [self getIDFromURL:self.loadingURL];

    if (videoID.length == 0) {
        [self callCompletion:nil];
        return;
    }

    JSValue *configurationUrl = [mainFrame.javaScriptContext evaluateScript:[NSString stringWithFormat:@"getConfigurationURLWithID('%@')", videoID]];
    if (!configurationUrl.isString) {
        [self callCompletion:nil];
        return;
    }
    JSValue *titleValue = [mainFrame.javaScriptContext evaluateScript:@"vsaverGetTitle()"];

    NSURL *configURL = [NSURL URLWithString:[configurationUrl toString]];
    NSString *title = titleValue.isString ? [@[[titleValue toString], self.loadingURL.absoluteString] componentsJoinedByString:@" 📽"] : self.loadingURL.absoluteString;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    [[session dataTaskWithURL:configURL mainQueueCompletionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        if (error || !data) {
            [self callCompletion:nil];
            return;
        }

        NSString *jsonp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (jsonp.length == 0) {
            [self callCompletion:nil];
            return;
        }

        NSError *regexError;
        NSRegularExpression *windowReplacement = [NSRegularExpression regularExpressionWithPattern:@"window([^=]+)" options:NSRegularExpressionCaseInsensitive error:&regexError];
        NSString *configScript = [windowReplacement stringByReplacingMatchesInString:jsonp options:0 range:NSMakeRange(0, jsonp.length) withTemplate:@"vsaver.json"];

        [self.jsContext evaluateScript:@"let vsaver = {};"];
        [self.jsContext evaluateScript:configScript];
        [self.jsContext evaluateScript:self.script];

        JSValue *urlValue = [self.jsContext evaluateScript:@"vsaverGetURL()"];

        if (!urlValue.isString) {
            [self callCompletion:nil];
            return;
        }

        NSURL *videoURL = [NSURL URLWithString:[urlValue toString]];
        [self callCompletion:[[VSSURLItem alloc] initWithTitle:title url:videoURL]];
    }] resume];
}

#pragma mark - Private

- (NSString *)getIDFromURL:(NSURL *)url
{
    NSURLComponents *components = [NSURLComponents componentsWithString:url.absoluteString];
    NSArray<NSString *> *pathComponents = [components.path.lowercaseString componentsSeparatedByString:@"/"];
    NSInteger mediasIndex = [pathComponents indexOfObject:@"medias"];

    if (mediasIndex == NSNotFound || mediasIndex == pathComponents.count) {
        return nil;
    }

    return pathComponents[mediasIndex + 1];
}

@end
