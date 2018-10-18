//
//  AppDelegate.m
//  VSaverTester
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "AppDelegate.h"
#import "VSSScreenSaverWindow.h"
#import "NSObject+Extended.h"
#import "NSArray+Extended.h"

@interface AppDelegate () <NSWindowDelegate>
@property (nonnull, nonatomic, strong) NSMutableArray<VSSScreenSaverWindow *> *windows;
@property (nonnull, nonatomic, strong) NSBundle *screenSaverBundle;
@end

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        self.windows = [@[] mutableCopy];
        
        NSString *screenSaverBundlePath = [[NSBundle mainBundle] pathForResource:@"VSaver" ofType:@"saver"];
        NSAssert(screenSaverBundlePath, @"VSaver target should be built and included in this bundle");
        
        NSBundle *screenSaverBundle = [NSBundle bundleWithPath:screenSaverBundlePath];
        NSError *bundleError;
        if (![screenSaverBundle loadAndReturnError:&bundleError]) {
            NSAssert(false, @"Couldn't load screen saver bundle");
        }
        
        self.screenSaverBundle = screenSaverBundle;
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
    
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender {
    if (self.windows.count == 0) {
        [self createNewWindow];
    }
    return YES;
}
    
#pragma mark - Actions

- (IBAction)openPreferencesSelected: (NSMenuItem *)sender {
    VSSScreenSaverWindow *window = VSSAS([NSApp keyWindow], VSSScreenSaverWindow);
    
    NSWindow *settingsWindow = window.screenSaverView.configureSheet;
    if (settingsWindow) {
        [window beginSheet:settingsWindow completionHandler:^(NSModalResponse returnCode) {
            NSAssert(self.windows.count > 0, @"Since we closed the settings, there has to be at least one window");
            [self.windows vss_forEach:^(VSSScreenSaverWindow * _Nonnull window) {
                [window reloadScreenSaver];
            }];
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
    __weak typeof(self) weakSelf = self;
    VSSScreenSaverWindow *window = [[VSSScreenSaverWindow alloc] initWithScreenSaverViewFactory:^NSView<VSSScreenSaver> *(CGRect frame) {
        __strong typeof(self) strongSelf = weakSelf;
        id principalObject = [[strongSelf.screenSaverBundle principalClass] alloc];
        if (![principalObject conformsToProtocol:@protocol(VSSScreenSaver)] || ![principalObject isKindOfClass:[NSView class]]) {
            principalObject = nil;
            NSAssert(false, @"Principal class isn't a screen saver");
            return nil;
        }
        
        NSView<VSSScreenSaver> *saverView = [principalObject initWithFrame:CGRectZero isPreview:NO];
        saverView.frame = frame;
        return saverView;
    }];
    [window center];
    [window makeKeyAndOrderFront:window];
    
    NSAssert(self.windows, @"There should be a way to store windows");
    [self.windows addObject:window];
}

@end
