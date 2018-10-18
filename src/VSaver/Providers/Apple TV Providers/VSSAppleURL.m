//
//  VSSAppleURL.m
//  VSaver
//
//  Created by Jarek Pendowski on 04/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSAppleURL.h"

@interface VSSAppleURL ()
@property (nonatomic) VSSAppleQuality quality;
@property (nonatomic, strong) NSURL *url;
@end

@implementation VSSAppleURL

- (instancetype)initWithURL:(NSURL *)url quality:(VSSAppleQuality)quality
{
    self = [super init];

    self.quality = quality;
    self.url = url;

    return self;
}

@end

NSString * VSSAppleQualityNameForQuality(VSSAppleQuality quality)
{
    switch (quality) {
        case VSSAppleQuality1080H264:
            return @"1080p264";
        case VSSAppleQuality1080SDR:
            return @"1080p";
        case VSSAppleQuality1080HDR:
            return @"1080p HDR";
        case VSSAppleQuality4KSDR:
            return @"4K";
        case VSSAppleQuality4KHDR:
            return @"4K HDR";
    }
}
