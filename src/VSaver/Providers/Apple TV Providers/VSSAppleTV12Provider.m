//
//  VSSAppleTV12Provider.m
//  VSaver
//
//  Created by Jarek Pendowski on 03/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSAppleTV12Provider.h"
#import "VSSAppleItem.h"
#import "NSObject+Extended.h"
#import "NSArray+Extended.h"

#define TARURL [NSURL URLWithString: @"https://sylvan.apple.com/Aerials/resources.tar"]

@interface VSSAppleTV12Provider ()
@property (nonnull, nonatomic, strong) NSMutableArray<VSSAppleItem *> *cache;
@end

@implementation VSSAppleTV12Provider

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [NSMutableArray array];
    }
    return self;
}

- (NSString *)name {
    return @"AppleTV";
}

#pragma mark - VSSProvider

- (BOOL)isValidURL: (NSURL *_Nonnull)url {
    return [url.scheme isEqualToString:@"appletv"];
}

- (void)getVideoAtIndex:(VSSAppleIndex)index quality:(VSSAppleQuality)quality completion:(nonnull void (^)(VSSURLItem * _Nullable))completion {
    
    if (self.cache.count > 0) {
        completion([self getItemAtIndex:index quality:quality]);
        return;
    }
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"appletv12"];
    NSURL *cacheDestination = [NSURL fileURLWithPath:cachePath isDirectory:YES];
    
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:cachePath error:nil];
    NSDate *modifiedDate = attributes[NSFileModificationDate];
    
    if (modifiedDate && NSDate.timeIntervalSinceReferenceDate - modifiedDate.timeIntervalSince1970 > 60 * 60 * 24) {
        return [self getVideoFromCache:cacheDestination urlIndex:index quality:quality completion:completion];
    }
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    [[session downloadTaskWithURL:TARURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!location || error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf getVideoFromCache:cacheDestination urlIndex:index quality:quality completion:completion];
            });
            return;
        }
        
        [[NSFileManager defaultManager] removeItemAtURL:cacheDestination error:nil];
        if (![strongSelf untar:location destination:cacheDestination]) {
            [[NSFileManager defaultManager] removeItemAtURL:cacheDestination error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf getVideoFromCache:cacheDestination urlIndex:index quality:quality completion:completion];
        });
        
    }] resume];
}

#pragma mark - Private

- (VSSURLItem *)getItemAtIndex:(NSInteger)index quality:(VSSAppleQuality)quality {
    NSInteger cacheIndex = index;
    if (index < 0 || self.cache.count <= index) {
        cacheIndex = arc4random() % (self.cache.count - 1);
    }
    VSSAppleItem *item = self.cache[cacheIndex];
    VSSAppleURL *url = [item urlForQuality:quality];
    return [[VSSURLItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ #%ld %@ %@", self.name, item.index, item.label, VSSAppleQualityNameForQuality(url.quality)] url:url.url];
}

- (BOOL)untar: (NSURL *)tarFile destination: (NSURL *)destination {
    if (![[NSFileManager defaultManager] fileExistsAtPath:destination.path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:destination.path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSTask *task = [NSTask new];
    task.launchPath = @"/usr/bin/tar";
    task.arguments = @[ @"-xf", tarFile.path, @"-C", destination.path ];
    
    [task launch];
    [task waitUntilExit];

    return task.terminationReason == NSTaskTerminationReasonExit;
}

- (void)getVideoFromCache:(NSURL *)cacheURL urlIndex:(NSInteger)urlIndex quality:(VSSAppleQuality)quality completion:(void (^)(VSSURLItem * _Nullable))completion {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[cacheURL.path stringByAppendingPathComponent:@"entries.json"]]];
    if (!data) {
        return completion(nil);
    }
    
    NSError *jsonError;
    NSDictionary *jsonDictionaries = VSSAS([NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError], NSDictionary);
    NSArray<NSDictionary *> *assets = VSSAS(jsonDictionaries[@"assets"], NSArray);
    
    if (!assets || jsonError) {
        completion(nil);
        return;
    }
    
    [self.cache removeAllObjects];
    
    for (NSDictionary *dic in assets) {
        NSString *label = dic[@"accessibilityLabel"] ?: @"";
        NSInteger index = self.cache.count + 1;
        NSDictionary<NSString*, NSNumber*> *keyToQuality = @{
                                                             @"url-1080-H264": @(VSSAppleQuality1080H264),
                                                             @"url-1080-SDR": @(VSSAppleQuality1080SDR),
                                                             @"url-1080-HDR": @(VSSAppleQuality1080HDR),
                                                             @"url-4K-SDR": @(VSSAppleQuality4KSDR),
                                                             @"url-4K-HDR": @(VSSAppleQuality4KHDR),
                                                             };
        VSSAppleItem *item = [[VSSAppleItem alloc] initWithIndex:index label:label];
        BOOL addedURL = NO;
        
        for (NSString *key in keyToQuality.allKeys) {
            NSNumber *qualityValue = keyToQuality[key];
            NSString *urlString = dic[key];
            if (urlString) {
                NSURL *url = [NSURL URLWithString:urlString];
                if (url) {
                    [item setURL:url forQuality:qualityValue.unsignedIntegerValue];
                    addedURL = YES;
                }
            }
        }
        
        if (addedURL) {
            [self.cache addObject:item];
        }
        
    }
    
    if (self.cache.count == 0) {
        return completion(nil);
    }
    
    completion([self getItemAtIndex:urlIndex quality:quality]);
}

@end
