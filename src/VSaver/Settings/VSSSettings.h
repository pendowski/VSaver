//
//  VSSSettings.h
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

typedef NS_ENUM(NSInteger, VSSPlayMode) {
    VSSPlayModeSequence = 0,
    VSSPlayModeRandom = 1
};

@protocol VSSSettings <NSObject>
@property (nonnull, nonatomic, strong) NSArray<NSString *> *urls;
@property (nonatomic) BOOL muteVideos;
@property (nonatomic) BOOL showLabel;
@property (nonatomic) VSSPlayMode playMode;
@property (nonatomic) BOOL sameOnAllScreens;
@end
