//
//  VSSVimeoProvider.m
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSVimeoProvider.h"
#import "NSObject+Extended.h"
#import "NSArray+Extended.h"
#import "NSURLSession+VSSExtended.h"

@interface VSSVimeoStream: NSObject
@property (nonnull, nonatomic, copy) NSString *url;
@property (nonnull, nonatomic, copy) NSString *quality;
@property (nonnull, nonatomic, strong) NSNumber *width;
@end

@implementation VSSVimeoStream
- (instancetype)initWithUrl:(NSString *)url quality:(NSString *)quality width:(NSNumber *)width {
    self = [super init];
    if (self) {
        self.url = url;
        self.quality = quality;
        self.width = width;
    }
    return self;
}
@end

@implementation VSSVimeoProvider

- (NSString *)name {
    return @"Vimeo";
}

- (BOOL)isValidURL:(NSURL *)url {
    return [url.host containsString:@"vimeo.com"];
}

- (void)getVideoFromURL:(NSURL *)url completion:(void (^)(VSSURLItem * _Nullable))completion {
    NSString *videoID = [[url.path componentsSeparatedByString:@"/"] lastObject];
    
    if (videoID.length == 0) {
        completion(nil);
        return;
    }
    
    NSURL *configURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://player.vimeo.com/video/%@/config", videoID]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    [[session dataTaskWithURL:configURL mainQueueCompletionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !data) {
            completion(nil);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *json = VSSAS([NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError], NSDictionary);
        NSDictionary *files = VSSAS(VSSAS(json[@"request"], NSDictionary)[@"files"], NSDictionary);
        NSString *title = VSSAS(VSSAS(json[@"video"], NSDictionary)[@"title"], NSString) ?: url.absoluteString;
        
        NSArray *streams = VSSAS(files[@"progressive"], NSArray);
        if (streams) {
            NSArray<VSSVimeoStream *> *urls = [[streams vss_flatMap:^id _Nullable(NSDictionary * _Nonnull dic) {
                NSString *url = VSSAS(dic[@"url"], NSString);
                NSString *quality = VSSAS(dic[@"quality"], NSString);
                NSNumber *width = VSSAS(dic[@"width"], NSNumber);
                NSString *mime = VSSAS(dic[@"mime"], NSString);
                if (![mime containsString:@"mp4"] || url.length == 0 || quality.length == 0 || !width) {
                    return nil;
                }
                return [[VSSVimeoStream alloc] initWithUrl:url quality:quality width:width];
            }] sortedArrayUsingComparator:^NSComparisonResult(VSSVimeoStream *_Nonnull left, VSSVimeoStream * _Nonnull right) {
                return [left.width compare:right.width];
            }];
            
            NSString *video = urls.firstObject.url;
            if (video) {
                completion([[VSSURLItem alloc] initWithTitle:title url:[NSURL URLWithString:video]]);
                return;
            }
        }
        
        NSDictionary *hls = VSSAS(files[@"hls"], NSDictionary);
        NSString *hlsUrl = VSSAS(hls[@"url"], NSString);
        if (hlsUrl.length > 0) {
            completion([[VSSURLItem alloc] initWithTitle:title url:[NSURL URLWithString:hlsUrl]]);
            return;
        }
        
        completion(nil);
    }] resume];
}

@end
