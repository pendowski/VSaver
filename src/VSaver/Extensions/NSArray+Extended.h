//
//  NSArray+VSSNSArray_Extended.h
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extended)

- (void)vss_forEach:(void (^_Nonnull)(id _Nonnull obj))block;
- (NSArray *_Nonnull)vss_map:(id _Nullable (^_Nonnull)(id _Nonnull obj))block;
- (NSArray *_Nonnull)vss_flatMap:(id _Nullable (^_Nonnull)(id _Nonnull obj))block;
- (NSArray *_Nonnull)vss_filter:(BOOL (^_Nonnull)(id _Nonnull obj))block;

@end
