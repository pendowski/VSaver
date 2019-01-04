//
//  VSSActivitityIndicator.h
//  VSaver
//
//  Created by Jarek Pendowski on 04/01/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface VSSActivityIndicator : NSView
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) NSColor *mainColor;

- (void)startAnimation;
- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
