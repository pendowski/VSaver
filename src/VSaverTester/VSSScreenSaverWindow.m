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
    return [self initWithScreenSaverViewFactory:factory styleMask:(NSWindowStyleMaskResizable | NSWindowStyleMaskTitled | NSWindowStyleMaskClosable) screen:[NSScreen mainScreen] coverFullScreen:NO];
}
    
- (instancetype)initWithScreenSaverViewFactory:(VSSScreenSaverFactory)factory styleMask:(NSWindowStyleMask)styleMask screen:(NSScreen *)screen coverFullScreen:(BOOL)fullScreen {
    CGSize screenSize = fullScreen ? [screen frame].size : [screen visibleFrame].size;
    CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self = [super initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES screen:screen];
    if (self) {
        self.hidesOnDeactivate = NO;
        [self setReleasedWhenClosed:NO];
        self.screenSaverfactory = factory;
        
        [self reloadScreenSaver];
    }
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    const unsigned short spaceKey = 49;
    const unsigned short rightKey = 124;
    
    if (event.keyCode == spaceKey || event.keyCode == rightKey) {
        [self.screenSaverView.videoController playNext];
    } else {
        [super keyDown:event];
    }
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
