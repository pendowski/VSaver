//
//  VSSAppleItem.m
//  VSaver
//
//  Created by Jarek Pendowski on 03/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSAppleItem.h"
#import "NSArray+Extended.h"

@interface VSSAppleItem ()
@property (nonnull, nonatomic, strong) NSMutableDictionary<NSNumber *, NSURL *> *urls;
@end

@implementation VSSAppleItem

- (instancetype)initWithIndex:(NSInteger)index label:(NSString *)label
{
    self = [super init];
    if (self) {
        self.index = index;
        self.label = label;
        self.urls = [@{} mutableCopy];
    }
    return self;
}

- (void)setURL:(NSURL *)url forQuality:(VSSAppleQuality)quality
{
    NSNumber *key = @(quality);
    self.urls[key] = url;
}

- (VSSAppleURL *)urlForQuality:(VSSAppleQuality)quality
{
    NSNumber *key = @(quality);
    NSURL *url = self.urls[key];
    if (url) {
        return [[VSSAppleURL alloc] initWithURL:url quality:quality];
    }

    NSDictionary *urls = [self saveURLs];
    NSNumber *safeKey = urls.allKeys.firstObject;
    if (!safeKey) {
        return nil;
    }

    return [[VSSAppleURL alloc] initWithURL:urls[safeKey] quality:safeKey.unsignedIntegerValue];
}

- (NSDictionary<NSNumber *, NSURL *> *)saveURLs
{
    NSMutableDictionary *urlsCopy = [self.urls mutableCopy];

    NSArray *HDRQualities = @[ @(VSSAppleQuality4KHDR), @(VSSAppleQuality1080HDR) ];
    [HDRQualities vss_forEach:^(NSNumber *_Nonnull key) {
        [urlsCopy removeObjectForKey:key];
    }];

    return [urlsCopy copy];
}

@end
