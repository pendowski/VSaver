//
//  AppDelegate.m
//  VSaverWallpaper
//
//  Created by Jarek Pendowski on 09/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "AppDelegate.h"
#import "VSSWallpaperOptionsController.h"
#import "VSSScreenSaverWindow.h"
#import "NSArray+Extended.h"

@interface AppDelegate () <VSSWallpaperOptionsControllerDelegate>
@property (nonnull, nonatomic, strong) NSArray<VSSScreenSaverWindow *> *windows;
@property (nonnull, nonatomic, strong) NSStatusItem *statusBarItem;
@property (nonnull, nonatomic, strong) NSPopover *popover;
@property (nonnull, nonatomic, strong) NSBundle *screenSaverBundle;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *screenSaverBundlePath = [[NSBundle mainBundle] pathForResource:@"VSaver" ofType:@"saver"];
    NSAssert(screenSaverBundlePath, @"VSaver target should be built and included in this bundle");

    NSBundle *screenSaverBundle = [NSBundle bundleWithPath:screenSaverBundlePath];
    NSError *bundleError;
    if (![screenSaverBundle loadAndReturnError:&bundleError]) {
        NSAssert(false, @"Couldn't load screen saver bundle");
    }

    self.screenSaverBundle = screenSaverBundle;

    VSSWallpaperOptionsController *optionsController = [[VSSWallpaperOptionsController alloc] initWithNibName:NSStringFromClass([VSSWallpaperOptionsController class]) bundle:nil];
    optionsController.delegate = self;

    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = optionsController;
    self.popover = popover;

    [self setupStatusBar];

    [self recreateWindows];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

#pragma mark - Action

- (IBAction)statusItemTapped:(id)sender
{
    if (self.popover.isShown) {
        [self.popover close];
    } else {
        NSStatusBarButton *button = self.statusBarItem.button;
        [self.popover showRelativeToRect:button.bounds ofView:button preferredEdge:NSMinYEdge];
    }
}

#pragma mark - VSSWallpaperOptionsControllerDelegate

- (void)wallpaperOptionsControllerDidChooseReload:(VSSWallpaperOptionsController *)controller
{
    [self.popover close];
    [self recreateWindows];
}

- (void)wallpaperOptionsControllerDidChooseSettings:(VSSWallpaperOptionsController *)controller
{
    NSWindow *settingsWindow = [[[self.windows firstObject] screenSaverView] configureSheet];
    __weak typeof(self)weakSelf = self;
    [controller.view.window beginSheet:settingsWindow completionHandler:^(NSModalResponse returnCode) {
        [weakSelf.windows vss_forEach:^(VSSScreenSaverWindow *_Nonnull window) {
            [window reloadScreenSaver];
        }];
        [weakSelf.popover close];
    }];
}

- (void)wallpaperOptionsControllerDidChooseClose:(VSSWallpaperOptionsController *)controller
{
    [self.popover close];
    [NSApp terminate:nil];
}

#pragma mark - Private

- (void)recreateWindows
{
    [self.windows vss_forEach:^(VSSScreenSaverWindow *_Nonnull window) {
        [window close];
    }];

    self.windows = [[NSScreen screens] vss_map:^id _Nullable (NSScreen *_Nonnull screen) {
        return [self createWindowOnScreen:screen];
    }];
}

- (void)setupStatusBar
{
    NSImage *icon = [NSImage imageNamed:@"icon_16x16"];
    [icon setTemplate:YES];

    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:-1];
    statusItem.button.image = icon;
    statusItem.highlightMode = YES;
    statusItem.target = self;
    statusItem.action = @selector(statusItemTapped:);

    self.statusBarItem = statusItem;
}

- (VSSScreenSaverWindow *)createWindowOnScreen:(NSScreen *)screen
{
    __weak typeof(self)weakSelf = self;
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
    } styleMask:NSWindowStyleMaskBorderless screen:screen coverFullScreen:YES];
    window.level = CGWindowLevelForKey(kCGDesktopWindowLevelKey);
    window.backgroundColor = [NSColor blackColor];
    [window setReleasedWhenClosed:NO];
    window.ignoresMouseEvents = YES;

    [window orderFront:nil];

    return window;
}

@end
