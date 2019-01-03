//
//  VSSDelayedOperation.h
//  VSaver
//
//  Created by Jarek Pendowski on 04/12/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VSSDelayedOperation : NSObject

- (instancetype)initWithDelay:(NSTimeInterval)delay block:(void(^)(void))block;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
