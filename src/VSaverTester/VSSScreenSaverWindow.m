//
//  VSSScreenSaverWindow.m
//  VSaverTester
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSScreenSaverWindow.h"
#import "VSaverView.h"

@implementation VSSScreenSaverWindow
    
- (instancetype)init {
    CGRect mainFrame = [[NSScreen mainScreen] visibleFrame];
    self = [super initWithContentRect:mainFrame styleMask:(NSWindowStyleMaskResizable | NSWindowStyleMaskTitled | NSWindowStyleMaskClosable) backing:NSBackingStoreBuffered defer:YES];
    if (self) {
        self.hidesOnDeactivate = NO;
        [self setReleasedWhenClosed:NO];
        
        [self reloadScreenSaver];
    }
    return self;
}

#pragma mark - Private

- (void)reloadScreenSaver {
    [self.screenSaverView removeFromSuperview];
    
    VSaverView *saverView = [[VSaverView alloc] initWithFrame:CGRectZero isPreview:NO];
    saverView.frame = self.contentView.bounds;
    saverView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.contentView addSubview:saverView];
    
    self.screenSaverView = saverView;
}

@end
