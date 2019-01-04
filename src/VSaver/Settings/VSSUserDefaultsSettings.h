//
//  VSSUserDefaultsSettings.h
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSettings.h"
#import "VSSLogger.h"

@interface VSSUserDefaultsSettings : NSObject <VSSSettings>

@end

@interface VSSLogger (VSSUserDefaultsSettings)

- (void)logSettings:(VSSUserDefaultsSettings *)settings;

@end
