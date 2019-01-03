//
//  VSSUserDefaultsSettings.m
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSUserDefaultsSettings.h"
@import ScreenSaver;

#define MuteKey             @"mute"
#define URLsKey             @"urls"
#define PlayModeKey         @"playMode"
#define ShowLabelKey        @"showSource"
#define SameOnAllScreensKey @"sameOnAllScreens"
#define QualityPreference   @"qualityPreference"
#define LastVersion         @"lastVersion"

@interface VSSUserDefaultsSettings ()
@property (nonnull, nonatomic, strong) NSUserDefaults *defaults;
@end

@implementation VSSUserDefaultsSettings

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"com.pendowski.VSaver"];
    }
    return self;
}

#pragma mark - VSSSettings

- (BOOL)muteVideos
{
    return [self.defaults boolForKey:MuteKey];
}

- (void)setMuteVideos:(BOOL)muteVideos
{
    [self.defaults setBool:muteVideos forKey:MuteKey];
}

- (BOOL)showLabel
{
    return [self.defaults boolForKey:ShowLabelKey];
}

- (void)setShowLabel:(BOOL)showLabel
{
    [self.defaults setBool:showLabel forKey:ShowLabelKey];
}

- (VSSPlayMode)playMode
{
    return [self.defaults integerForKey:PlayModeKey];
}

- (void)setPlayMode:(VSSPlayMode)playMode
{
    [self.defaults setInteger:playMode forKey:PlayModeKey];
}

- (NSArray<NSString *> *)urls
{
    return [self.defaults objectForKey:URLsKey] ? : @[];
}

- (void)setUrls:(NSArray<NSString *> *)urls
{
    [self.defaults setObject:urls forKey:URLsKey];
}

- (BOOL)sameOnAllScreens
{
    return [self.defaults objectForKey:SameOnAllScreensKey] ? [self.defaults boolForKey:SameOnAllScreensKey] : YES;
}

- (void)setSameOnAllScreens:(BOOL)sameOnAllScreens
{
    [self.defaults setBool:sameOnAllScreens forKey:SameOnAllScreensKey];
}

- (VSSQualityPreference)qualityPreference
{
    return [self.defaults integerForKey:QualityPreference];
}

- (void)setQualityPreference:(VSSQualityPreference)qualityPreference
{
    [self.defaults setInteger:qualityPreference forKey:QualityPreference];
}

- (NSString *)lastVersion
{
    return [self.defaults stringForKey:LastVersion];
}

- (void)setLastVersion:(NSString *)lastVersion
{
    [self.defaults setObject:lastVersion forKey:LastVersion];
}

@end

@implementation VSSLogger (VSSUserDefaultsSettings)

- (void)logSettings:(VSSUserDefaultsSettings *)settings
{
    if (!settings) { return; }
    NSDictionary *dictionary = @{
                                 MuteKey: @(settings.muteVideos),
                                 PlayModeKey: @(settings.playMode),
                                 ShowLabelKey: @(settings.showLabel),
                                 SameOnAllScreensKey: @(settings.sameOnAllScreens),
                                 QualityPreference: @(settings.qualityPreference),
                                 LastVersion: settings.lastVersion ?: @"-"
                                 };
    [self log:@"Settings: %@", dictionary];
}

@end
