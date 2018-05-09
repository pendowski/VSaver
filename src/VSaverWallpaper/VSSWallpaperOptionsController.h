//
//  VSSWallpaperOptionsController.h
//  VSaverWallpaper
//
//  Created by Jarek Pendowski on 09/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSSWallpaperOptionsController;

@protocol VSSWallpaperOptionsControllerDelegate <NSObject>
- (void)wallpaperOptionsControllerDidChooseClose:(VSSWallpaperOptionsController *)controller;
- (void)wallpaperOptionsControllerDidChooseReload:(VSSWallpaperOptionsController *)controller;
- (void)wallpaperOptionsControllerDidChooseSettings:(VSSWallpaperOptionsController *)controller;
@end

@interface VSSWallpaperOptionsController : NSViewController
@property (nullable, nonatomic, weak) id<VSSWallpaperOptionsControllerDelegate> delegate;
@end
