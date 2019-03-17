//
//  NSBundle+VSSExtended.m
//  VSaver
//
//  Created by Jarek Pendowski on 16/03/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import "NSBundle+VSSExtended.h"

@implementation NSBundle (VSSExtended)

- (NSString *)vss_bundleVersion
{
    return [self objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

@end
