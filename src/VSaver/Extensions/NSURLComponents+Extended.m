//
//  NSURLComponents+Extended.m
//  VSaver
//
//  Created by Jarek Pendowski on 03/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "NSURLComponents+Extended.h"

@implementation NSURLComponents (Extended)

- (NSString *)queryValueWithKey:(NSString *)key
{
    for (NSURLQueryItem *item in self.queryItems) {
        if ([item.name isEqualToString:key]) {
            return item.value;
        }
    }
    return nil;
}

- (NSArray<NSString *> *)pathComponents
{
    return [self.path componentsSeparatedByString:@"/"];
}

@end
