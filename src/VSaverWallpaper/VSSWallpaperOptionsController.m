//
//  VSSWallpaperOptionsController.m
//  VSaverWallpaper
//
//  Created by Jarek Pendowski on 09/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSWallpaperOptionsController.h"

@interface VSSWallpaperOptionsController ()

@end

@implementation VSSWallpaperOptionsController

#pragma mark - Actions

- (IBAction)closeTapped:(id)sender
{
    [self.delegate wallpaperOptionsControllerDidChooseClose:self];
}

- (IBAction)settingsTapped:(id)sender
{
    [self.delegate wallpaperOptionsControllerDidChooseSettings:self];
}

- (IBAction)reloadTapped:(id)sender
{
    [self.delegate wallpaperOptionsControllerDidChooseReload:self];
}

@end
