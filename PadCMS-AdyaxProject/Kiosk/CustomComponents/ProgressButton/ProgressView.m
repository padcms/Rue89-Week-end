//
//  ProgressView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/10/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.progressTintColor = [UIColor redColor];
        self.trackTintColor = [UIColor yellowColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    float progress = self.progress;
    if(progress < 0)
    {
        progress = 0;
    }
    if(progress > 1)
    {
        progress = 1;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    
    CGContextSetFillColorWithColor(context, self.trackTintColor.CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
    CGRect progressRect = CGRectMake(0, 0, self.frame.size.width * self.progress, self.frame.size.height);
    CGContextFillRect(context, progressRect);
}

- (void) setProgress:(float)progress
{
    if(_progress != progress)
    {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

@end
