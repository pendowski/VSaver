//
//  NSString+Extended.m
//  VSaver
//
//  Created by Jarek Pendowski on 11/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "NSString+Extended.h"
#import "NSArray+Extended.h"

@implementation NSString (Extended)

- (NSString *)stringByTrimmingEachLine {
    NSArray<NSString *> *lines = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return [[lines vss_map:^id _Nullable(NSString *line) {
        return [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }] componentsJoinedByString:@"\n"];
}

@end
