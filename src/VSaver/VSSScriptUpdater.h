//
//  VSSScriptUpdater.h
//  VSaver
//
//  Created by Jarek Pendowski on 16/03/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VSSScriptUpdater : NSObject

+ (void)configureSharedInstanceWithCacheURL:(NSURL *)cacheURL baseURL:(NSURL *)baseURL bundle:(NSBundle *)bundle;
+ (instancetype)sharedInstance;

- (instancetype)initWithCacheURL:(NSURL * _Nullable)cacheURL baseURL:(NSURL * _Nullable)baseURL bundle:(NSBundle *)bundle;

- (void)scriptWithPath:(NSString *)path completion:(void (^)(NSString *))completion;

@end

NS_ASSUME_NONNULL_END
