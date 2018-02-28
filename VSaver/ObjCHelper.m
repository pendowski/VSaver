//
//  ObjCHelper.m
//  VSaver
//
//  Created by Jarek Pendowski on 16/10/2017.
//  Copyright © 2017 Jaroslaw Pendowski. All rights reserved.
//

#import "ObjCHelper.h"

@implementation ObjCHelper
    
    + (nullable NSNumber *)identifierFromScreen: (nonnull NSScreen *)screen {
        return [screen deviceDescription][@"NSScreenNumber"];
    }
    
    + (nullable NSString *)displayIDFromScreen: (nonnull NSScreen *)screen {
        return [[self identifierFromScreen:screen] stringValue];
    }
    
    + (nullable NSString *)displayNameFromScreen: (nonnull NSScreen *)screen {
        NSNumber *idenfier = [self identifierFromScreen:screen];
        if (!idenfier) { return nil; }
        
        CGDirectDisplayID displayID = [idenfier unsignedIntValue];
        NSString *screenName = nil;
        
        NSDictionary *deviceInfo = (NSDictionary *)CFBridgingRelease(IODisplayCreateInfoDictionary(CGDisplayIOServicePort(displayID), kIODisplayOnlyPreferredName));
        NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];
        
        if ([localizedNames count] > 0) {
            screenName = [localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]];
        }
        
        return screenName;
    }

@end
