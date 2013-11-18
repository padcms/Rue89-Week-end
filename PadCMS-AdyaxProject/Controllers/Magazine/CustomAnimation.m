//
//  CustomAnimation.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/18/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "CustomAnimation.h"

#define kTimerStep 0.02

@interface CustomAnimation ()
{
    UIView* _view;
    
    NSTimer* _timer;
    int _stepsCount;
    int _currentStep;
    
    BOOL _animatingFrame;
    CGRect _toFrame;
    CGRect _frameStep;
    
    BOOL _animatingTransform;
    CGAffineTransform _toTransform;
    CGAffineTransform _transformStep;
}

@property (nonatomic, copy) void(^completion)();

@end

@implementation CustomAnimation

- (id) initForView:(UIView*)view duration:(NSTimeInterval)duration finalFrame:(CGRect)toFrame finalTransform:(CGAffineTransform)toTransform
{
    self = [super init];
    if(self)
    {
        _view = view;
        
        if(CGRectEqualToRect(view.frame, toFrame) == NO)
        {
            _animatingFrame = YES;
            _toFrame = toFrame;
            
            _stepsCount = (float)duration / kTimerStep;
            
            _frameStep = CGRectMake((toFrame.origin.x - view.frame.origin.x) / _stepsCount, (toFrame.origin.y - view.frame.origin.y) / _stepsCount, (toFrame.size.width - view.frame.size.width) / _stepsCount, (toFrame.size.height - view.frame.size.height) / _stepsCount);
        }
        
        if(CGAffineTransformEqualToTransform(view.transform, toTransform) == NO)
        {
            _animatingTransform = YES;
            _toTransform = toTransform;
        }
        
    }
    return self;
}

- (void) performWithCompletion:(void(^)())completion
{
    self.completion = completion;
    
//    _timer = [[NSTimer alloc]initWithFireDate:[NSDate date] interval:kTimerStep target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerStep target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}
              
- (void) timerTick
{
    if(_animatingFrame)
    {
        if(_currentStep == _stepsCount - 1)
        {
            _view.frame = _toFrame;
        }
        else
        {
            _view.frame = CGRectMake(_view.frame.origin.x + _frameStep.origin.x, _view.frame.origin.y + _frameStep.origin.y, _view.frame.size.width + _frameStep.size.width, _view.frame.size.height + _frameStep.size.height);
        }
    }
    
    if(_animatingTransform)
    {
        if(_currentStep == _stepsCount - 1)
        {
            _view.transform = _toTransform;
        }
        else
        {
            _view.transform = CGAffineTransformConcat(_view.transform, _transformStep);
        }
    }
    
    if(_currentStep == _stepsCount - 1)
    {
        [_timer invalidate];
        _timer = nil;
        if(_completion)
        {
            _completion();
            _completion = nil;
        }
    }
    else
    {
        _currentStep += 1;
    }
    
    [_view setNeedsLayout];
}

- (void) invalidate
{
    [_timer invalidate];
    _timer = nil;
    self.completion = nil;
}

@end
