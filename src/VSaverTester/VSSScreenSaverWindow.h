//
//  VSSScreenSaverWindow.h
//  VSaverTester
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VSSScreenSaver.h"

typedef NSView<VSSScreenSaver> *(^ VSSScreenSaverFactory)(CGRect frame);

@interface VSSScreenSaverWindow : NSWindow
@property (nullable, nonatomic, weak) NSView<VSSScreenSaver> *screenSaverView;

- (instancetype)initWithScreenSaverViewFactory:(VSSScreenSaverFactory)factory;
- (instancetype)initWithScreenSaverViewFactory:(VSSScreenSaverFactory)factory styleMask:(NSWindowStyleMask)styleMask screen:(NSScreen *)screen coverFullScreen:(BOOL)fullScreen;

- (void)reloadScreenSaver;
@end
