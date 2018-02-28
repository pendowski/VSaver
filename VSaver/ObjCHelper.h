//
//  ObjCHelper.h
//  VSaver
//
//  Created by Jarek Pendowski on 16/10/2017.
//  Copyright © 2017 Jaroslaw Pendowski. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface ObjCHelper : NSObject
    
    + (nullable NSString *)displayIDFromScreen: (nonnull NSScreen *)screen;
    + (nullable NSString *)displayNameFromScreen: (nonnull NSScreen *)screen;

@end
