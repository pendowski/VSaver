//
//  NSObject+Extended.m
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "NSObject+Extended.h"

@implementation NSObject (Extended)

- (id)vss_as:(Class)class
{
    return [self isKindOfClass:class] ? self : nil;
}

@end
