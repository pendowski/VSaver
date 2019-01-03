//
//  VSSDelayedOperation.m
//  VSaver
//
//  Created by Jarek Pendowski on 04/12/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSDelayedOperation.h"

@interface VSSDelayedOperation ()
@property (nonatomic) BOOL isCanceled;
@end

@implementation VSSDelayedOperation

- (instancetype)initWithDelay:(NSTimeInterval)delay block:(void (^)(void))block
{
    self = [super init];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isCanceled) {
            return;
        }
        block();
    });
    
    return self;
}

- (void)cancel
{
    self.isCanceled = YES;
}

@end
