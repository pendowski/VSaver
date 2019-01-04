//
//  NSThread+VSSExtended.h
//  VSaver
//
//  Created by Jarek Pendowski on 04/01/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (VSSExtended)

+ (NSArray<NSString *> *)vss_simpleCallStackSymbolsWithLimit:(NSInteger)limit;
+ (NSString *)vss_simpleCallStackWithLimit:(NSInteger)limit;

@end

NS_ASSUME_NONNULL_END
