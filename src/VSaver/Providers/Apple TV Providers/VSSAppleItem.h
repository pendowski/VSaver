//
//  VSSAppleItem.h
//  VSaver
//
//  Created by Jarek Pendowski on 03/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSAppleURL.h"

NS_ASSUME_NONNULL_BEGIN

@interface VSSAppleItem: NSObject
@property (nonatomic) NSInteger index;
@property (nonnull, nonatomic, copy) NSString *label;

- (instancetype)initWithIndex:(NSInteger)index label:(NSString *)label;
- (void)setURL:(NSURL *)url forQuality:(VSSAppleQuality)quality;
- (VSSAppleURL * _Nullable)urlForQuality:(VSSAppleQuality)quality;

@end

NS_ASSUME_NONNULL_END
