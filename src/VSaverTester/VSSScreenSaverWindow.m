//
//  VSSScreenSaverWindow.m
//  VSaverTester
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSScreenSaverWindow.h"

@implementation VSSScreenSaverWindow
    
    - (instancetype)initWithScreenSaverView:(ScreenSaverView *)view {
        CGRect mainFrame = [[NSScreen mainScreen] visibleFrame];
        self = [super initWithContentRect:mainFrame styleMask:(NSWindowStyleMaskResizable | NSWindowStyleMaskTitled | NSWindowStyleMaskClosable) backing:NSBackingStoreBuffered defer:YES];
        if (self) {
            self.hidesOnDeactivate = NO;
            [self setReleasedWhenClosed:NO];
            
            view.frame = self.contentView.bounds;
            view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
            [self.contentView addSubview:view];
            
            self.screenSaverView = view;
        }
        return self;
    }

@end
