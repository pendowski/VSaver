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
    VSaverView *saverView = [[VSaverView alloc] initWithFrame:CGRectZero isPreview:NO];
    VSSScreenSaverWindow *window = [[VSSScreenSaverWindow alloc] initWithScreenSaverView:saverView];
    [window center];
    [window makeKeyAndOrderFront:window];
    
    [self.windows addObject:window];
}

@end
