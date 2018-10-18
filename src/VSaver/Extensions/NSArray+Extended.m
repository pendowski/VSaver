//
//  NSArray+VSSNSArray_Extended.m
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "NSArray+Extended.h"

@implementation NSArray (Extended)

- (void)vss_forEach:(void (^)(id obj))block
{
    for (id obj in self) {
        block(obj);
    }
}

- (NSArray *)vss_map:(id (^)(id))block
{
    NSMutableArray *array = [NSMutableArray array];
    for (id obj in self) {
        id result = block(obj);
        if (result) {
            [array addObject:result];
        }
    }
    return array;
}

- (NSArray *)vss_flatMap:(id (^)(id))block
{
    NSMutableArray *array = [NSMutableArray array];
    for (id obj in self) {
        id result = block(obj);
        if ([result isKindOfClass:[NSArray class]]) {
            [array addObjectsFromArray:result];
        } else if (result) {
            [array addObject:result];
        }
    }
    return array;
}

- (instancetype)vss_filter:(BOOL (^)(id))block
{
    NSMutableArray *array = [NSMutableArray array];
    for (id obj in self) {
        if (block(obj)) {
            [array addObject:obj];
        }
    }
    return array;
}

@end
