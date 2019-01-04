//
//  VSSActivitityIndicator.m
//  VSaver
//
//  Created by Jarek Pendowski on 04/01/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import "VSSActivityIndicator.h"
@import QuartzCore;

@interface VSSActivityIndicator ()
@property (nullable, nonatomic, strong) NSTimer *spawnTimer;
@property (nonnull, nonatomic, strong) NSMutableSet *circles;
@end

@implementation VSSActivityIndicator

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    [self commonInit];
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    [self commonInit];
    return self;
}

- (void)commonInit
{
    self.wantsLayer = YES;
    
    self.lineWidth = 4;
    self.mainColor = [NSColor whiteColor];
    
    self.circles = [NSMutableSet set];
}

- (void)startAnimation
{
    if (self.spawnTimer != nil) {
        return;
    }
    self.spawnTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(cleanUpAndSpawnNewCircle) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
    [self.spawnTimer invalidate];
    self.spawnTimer = nil;
    
    for (CAShapeLayer *circle in self.circles) {
        [circle removeAllAnimations];
        [circle removeFromSuperlayer];
    }
    [self.circles removeAllObjects];
}

#pragma mark - private

- (void)cleanUpAndSpawnNewCircle
{
    [self cleanUpUsedCircles];
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.frame = self.bounds;
    circle.strokeColor = self.mainColor.CGColor;
    circle.fillColor = [NSColor clearColor].CGColor;
    circle.lineWidth = self.lineWidth;

    CGRect innerRect = CGRectInset(self.bounds, self.lineWidth / 2, self.lineWidth / 2);
    CGPathRef path = CGPathCreateWithRoundedRect(innerRect, innerRect.size.width / 2, innerRect.size.height / 2, nil);
    circle.path = path;
    circle.opacity = 0;
    CGPathRelease(path);
    
    [self.layer addSublayer:circle];
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = 1.2;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    scale.values = @[@0, @1, @0.9, @1, @0.9];
    scale.keyTimes = @[@0, @0.8, @0.85, @0.9, @1];
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.duration = 1.4;
    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fade.fromValue = @1;
    fade.toValue = @0;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.duration = 1;
    animations.animations = @[ scale, fade ];
    animations.removedOnCompletion = YES;
    
    [circle addAnimation:animations forKey:@"fadeOut"];
    
    [self.circles addObject:circle];
}

- (void)cleanUpUsedCircles
{
    for (CAShapeLayer *layer in [self.circles copy]) {
        if (layer.presentationLayer.opacity == 0) {
            [layer removeFromSuperlayer];
            [self.circles removeObject:layer];
        }
    }
}

@end
