//
//  VSSProvider.h
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "VSSURLItem.h"

@protocol VSSProvider <NSObject>
@property (nonnull, nonatomic, readonly, copy) NSString *name;

- (BOOL)isValidURL:(NSURL *_Nonnull)url;
- (void)getVideoFromURL:(NSURL *_Nonnull)url completion:(void (^_Nonnull)(VSSURLItem *_Nullable))completion;
@end

@protocol VSSSupports4KQuality
@property (nonatomic) BOOL shouldUse4K;
@end
