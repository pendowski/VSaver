//
//  VSSVideoPlayerController.h
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

@import AVFoundation;
#import <Foundation/Foundation.h>
#import "VSSProvider.h"
#import "VSSScreenSaver.h"

typedef NS_ENUM (NSInteger, VSSMode) {
    VSSModeRandom,
    VSSModeSequence
};

@class VSSVideoPlayerController;

@protocol VSSVideoPlayerControllerDelegate <NSObject>
- (void)videoPlayerController:(VSSVideoPlayerController *)controller willLoadVideoWithURL:(NSURL *)url;
- (void)videoPlayerController:(VSSVideoPlayerController *)controller didLoadVideoItem:(VSSURLItem *)url;
@end

@interface VSSVideoPlayerController : NSObject <VSScreenVideoController>
@property (nonatomic) VSSMode mode;
@property (nonatomic) BOOL use4KVideoIfAvailable;

+ (instancetype)sharedPlayerController;

- (instancetype)initWithProviders:(NSArray<id<VSSProvider> > *)providers;
- (instancetype)initWithCommonProviders;

- (void)setQueue:(NSArray<NSURL *> *)urls;
- (void)registerPlayerLayer:(AVPlayerLayer *)playerLayer;
- (void)unregisterPlayerLayer:(AVPlayerLayer *)playerLayer;
- (void)playIfNeeded;

- (void)addDelegate:(id<VSSVideoPlayerControllerDelegate>)delegate;
- (void)setVolume:(CGFloat)volume;
- (void)playNext;

@end
