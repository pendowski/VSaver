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

typedef NS_ENUM(NSInteger, VSSMode) {
    VSSModeRandom,
    VSSModeSequence
};

@class VSSVideoPlayerController;

@protocol VSSVideoPlayerControllerDelegate <NSObject>
- (void)videoPlayerController: (VSSVideoPlayerController *)controller willLoadVideoWithURL: (NSURL *)url;
- (void)videoPlayerController: (VSSVideoPlayerController *)controller didLoadVideoItem: (VSSURLItem *)url;
@end

@interface VSSVideoPlayerController : NSObject
@property (nonatomic) VSSMode mode;

+ (instancetype)sharedPlayerController;

- (instancetype)initWithProviders: (NSArray<id<VSSProvider>> *)providers;
- (instancetype)initWithCommonProviders;

- (void)setQueue: (NSArray<NSURL *> *)urls;
- (void)addPlayer: (AVPlayer *)player;
- (void)addDelegate: (id<VSSVideoPlayerControllerDelegate>)delegate;
- (void)setVolume: (CGFloat)volume;

@end
