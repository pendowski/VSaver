//
//  NSURLComponents+Extended.h
//  VSaver
//
//  Created by Jarek Pendowski on 03/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLComponents (Extended)
@property (nonnull, nonatomic, copy, readonly) NSArray<NSString *> *pathComponents;
@property (nonnull, nonatomic, copy, readonly) NSArray<NSURLQueryItem *> *fragmentItems;

- (NSString *_Nullable)queryValueWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
