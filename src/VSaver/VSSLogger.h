//
//  VSSLogger.h
//  VSaver
//
//  Created by Jarek Pendowski on 03/01/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VSSLog(format, ...) [[VSSLogger sharedInstance] log:(format), ## __VA_ARGS__]

NS_ASSUME_NONNULL_BEGIN

@interface VSSLogger : NSObject

+ (VSSLogger *)sharedInstance;

- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

// By default it's called with first initialization. If you don't want that define `VSS_DO_NOT_REGISTER_FOR_SYSTEM_EVENTS` and call it yourself if needed
- (void)registerForSystemEvents;

@end

NS_ASSUME_NONNULL_END
