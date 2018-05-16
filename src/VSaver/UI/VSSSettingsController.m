//
//  VSSSettingsController.m
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSSettingsController.h"
#import "NSArray+Extended.h"
#import "NSObject+Extended.h"

@interface VSSSettingsController () <NSTableViewDataSource, NSWindowDelegate>
@property (nonnull, nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonnull, nonatomic, strong) IBOutlet NSButton *muteCheckbox;
@property (nonnull, nonatomic, strong) IBOutlet NSButton *sourceCheckbox;
@property (nonnull, nonatomic, strong) IBOutlet NSButton *sameVideoCheckbox;
@property (nonnull, nonatomic, strong) IBOutlet NSSegmentedControl *playModeSelector;
@property (nonnull, nonatomic, strong) NSMutableArray<NSString *> *urls;
@end

@implementation VSSSettingsController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.urls = [@[] mutableCopy];
    
    self.tableView.dataSource = self;
    self.tableView.target = self;
    [self.tableView setDoubleAction:@selector(rowDoubleClicked:)];
}

#pragma mark - NSWindowDelegate

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [self.urls removeAllObjects];
    [self.urls addObjectsFromArray:self.settings.urls];
    
    self.muteCheckbox.state = self.settings.muteVideos ? NSOnState : NSOffState;
    self.sourceCheckbox.state = self.settings.showLabel ? NSOnState : NSOffState;
    self.sameVideoCheckbox.state = self.settings.sameOnAllScreens ? NSOnState : NSOffState;
    
    switch (self.settings.playMode) {
        case VSSPlayModeRandom:
            self.playModeSelector.selectedSegment = 1;
            break;
        case VSSPlayModeSequence:
            self.playModeSelector.selectedSegment = 0;
            break;
    }
    
    [self.tableView reloadData];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    // force commiting changes if some row is in the middle of editing
    [self.tableView editColumn:-1 row:-1 withEvent:nil select:NO];
    
    self.settings.urls = [self.urls vss_map:^id(NSString * _Nonnull url) {
        NSString *cleanUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return cleanUrl.length > 0 ? cleanUrl : nil;
    }];
    self.settings.muteVideos = self.muteCheckbox.state == NSOnState;
    self.settings.showLabel = self.sourceCheckbox.state == NSOnState;
    self.settings.sameOnAllScreens = self.sameVideoCheckbox.state == NSOnState;
    
    switch (self.playModeSelector.selectedSegment) {
        case 0:
            self.settings.playMode = VSSPlayModeSequence;
            break;
        case 1:
            self.settings.playMode = VSSPlayModeRandom;
            break;
        default:
            NSAssert(false, @"");
            break;
    }
    
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.urls.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return self.urls[row];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *previousValue = self.urls[row];
    NSString *url = [VSSAS(object, NSString) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (url) {
        if (url.length == 0 && previousValue.length > 0) {
            [self removeItemAtIndex:row];
        } else {
            self.urls[row] = url;
        }
    }
}

#pragma mark - Actions

- (IBAction)addItemClicked:(NSButton *)sender {
    [self.tableView beginUpdates];
    
    [self.urls addObject:@""];
    NSUInteger rowIndex = self.urls.count - 1;
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:rowIndex] withAnimation:NSTableViewAnimationEffectGap];
    
    [self.tableView endUpdates];
    
    [self.tableView editColumn:0 row:rowIndex withEvent:nil select:YES];
}

- (IBAction)removeItemClicked:(NSButton *)sender {
    NSInteger rowIndex = self.tableView.selectedRow;
    if (rowIndex >= 0 && rowIndex < self.urls.count) {
        [self removeItemAtIndex:rowIndex];
    }
}

- (IBAction)closeWindowClicked:(NSButton *)sender {
    NSWindow *currentWindow = self.window;
    NSWindow *parentWindow = [[NSApp.windows vss_filter:^BOOL(NSWindow *_Nonnull window) {
        return [window.sheets containsObject:currentWindow];
    }] firstObject];
    [parentWindow endSheet:currentWindow];
}

- (IBAction)rowDoubleClicked:(NSTableView *)sender {
    NSInteger rowIndex = self.tableView.clickedRow;
    if (rowIndex == -1) {
        [self addItemClicked:nil];
    } else {
        [sender editColumn:0 row:rowIndex withEvent:nil select:YES];
    }
}

#pragma mark - Private

- (void)removeItemAtIndex:(NSInteger)index {
    [self.tableView beginUpdates];
    
    [self.urls removeObjectAtIndex:index];
    [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationEffectFade];
    
    [self.tableView endUpdates];
}

@end
