//
//  AppDelegate.m
//  VSaverTester
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "AppDelegate.h"
#import "VSaverView.h"
#import "VSSScreenSaverWindow.h"
#import "NSObject+Extended.h"

@interface AppDelegate () <NSWindowDelegate>

    @property (nonnull, nonatomic, strong) NSMutableArray<VSSScreenSaverWindow *> *windows;
    
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.windows = [@[] mutableCopy];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
    
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender {
    [self createNewWindow];
    return YES;
}
    
#pragma mark - Actions

- (IBAction)openPreferencesSelected: (NSMenuItem *)sender {
    VSSScreenSaverWindow *window = VSSAS([NSApp keyWindow], VSSScreenSaverWindow);
    NSWindow *settingsWindow = window.screenSaverView.configureSheet;
    if (settingsWindow) {
        [window beginSheet:settingsWindow completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"Response");
        }];
    }
}
    
- (IBAction)newFile:(id)sender {
    [self createNewWindow];
}
    
#pragma mark - NSWindowDelegate
    
-(BOOL)windowShouldClose:(VSSScreenSaverWindow *)sender {
    [self.windows removeObject:sender];
    return YES;
}
    
#pragma mark - Private
    
- (void)createNewWindow {
    VSSScreenSaverWindow *window = [[VSSScreenSaverWindow alloc] init];
    [window center];
    [window makeKeyAndOrderFront:window];
    
    [self.windows addObject:window];
}

@end
