//
//  VSSAppleTVProvider.h
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSURLItem.h"
#import "VSSAppleTVProvider.h"

@interface VSSAppleTVClassicProvider : NSObject

- (void)getVideoAtIndex:(VSSAppleIndex)index completion:(void (^)(VSSURLItem *_Nullable))completion;

@end
