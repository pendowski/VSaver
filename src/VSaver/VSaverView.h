//
//  VSaverView.h
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "VSSScreenSaver.h"
#import "VSSVideoPlayerController.h"

@interface VSaverView : ScreenSaverView <VSSScreenSaver>
@property (nonnull, nonatomic, strong) VSSVideoPlayerController *videoController;
@end
