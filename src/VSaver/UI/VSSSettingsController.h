//
//  VSSSettingsController.h
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VSSSettings.h"

@interface VSSSettingsController : NSWindowController
@property (nonnull, nonatomic, strong) id<VSSSettings> settings;
@end
