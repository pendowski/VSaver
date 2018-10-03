//
//  VSSScreenSaver.h
//  VSaver
//
//  Created by Jarek Pendowski on 09/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//
#import <Cocoa/Cocoa.h>

@protocol VSScreenVideoController <NSObject>
- (void)playNext;
@end

@protocol VSSScreenSaver <NSObject>
@property (nonatomic, strong, readonly) id<VSScreenVideoController> videoController;
- (nullable instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)preview;
- (NSWindow*)configureSheet;
@end
