//
//  VSSScreenSaverWindow.m
//  VSaverTester
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSScreenSaverWindow.h"
#import "VSSScreenSaver.h"

@interface VSSScreenSaverWindow ()
@property (nonnull, nonatomic, copy) VSSScreenSaverFactory screenSaverfactory;
@end

@implementation VSSScreenSaverWindow
    
- (instancetype)initWithScreenSaverViewFactory:(VSSScreenSaverFactory)factory {
    CGRect mainFrame = [[NSScreen mainScreen] visibleFrame];
    self = [super initWithContentRect:mainFrame styleMask:(NSWindowStyleMaskResizable | NSWindowStyleMaskTitled | NSWindowStyleMaskClosable) backing:NSBackingStoreBuffered defer:YES];
    if (self) {
        self.hidesOnDeactivate = NO;
        [self setReleasedWhenClosed:NO];
        self.screenSaverfactory = factory;
        
        [self reloadScreenSaver];
    }
    return self;
}

#pragma mark - Private

- (void)reloadScreenSaver {
    [self.screenSaverView removeFromSuperview];
    
    NSView<VSSScreenSaver> *saverView = self.screenSaverfactory(self.contentView.bounds);
    saverView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.contentView addSubview:saverView];
    
    self.screenSaverView = saverView;
}

@end
