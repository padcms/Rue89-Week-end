//
//  UIView+EasyFrame.m
//  Quiz
//
//  Created by Martyniuk.M on 2/22/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import "UIView+EasyFrame.h"

@implementation UIView (EasyFrame)

- (float)frameX
{
    return self.frame.origin.x;
}
- (void)setFrameX:(float)x
{
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (float)frameY
{
    return self.frame.origin.y;
}
- (void)setFrameY:(float)y
{
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (float)frameWidth
{
    return self.frame.size.width;
}

- (void)setFrameWidth:(float)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (float)frameHeight
{
    return self.frame.size.height;
}
- (void)setFrameHeight:(float)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

@end