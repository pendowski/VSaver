//
//  VSaverView.m
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSaverView.h"
@import AVKit;
@import AVFoundation;
@import QuartzCore;
#import "VSSVideoPlayerController.h"
#import "VSSSettings.h"
#import "VSSSettingsController.h"
#import "VSSUserDefaultsSettings.h"
#import "NSArray+Extended.h"
#import "NSObject+Extended.h"

@interface VSaverView () <VSSVideoPlayerControllerDelegate>
@property (nullable, nonatomic, weak) NSProgressIndicator *loadingIndicator;
@property (nullable, nonatomic, weak) NSTextField *sourceLabel;
@property (nullable, nonatomic, weak) AVPlayerLayer *playerLayer;

@property (nonnull, nonatomic, strong) id<VSSSettings> settings;
@property (nullable, nonatomic, strong) NSWindowController *settingsController;
@end

@implementation VSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
        self.wantsLayer = YES;
        
        self.settings = [[VSSUserDefaultsSettings alloc] init];
        
        self.layer.backgroundColor = [NSColor blackColor].CGColor;
        self.layer.frame = self.bounds;
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
        playerLayer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        playerLayer.frame = self.bounds;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.playerLayer = playerLayer;
        
        [self.layer addSublayer:playerLayer];
        
        NSProgressIndicator *activityIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 64, 64)];
        [activityIndicator setDisplayedWhenStopped:NO];
        activityIndicator.style = NSProgressIndicatorSpinningStyle;
        activityIndicator.controlSize = NSControlSizeRegular;
        [activityIndicator sizeToFit];
        
        CIFilter *brightFilter = [CIFilter filterWithName:@"CIColorControls"];
        [brightFilter setDefaults];
        [brightFilter setValue:@1 forKey:@"inputBrightness"];

        if (brightFilter) {
            activityIndicator.contentFilters = @[brightFilter];
        }
        
        CGRect activityFrame = CGRectMake(frame.size.width / 2 - activityIndicator.frame.size.width / 2,
                                  frame.size.height / 2 - activityIndicator.frame.size.height / 2,
                                  activityIndicator.frame.size.width,
                                  activityIndicator.frame.size.height);
        activityIndicator.frame = activityFrame;
        activityIndicator.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        
        [self addSubview:activityIndicator];
        self.loadingIndicator = activityIndicator;
        
        NSTextField *label = [NSTextField labelWithString:@"VSaver"];
        label.textColor = [NSColor whiteColor];
        label.alphaValue = 0.3;
        [label sizeToFit];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:label];
        
        CGFloat labelMargin = 20;
        CGFloat labelHeight = label.bounds.size.height;
        NSDictionary *layoutViews = @{ @"label": label };
        NSMutableArray<NSLayoutConstraint *> *labelConstraints = [NSMutableArray array];
        [labelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%0.0f-[label]-%0.0f-|", labelMargin, labelMargin] options:0 metrics:nil views:layoutViews]];
        [labelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(>=%0.0f)-[label(%0.0f)]-|", labelMargin, labelHeight] options:0 metrics:nil views:layoutViews]];
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        [label setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
        [NSLayoutConstraint activateConstraints:labelConstraints];
        
        self.sourceLabel = label;
        
        VSSSettingsController *settingsController = [[VSSSettingsController alloc] initWithWindowNibName:@"VSSSettingsController"];
        settingsController.settings = self.settings;
        self.settingsController = settingsController;
    }
    return self;
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    
    if (self.window == nil) { return; }
    VSSQualityPreference qualityPreference = self.settings.qualityPreference;
    
    BOOL (^containsSup1080Screen)(NSArray<NSScreen *> *) = ^BOOL(NSArray<NSScreen *> * screens) {
        return [screens vss_filter:^BOOL(NSScreen *screen) {
            return screen.frame.size.height * screen.backingScaleFactor > 1080;
        }].count > 0;
    };
    
    VSSVideoPlayerController *videoController;
    if (self.settings.sameOnAllScreens) {
        videoController = [VSSVideoPlayerController sharedPlayerController];
        videoController.use4KVideoIfAvailable = qualityPreference == VSSQualityPreference4K || (qualityPreference == VSSQualityPreferenceAdjust && containsSup1080Screen([NSScreen screens]));
    } else {
        videoController = [[VSSVideoPlayerController alloc] initWithCommonProviders];
        videoController.use4KVideoIfAvailable = qualityPreference == VSSQualityPreference4K || (qualityPreference == VSSQualityPreferenceAdjust && containsSup1080Screen(@[self.window.screen]));
    }
    [videoController registerPlayerLayer:self.playerLayer];
    [videoController addDelegate:self];
    
    self.videoController = videoController;
    
    [self.sourceLabel setHidden:!self.settings.showLabel];
    
    [self reloadAndPlay];
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    return;
}

- (BOOL)hasConfigureSheet
{
    return self.settingsController != nil;
}

- (NSWindow*)configureSheet
{
    return self.settingsController.window;
}

#pragma mark - VSSVideoPlayerControllerDelegate

- (void)videoPlayerController: (VSSVideoPlayerController *)controller willLoadVideoWithURL: (NSURL *)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:self.loadingIndicator];
        [self.loadingIndicator startAnimation:nil];
    });
}
    
- (void)videoPlayerController: (VSSVideoPlayerController *)controller didLoadVideoItem: (VSSURLItem *)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimation:nil];
        [self.loadingIndicator removeFromSuperview];
        
        self.sourceLabel.stringValue = url.title != nil ? url.title : @"";
    });
}

#pragma mark - Private

- (void)reloadAndPlay {
    NSArray<NSURL *> *urls = [self.settings.urls vss_map:^id _Nullable(NSString * _Nonnull url) {
        return [NSURL URLWithString:url];
    }];
    [self.videoController setQueue:urls];
}

@end
