//
//  VSSUserDefaultsSettings.m
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSUserDefaultsSettings.h"
@import ScreenSaver;

#define MuteKey @"mute"
#define URLsKey @"urls"
#define PlayModeKey @"playMode"
#define ShowLabelKey @"showSource"

@interface VSSUserDefaultsSettings ()
@property (nonnull, nonatomic, strong) NSUserDefaults *defaults;
@end

@implementation VSSUserDefaultsSettings

- (instancetype)init {
    self = [super init];
    if (self) {
        self.defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"com.pendowski.VSaver"];
    }
    return self;
}

#pragma mark - VSSSettings

- (BOOL)muteVideos {
    return [self.defaults boolForKey:MuteKey];
}

- (void)setMuteVideos:(BOOL)muteVideos {
    [self.defaults setBool:muteVideos forKey:MuteKey];
    [self.defaults synchronize];
}

- (BOOL)showLabel {
    return [self.defaults boolForKey:ShowLabelKey];
}

- (void)setShowLabel:(BOOL)showLabel {
    [self.defaults setBool:showLabel forKey:ShowLabelKey];
    [self.defaults synchronize];
}

- (VSSPlayMode)playMode {
    return [self.defaults integerForKey:PlayModeKey];
}

- (void)setPlayMode:(VSSPlayMode)playMode {
    [self.defaults setInteger:playMode forKey:PlayModeKey];
    [self.defaults synchronize];
}

- (NSArray<NSString *> *)urls {
    return [self.defaults objectForKey:URLsKey] ?: @[];
}

- (void)setUrls:(NSArray<NSString *> *)urls {
    [self.defaults setObject:urls forKey:URLsKey];
    [self.defaults synchronize];
}

@end
