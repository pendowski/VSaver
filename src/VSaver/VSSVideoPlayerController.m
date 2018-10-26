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

@interface VSSVideoPlayerController ()
@property (nonnull, nonatomic, strong) NSArray<id<VSSProvider> > *providers;
@property (nonnull, nonatomic, strong) NSMutableArray<AVPlayerLayer *> *layers;
@property (nonnull, nonatomic, strong) AVPlayer *player;
@property (nonnull, nonatomic, strong) NSArray<NSURL *> *urls;
@property (nonatomic) NSInteger urlIndex;
@property (nonnull, nonatomic, strong) NSHashTable<id<VSSVideoPlayerControllerDelegate> > *delegates;
@property (nonatomic) CGFloat volumes;
@end

@implementation VSSVideoPlayerController

- (instancetype)initWithProviders:(NSArray<id<VSSProvider> > *)providers
{
    self = [super init];

    if (self) {
        self.providers = providers;
        self.layers = [@[] mutableCopy];
        self.urls = @[];
        self.mode = VSSModeRandom;
        self.delegates = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        self.urlIndex = -1;
        self.player = [[AVPlayer alloc] init];

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
                [[VSSWistiaProvider alloc] init]
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
    [self.player pause];

    self.urlIndex = -1;
    self.urls = urls;

    [self playNext];
}

- (void)registerPlayerLayer:(AVPlayerLayer *)playerLayer
{
    [self.layers addObject:playerLayer];
    playerLayer.player = self.player;
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
    if (self.urls.count == 0) {
        return;
    }

    NSInteger index = self.urlIndex;
    NSInteger total = self.urls.count;
    NSInteger random = arc4random();

    switch (self.mode) {
        case VSSModeRandom:
            index = random % total;
            break;
        case VSSModeSequence:
            index = (index + 1) % total;
            break;
    }

    NSURL *url = self.urls[index];
    id<VSSProvider> provider = [[self.providers vss_filter:^BOOL (id<VSSProvider> _Nonnull provider) {
        return [provider isValidURL:url];
    }] firstObject];

    self.urlIndex = index;

    for (id<VSSVideoPlayerControllerDelegate> delegate in self.delegates) {
        [delegate videoPlayerController:self willLoadVideoWithURL:url];
    }

    __weak typeof(self)weakSelf = self;
    [provider getVideoFromURL:url completion:^(VSSURLItem *_Nullable item) {
        __strong typeof(self) strongSelf = weakSelf;

        if (!strongSelf || !item) {
            return;
        }

        for (id<VSSVideoPlayerControllerDelegate> delegate in strongSelf.delegates) {
            [delegate videoPlayerController:strongSelf didLoadVideoItem:item];
        }

        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:item.url];
        [strongSelf.player replaceCurrentItemWithPlayerItem:playerItem];
        strongSelf.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [strongSelf.player play];
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

@end
