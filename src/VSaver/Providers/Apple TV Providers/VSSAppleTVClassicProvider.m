//
//  VSSAppleTVProvider.m
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSAppleTVClassicProvider.h"
#import "NSObject+Extended.h"
#import "NSArray+Extended.h"
#import "NSURLSession+VSSExtended.h"
#import "VSSAppleItem.h"
#import "VSSLogger.h"

#define JSONURL [NSURL URLWithString:@"http://a1.phobos.apple.com/us/r1000/000/Features/atv/AutumnResources/videos/entries.json"]

@interface VSSAppleTVClassicProvider ()
@property (nonnull, nonatomic, strong) NSMutableArray<VSSAppleItem *> *cache;
@end

@implementation VSSAppleTVClassicProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cache = [NSMutableArray array];
    }
    return self;
}

- (NSString *)name
{
    return @"AppleTV Classic";
}

- (void)getVideoAtIndex:(VSSAppleIndex)index completion:(void (^)(VSSURLItem *_Nullable))completion
{
    if (self.cache.count > 0) {
        completion([self getItemAtIndex:index]);
        return;
    }

    __weak typeof(self)weakSelf = self;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    [[session vss_dataTaskWithURL:JSONURL mainQueueCompletionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!data || error) {
            VSSLog(@"AppleTV Classic - failed to download data: %@", error);
            completion(nil);
            return;
        }

        NSError *jsonError;
        NSArray<NSDictionary *> *jsonDictionaries = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSArray<NSDictionary *> *assets = [jsonDictionaries vss_flatMap:^id _Nullable (NSDictionary *_Nonnull obj) {
            return VSSAS(obj[@"assets"], NSArray);
        }];

        if (!assets || jsonError) {
            VSSLog(@"AppleTV Classic - missing assets: %@", jsonError);
            completion(nil);
            return;
        }

        [strongSelf.cache removeAllObjects];

        for (NSDictionary *dic in assets) {
            NSString *urlString = dic[@"url"];
            NSURL *url = [NSURL URLWithString:urlString];
            if (url) {
                NSString *label = dic[@"accessibilityLabel"] ? : @"";
                NSInteger index = strongSelf.cache.count + 1;

                VSSAppleItem *item = [[VSSAppleItem alloc] initWithIndex:index label:label];
                [item setURL:url forQuality:VSSAppleQuality1080H264];
                [strongSelf.cache addObject:item];
            }
        }

        if (strongSelf.cache.count == 0) {
            VSSLog(@"AppleTV Classic - no items found. JSON dump: %@", VSSLogFile(@"AppleClassic.json", data));
            completion(nil);
            return;
        }

        completion([strongSelf getItemAtIndex:index]);
    }] resume];
}

#pragma mark - Private

- (VSSURLItem *)getItemAtIndex:(NSInteger)index
{
    NSInteger cacheIndex = index;
    if (index < 0 || self.cache.count <= index) {
        cacheIndex = arc4random() % (self.cache.count - 1);
    }
    VSSAppleItem *item = self.cache[cacheIndex];
    VSSAppleURL *url = [item urlForQuality:VSSAppleQuality1080H264];
    return [[VSSURLItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ #%ld %@", self.name, item.index, item.label] url:url.url];
}

@end
