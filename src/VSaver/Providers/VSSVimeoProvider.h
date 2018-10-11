//
//  VSSVimeoProvider.h
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSProvider.h"

@interface VSSVimeoProvider : NSObject <VSSProvider, VSSSupports4KQuality>
@property (nonatomic) BOOL shouldUse4K;
@end
