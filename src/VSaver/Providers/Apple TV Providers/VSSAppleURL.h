//
//  VSSAppleURL.h
//  VSaver
//
//  Created by Jarek Pendowski on 04/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, VSSAppleQuality) {
    VSSAppleQuality1080H264 = 0,
    VSSAppleQuality1080SDR,
    VSSAppleQuality1080HDR,
    VSSAppleQuality4KSDR,
    VSSAppleQuality4KHDR
};

NSString * VSSAppleQualityNameForQuality(VSSAppleQuality quality);

NS_ASSUME_NONNULL_BEGIN

@interface VSSAppleURL : NSObject
@property (nonatomic, readonly) VSSAppleQuality quality;
@property (nonatomic, readonly, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url quality:(VSSAppleQuality)quality;

@end

NS_ASSUME_NONNULL_END
