//
//  VSSScreenSaverWindow.h
//  VSaverTester
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import ScreenSaver;

@interface VSSScreenSaverWindow : NSWindow
@property (nonatomic, weak) ScreenSaverView *screenSaverView;

- (instancetype)initWithScreenSaverView: (ScreenSaverView *)view;
@end
