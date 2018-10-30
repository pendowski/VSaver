//
//  VSSVersionChecker.h
//  VSaver
//
//  Created by Jarek Pendowski on 22/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VSSUpdateChecker : NSObject

- (instancetype)initWithVersionSource:(NSString * _Nullable (^_Nullable)(void))source;

- (void)checkForUpdates:(void (^)(BOOL, NSString * _Nullable))updates;

@end

NS_ASSUME_NONNULL_END
