//
//  VSSVideoPlayerController.m
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSVideoPlayerController.h"
#import "NSArray+Extended.h"
#import "VSSAppleTVProvider.h"
#import "VSSVimeoProvider.h"
#import "VSSYouTubeProvider.h"
#import "VSSWistiaProvider.h"
#import "VSSUStreamProvider.h"

#define MinimalTransitionTime 3.0

@interface VSSVideoPlayerController ()
@property (nonnull, nonatomic, strong) NSArray<id<VSSProvider> > *providers;
@property (nonnull, nonatomic, strong) NSMutableSet<AVPlayerLayer *> *layers;
@property (nonnull, nonatomic, strong) AVPlayer *player;
@property (nonnull, nonatomic, strong) NSArray<NSURL *> *urls;
@property (nonatomic) NSInteger urlIndex;
@property (nonnull, nonatomic, strong) NSHashTable<id<VSSVideoPlayerControllerDelegate> > *delegates;
@property (nonatomic) CGFloat volumes;
@property (nonatomic) BOOL isPlaying;
@end

@implementation VSSVideoPlayerController

- (instancetype)initWithProviders:(NSArray<id<VSSProvider> > *)providers
{
    self = [super init];

    if (self) {
        self.providers = providers;
        self.layers = [NSMutableSet set];
        self.urls = @[];
        self.mode = VSSPlayModeRandom;
        self.delegates = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        self.urlIndex = -1;
        self.player = [[AVPlayer alloc] init];
        self.player.allowsExternalPlayback = NO;

        [self setup4KProvidersProviders];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFail:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    }

    return self;
}

- (instancetype)initWithCommonProviders
{
    self.use4KVideoIfAvailable = NO;

    return [self initWithProviders:@[
                [[VSSAppleTVProvider alloc] init],
                [[VSSYouTubeProvider alloc] init],
                [[VSSVimeoProvider alloc] init],
                [[VSSWistiaProvider alloc] init],
                [[VSSUstreamProvider alloc] init]
    ]];
}

#pragma mark - Static

+ (instancetype)sharedPlayerController
{
    static VSSVideoPlayerController *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] initWithCommonProviders];
    });
    return shareObject;
}

#pragma mark - Properties

- (void)setUse4KVideoIfAvailable:(BOOL)isOnSup1080Screen
{
    _use4KVideoIfAvailable = isOnSup1080Screen;

    [self setup4KProvidersProviders];
}

#pragma mark - Public

- (void)setQueue:(NSArray<NSURL *> *)urls
{
    if ([self.urls isEqualToArray:urls]) {
        return [self playIfNeeded];
    }
    
    self.isPlaying = NO;
    [self.player pause];

    self.urlIndex = -1;
    self.urls = urls;

    [self playIfNeeded];
}

- (void)registerPlayerLayer:(AVPlayerLayer *)playerLayer
{
    [self.layers addObject:playerLayer];
    playerLayer.player = self.player;
    
    [self playIfNeeded];
}

- (void)unregisterPlayerLayer:(AVPlayerLayer *)playerLayer
{
    [self.layers removeObject:playerLayer];
    if (self.layers.count == 0) {
        [self.player pause];
        self.isPlaying = NO;
    }
}

- (void)addDelegate:(id<VSSVideoPlayerControllerDelegate>)delegate
{
    [self.delegates addObject:delegate];
}

- (void)setVolume:(CGFloat)volume
{
    self.player.volume = volume;
}

- (void)playNext
{
    if (self.urls.count == 0 || self.layers.count == 0) {
        return;
    }
    
    self.isPlaying = YES;

    NSInteger index = self.urlIndex;
    NSInteger total = self.urls.count;
    NSInteger random = arc4random();

    switch (self.mode) {
        case VSSPlayModeRandom:
            index = random % total;
            break;
        case VSSPlayModeSequence:
            index = (index + 1) % total;
            break;
    }

    NSURL *url = self.urls[index];
    id<VSSProvider> provider = [[self.providers vss_filter:^BOOL (id<VSSProvider> _Nonnull provider) {
        return [provider isValidURL:url];
    }] firstObject];

    self.urlIndex = index;
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];

    for (id<VSSVideoPlayerControllerDelegate> delegate in self.delegates) {
        [delegate videoPlayerController:self willLoadVideoWithURL:url];
    }

    CFAbsoluteTime beginTime = CFAbsoluteTimeGetCurrent();
    
    __weak typeof(self)weakSelf = self;
    [provider getVideoFromURL:url completion:^(VSSURLItem *_Nullable item) {
        __strong typeof(self) strongSelf = weakSelf;

        if (!strongSelf || !item) {
            weakSelf.isPlaying = NO;
            return;
        }
        
        // Load and start playing as soon as possible
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:item.url];
            [strongSelf.player replaceCurrentItemWithPlayerItem:playerItem];
            strongSelf.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [strongSelf.player play];
            if (item.beginTime > 0) {
                [strongSelf.player seekToTime:CMTimeMakeWithSeconds(item.beginTime, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero ];
            }
        });
        
        // But if the internet is super quick we'll compensate here for more pleasing transition between videos
        CFAbsoluteTime finishTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime delay = MAX(MIN(MinimalTransitionTime - (finishTime - beginTime), MinimalTransitionTime), 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (id<VSSVideoPlayerControllerDelegate> delegate in strongSelf.delegates) {
                [delegate videoPlayerController:strongSelf didLoadVideoItem:item];
            }
        });
    }];
}

#pragma mark - Notifications

- (void)videoDidEnd:(NSNotification *)notification
{
    if (notification.object == self.player.currentItem) {
        [self playNext];
    }
}

- (void)videoDidFail:(NSNotification *)notification
{
    if (notification.object == self.player.currentItem) {
        [self playNext];
    }
}

#pragma mark - Private

- (void)setup4KProvidersProviders
{
    [[self.providers vss_filter:^BOOL (id _Nonnull obj) {
        return [obj conformsToProtocol:@protocol(VSSSupports4KQuality)];
    }] vss_forEach:^(id<VSSSupports4KQuality> _Nonnull obj) {
        obj.shouldUse4K = self.use4KVideoIfAvailable;
    }];
}

- (void)playIfNeeded
{
    if (!self.isPlaying && self.layers.count > 0 && self.urls.count > 0) {
        [self playNext];
    }
}

@end
