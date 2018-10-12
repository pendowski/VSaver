//
//  VSSAppleTVProvider.h
//  VSaver
//
//  Created by Jarek Pendowski on 09/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSProvider.h"
#import "VSSAppleURL.h"

typedef NSInteger VSSAppleIndex;
extern VSSAppleIndex VSSAppleIndexRandom;

NS_ASSUME_NONNULL_BEGIN

@interface VSSAppleTVProvider : NSObject <VSSProvider, VSSSupports4KQuality>
@property (nonatomic) BOOL shouldUse4K;
@end

NS_ASSUME_NONNULL_END
