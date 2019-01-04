//
//  VSSSettings.h
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

typedef NS_ENUM (NSInteger, VSSPlayMode) {
    VSSPlayModeSequence = 0,
    VSSPlayModeRandom   = 1
};

typedef NS_ENUM (NSInteger, VSSQualityPreference) {
    VSSQualityPreferenceAdjust = 0,
    VSSQualityPreference1080p  = 1,
    VSSQualityPreference4K     = 2
};

@protocol VSSSettings <NSObject>
@property (nonnull, nonatomic, strong) NSArray<NSString *> *urls;
@property (nonatomic) BOOL muteVideos;
@property (nonatomic) BOOL showLabel;
@property (nonatomic) VSSPlayMode playMode;
@property (nonatomic) BOOL sameOnAllScreens;
@property (nonatomic) VSSQualityPreference qualityPreference;

@property (nullable, nonatomic, copy) NSString *lastVersion;
@property (nullable, nonatomic, strong) NSDate *lastUpdateCheckedAt;
@end
