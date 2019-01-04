//
//  NSURLComponents+Extended.m
//  VSaver
//
//  Created by Jarek Pendowski on 03/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "NSURLComponents+Extended.h"

@implementation NSURLComponents (Extended)

- (NSString *)vss_queryValueWithKey:(NSString *)key
{
    for (NSURLQueryItem *item in self.queryItems) {
        if ([item.name isEqualToString:key]) {
            return item.value;
        }
    }
    return nil;
}

- (NSArray<NSString *> *)vss_pathComponents
{
    return [self.path componentsSeparatedByString:@"/"];
}

- (NSArray *)vss_fragmentItems {
    NSURLComponents *fakeComponents = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"http://localhost/?%@", self.fragment]];
    return fakeComponents.queryItems;
}

@end
