//
//  VSSURLItem.m
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSURLItem.h"

@implementation VSSURLItem

- (instancetype _Nonnull)initWithTitle:(NSString *_Nonnull)title url:(NSURL *_Nonnull)url
{
    return [self initWithTitle:title url:url beginTime:0];
}

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url beginTime:(NSUInteger)seconds
{
    self = [super init];
    if (self) {
        self.beginTime = seconds;
        self.title = title;
        self.url = url;
    }
    return self;
}

@end
