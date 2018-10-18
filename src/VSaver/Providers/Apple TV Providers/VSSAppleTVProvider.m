//
//  VSSAppleTVProvider.m
//  VSaver
//
//  Created by Jarek Pendowski on 09/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSAppleTVProvider.h"
#import "VSSAppleTVClassicProvider.h"
#import "VSSAppleTV12Provider.h"
#import "NSURLComponents+Extended.h"

VSSAppleIndex VSSAppleIndexRandom = -1;

@interface VSSAppleTVProvider ()
@property (nonatomic, nonnull, strong) VSSAppleTVClassicProvider *appleClassic;
@property (nonatomic, nonnull, strong) VSSAppleTV12Provider *appleTV12;
@end

@implementation VSSAppleTVProvider

- (instancetype)init
{
    self = [super init];

    self.appleClassic = [[VSSAppleTVClassicProvider alloc] init];
    self.appleTV12 = [[VSSAppleTV12Provider alloc] init];

    return self;
}

- (NSString *)name
{
    return @"Apple TV";
}

- (BOOL)isValidURL:(NSURL *)url
{
    return [url.host containsString:@"apple.com"] || [url.scheme isEqualToString:@"appletv"];
}

- (void)getVideoFromURL:(NSURL *)url completion:(void (^)(VSSURLItem *_Nullable))completion
{
    if (![url.scheme isEqualToString:@"appletv"]) {
        return completion([[VSSURLItem alloc] initWithTitle:url.absoluteString url:url]);
    }
    VSSAppleIndex index = [self indexFromURL:url];

    if (url.host && ([url.host rangeOfString:@"os12"].location == 0 || [url.host rangeOfString:@"tvos12"].location == 0)) {
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        VSSAppleQuality defaultQuality = self.shouldUse4K ? VSSAppleQuality4KSDR : VSSAppleQuality1080SDR;
        VSSAppleQuality quality = [self qualityFromString:[urlComponents queryValueWithKey:@"q"] defaultQuality:defaultQuality];
        [self.appleTV12 getVideoAtIndex:index quality:quality completion:completion];
    } else {
        [self.appleClassic getVideoAtIndex:index completion:completion];
    }
}

#pragma mark - Private

- (VSSAppleIndex)indexFromURL:(NSURL *)url
{
    NSArray<NSString *> *potentialStrings = @[url.host ? : @"",
                                              url.fragment ? : @"",
                                              url.path.lastPathComponent ? : @"",
                                              [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""] ? : @""];
    NSCharacterSet *numericCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789#"];

    for (NSString *string in potentialStrings) {
        if ([string rangeOfCharacterFromSet:numericCharacterSet].location == 0) {
            NSScanner *scanner = [NSScanner scannerWithString:url.host];
            NSInteger potentialIndex = 0;
            if ([scanner scanInteger:&potentialIndex] && potentialIndex > 0) {
                return potentialIndex;
            }
        }
    }

    return VSSAppleIndexRandom;
}

- (VSSAppleQuality)qualityFromString:(NSString *_Nullable)string defaultQuality:(VSSAppleQuality)defaultValue
{
    NSDictionary<NSString *, NSNumber *> *map = @{
        @"1080": @(VSSAppleQuality1080H264),
        @"1080sdr": @(VSSAppleQuality1080SDR),
        @"1080hdr": @(VSSAppleQuality1080HDR),
        @"4ksdr": @(VSSAppleQuality4KSDR),
        @"4khdr": @(VSSAppleQuality4KHDR),
    };
    NSNumber *result = map[[string.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    if (result) {
        return result.unsignedIntegerValue;
    }
    return defaultValue;
}

@end
