//
//  YMSquareGestureRecognizer.m
//  CustomGestureDemo
//
//  Created by Alex Shevlyakov on 17/09/15.
//  Copyright (c) 2015 Alex Shevlyakov. All rights reserved.
//

#import "YMSquareGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

static CGFloat const kMaxDeviation = 44.0f;

typedef NS_ENUM(NSUInteger, YMGestureDirection) {
    YMGestureDirectionUnknown,
    YMGestureDirectionLeft,
    YMGestureDirectionRight,
    YMGestureDirectionUp,
    YMGestureDirectionDown
};

@interface YMSquareGestureRecognizer ()

@property (nonatomic, assign) CGPoint topLeftCornerPoint;
@property (nonatomic, assign) CGPoint bottomLeftCornerPoint;
@property (nonatomic, assign) CGPoint topRightCornerPoint;
@property (nonatomic, assign) CGPoint bottomRightCornerPoint;

@property (nonatomic, assign) YMGestureDirection direction;

@end

@implementation YMSquareGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        _bottomLeftCornerPoint  = CGPointZero;
        _topLeftCornerPoint     = CGPointZero;
        _topRightCornerPoint    = CGPointZero;
        _bottomRightCornerPoint = CGPointZero;
        _direction = YMGestureDirectionUnknown;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        self.bottomLeftCornerPoint = [self pointWithTouch:touches.anyObject];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    switch (self.direction) {
        case YMGestureDirectionUnknown:
        {
            CGPoint currentPoint = [self pointWithTouch:touches.anyObject];
            if ([self isDirectionUpWithAnchorPoint:self.bottomLeftCornerPoint
                                     previousPoint:self.bottomLeftCornerPoint
                                      currentPoint:currentPoint]) {
                self.direction = YMGestureDirectionUp;
            } else {
                self.state = UIGestureRecognizerStateFailed;
            }
            break;
        }
            
        case YMGestureDirectionUp:
        {
            CGPoint currentPoint  = [self pointWithTouch:touches.anyObject];
            CGPoint previousPoint = [self previousPointWithTouch:touches.anyObject];
            if (![self isDirectionUpWithAnchorPoint:self.bottomLeftCornerPoint previousPoint:previousPoint currentPoint:currentPoint]) {
                if ([self isDirectionRightWithAnchorPoint:previousPoint previousPoint:previousPoint currentPoint:currentPoint]) {
                    self.topLeftCornerPoint = currentPoint;
                    self.direction = YMGestureDirectionRight;
                } else {
                    self.state = UIGestureRecognizerStateFailed;
                }
            }
            break;
        }
            
        case YMGestureDirectionRight:
        {
            CGPoint currentPoint  = [self pointWithTouch:touches.anyObject];
            CGPoint previousPoint = [self previousPointWithTouch:touches.anyObject];
            if (![self isDirectionRightWithAnchorPoint:self.topLeftCornerPoint previousPoint:previousPoint currentPoint:currentPoint]) {
                if ([self isDirectionDownWithAnchorPoint:previousPoint previousPoint:previousPoint currentPoint:currentPoint]) {
                    self.topRightCornerPoint = currentPoint;
                    self.direction = YMGestureDirectionDown;
                } else {
                    self.state = UIGestureRecognizerStateFailed;
                }
            }
            break;
        }
            
        case YMGestureDirectionDown:
        {
            CGPoint currentPoint  = [self pointWithTouch:touches.anyObject];
            CGPoint previousPoint = [self previousPointWithTouch:touches.anyObject];
            if (![self isDirectionDownWithAnchorPoint:self.topRightCornerPoint previousPoint:previousPoint currentPoint:currentPoint]) {
                if ([self isDirectionLeftWithAnchorPoint:previousPoint previousPoint:previousPoint currentPoint:currentPoint]) {
                    self.bottomRightCornerPoint = currentPoint;
                    self.direction = YMGestureDirectionLeft;
                } else {
                    self.state = UIGestureRecognizerStateFailed;
                }
            }
            break;
        }
            
        case YMGestureDirectionLeft:
        {
            CGPoint currentPoint  = [self pointWithTouch:touches.anyObject];
            CGPoint previousPoint = [self previousPointWithTouch:touches.anyObject];
            if (![self isDirectionLeftWithAnchorPoint:self.bottomRightCornerPoint previousPoint:previousPoint currentPoint:currentPoint]) {
                self.state = UIGestureRecognizerStateFailed;
            }
            break;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    CGPoint currentPoint = [self pointWithTouch:touches.anyObject];
    if (self.state == UIGestureRecognizerStatePossible &&
        self.direction == YMGestureDirectionLeft &&
        fabs(self.bottomLeftCornerPoint.x - currentPoint.x) <= kMaxDeviation &&
        fabs(self.bottomLeftCornerPoint.y - currentPoint.y) <= kMaxDeviation)
    {
        self.state = UIGestureRecognizerStateRecognized;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

- (void)reset
{
    [super reset];
    
    self.direction = YMGestureDirectionUnknown;
    
    self.bottomLeftCornerPoint  = CGPointZero;
    self.topLeftCornerPoint     = CGPointZero;
    self.topRightCornerPoint    = CGPointZero;
    self.bottomRightCornerPoint = CGPointZero;
}



- (BOOL)isDirectionUpWithAnchorPoint:(CGPoint)anchorPoint
                       previousPoint:(CGPoint)previousPoint
                        currentPoint:(CGPoint)currentPoint
{
    return (fabs(anchorPoint.x - currentPoint.x) < kMaxDeviation) && (currentPoint.y <= previousPoint.y);
}

- (BOOL)isDirectionRightWithAnchorPoint:(CGPoint)anchorPoint
                          previousPoint:(CGPoint)previousPoint
                           currentPoint:(CGPoint)currentPoint
{
    return (fabs(anchorPoint.y - currentPoint.y) < kMaxDeviation) && (currentPoint.x >= previousPoint.x);
}

- (BOOL)isDirectionDownWithAnchorPoint:(CGPoint)anchorPoint
                         previousPoint:(CGPoint)previousPoint
                          currentPoint:(CGPoint)currentPoint
{
    return (fabs(anchorPoint.x - currentPoint.x) < kMaxDeviation) && (currentPoint.y >= previousPoint.y);
}

- (BOOL)isDirectionLeftWithAnchorPoint:(CGPoint)anchorPoint
                         previousPoint:(CGPoint)previousPoint
                          currentPoint:(CGPoint)currentPoint
{
    return (fabs(anchorPoint.y - currentPoint.y) < kMaxDeviation) && (currentPoint.x <= previousPoint.x);
}

- (CGPoint)pointWithTouch:(UITouch *)touch
{
    return [touch locationInView:self.view];
}

- (CGPoint)previousPointWithTouch:(UITouch *)touch
{
    return [touch previousLocationInView:self.view];
}


#pragma mark - Debug methods
/*
- (void)setDirection:(YMGestureDirection)direction
{
    _direction = direction;
    NSLog(@"Direction %ld", direction);
}

- (void)setState:(UIGestureRecognizerState)state
{
    if (state == UIGestureRecognizerStateFailed) {
        NSLog(@"State failed");
    } else {
        NSLog(@"State is ok");
    }
    [super setState:state];
}
*/
@end
