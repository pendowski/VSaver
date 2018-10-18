//
//  VSSAppleTV12Provider.h
//  VSaver
//
//  Created by Jarek Pendowski on 03/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSURLItem.h"
#import "VSSAppleTVProvider.h"
#import "VSSAppleURL.h"

NS_ASSUME_NONNULL_BEGIN

@interface VSSAppleTV12Provider : NSObject

- (void)getVideoAtIndex:(VSSAppleIndex)index quality:(VSSAppleQuality)quality completion:(void (^)(VSSURLItem *_Nullable))completion;

@end

NS_ASSUME_NONNULL_END
