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
@property (nonnull, nonatomic, strong) NSArray<id<VSSProvider>> *providers;
@property (nonnull, nonatomic, strong) NSMutableArray<AVPlayer *> *players;
@property (nonnull, nonatomic, strong) NSArray<NSURL *> *urls;
@property (nonatomic) NSInteger urlIndex;
@property (nonnull, nonatomic, strong) NSHashTable<id<VSSVideoPlayerControllerDelegate>> *delegates;
@property (nonatomic) CGFloat volumes;
@end

@implementation VSSVideoPlayerController

- (instancetype)initWithProviders:(NSArray<id<VSSProvider>> *)providers {
    self = [super init];
    
    if (self) {
        self.providers = providers;
        self.players = [@[] mutableCopy];
        self.urls = @[];
        self.mode = VSSModeRandom;
        self.delegates = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        self.urlIndex = -1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFail:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    }
    
    return self;
}

- (instancetype)initWithCommonProviders {
    return [self initWithProviders:@[
                                     [[VSSAppleTVProvider alloc] init],
                                     [[VSSYouTubeProvider alloc] init],
                                     [[VSSVimeoProvider alloc] init],
                                     [[VSSWistiaProvider alloc] init]
                                     ]];
}

#pragma mark - Static

+ (instancetype)sharedPlayerController {
    static VSSVideoPlayerController *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] initWithCommonProviders];
    });
    return shareObject;
}

#pragma mark - Public

- (void)setQueue: (NSArray<NSURL *> *)urls {
    [self.players vss_forEach:^(AVPlayer *player) {
        [player pause];
    }];
    
    self.urlIndex = -1;
    self.urls = urls;
    
    [self playNext];
}

- (void)addPlayer: (AVPlayer *)player {
    [self.players addObject:player];
    player.volume = self.volumes;
}

- (void)addDelegate: (id<VSSVideoPlayerControllerDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)setVolume: (CGFloat)volume {
    self.volumes = volume;
    [self.players vss_forEach:^(AVPlayer *player) {
        player.volume = volume;
    }];
}

#pragma mark - Notifications

- (void)videoDidEnd: (NSNotification *)notifications {
    [self playNext];
}

- (void)videoDidFail: (NSNotification *)notifications {
    [self playNext];
}

#pragma mark - Private

- (void)playNext {
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
    id<VSSProvider> provider = [[self.providers vss_filter:^BOOL(id<VSSProvider> _Nonnull provider) {
        return [provider isValidURL:url];
    }] firstObject];
    
    self.urlIndex = index;
    
    for (id<VSSVideoPlayerControllerDelegate> delegate in self.delegates) {
        [delegate videoPlayerController:self willLoadVideoWithURL:url];
    }
    
    __weak typeof(self) weakSelf = self;
    [provider getVideoFromURL:url completion:^(VSSURLItem * _Nullable item) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (!strongSelf || !item) {
            return;
        }
        
        for (id<VSSVideoPlayerControllerDelegate> delegate in strongSelf.delegates) {
            [delegate videoPlayerController:strongSelf didLoadVideoItem:item];
        }
        
        for (AVPlayer *player in strongSelf.players) {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:item.url];
            [player replaceCurrentItemWithPlayerItem:playerItem];
            player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            [player play];
        }
    }];
}

@end

