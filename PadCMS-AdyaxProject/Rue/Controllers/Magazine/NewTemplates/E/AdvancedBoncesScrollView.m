//
//  AdvancedBoncesScrollView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/6/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "AdvancedBoncesScrollView.h"

typedef enum{
    MoveDirectionRight,
    MoveDirectionLeft,
    MoveDirectionUp,
    MoveDirectionDown,
}MoveDirection;

@interface AdvancedBoncesScrollView ()
{
    CGPoint _contentOrigin;
}

@end

@implementation AdvancedBoncesScrollView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _contentOrigin = self.contentOffset;
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint lastPoint = [touch locationInView:self];
    CGPoint startPoint = [touch previousLocationInView:self];
    
    float dx = lastPoint.x - startPoint.x;
    float dy = lastPoint.y - startPoint.y;
    
    MoveDirection direction = directionFromDeviation(dx, dy);
    
    switch (direction)
    {
        case MoveDirectionRight:
            if(_contentOrigin.x <= 0)
            {
                self.scrollEnabled = NO;
            }
            break;
            
        case MoveDirectionLeft:
            if(_contentOrigin.x >= self.contentSize.width - self.frame.size.width)
            {
                self.scrollEnabled = NO;
            }
            break;
            
        case MoveDirectionDown:
            if(_contentOrigin.y <= 0)
            {
                self.scrollEnabled = NO;
            }
            break;
            
        case MoveDirectionUp:
            if(_contentOrigin.y >= self.contentSize.height - self.frame.size.height)
            {
                self.scrollEnabled = NO;
            }
            break;
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.scrollEnabled = YES;
    [super touchesEnded:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.scrollEnabled = YES;
    [super touchesCancelled:touches withEvent:event];
}

MoveDirection directionFromDeviation(float dx, float dy)
{
    if(dx > 0)
    {
        if(dy > 0)
        {
            if(dx > dy)
            {
                return MoveDirectionRight;
            }
            else
            {
                return MoveDirectionDown;
            }
        }
        else
        {
            if(dx > -dy)
            {
                return MoveDirectionRight;
            }
            else
            {
                return MoveDirectionUp;
            }
        }
    }
    else
    {
        if(dy > 0)
        {
            if(-dx > dy)
            {
                return MoveDirectionLeft;
            }
            else
            {
                return MoveDirectionDown;
            }
        }
        else
        {
            if(-dx > -dy)
            {
                return MoveDirectionLeft;
            }
            else
            {
                return MoveDirectionUp;
            }
        }
    }
}

@end
