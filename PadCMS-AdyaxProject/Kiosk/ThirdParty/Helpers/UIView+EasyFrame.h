//
//  UIView+EasyFrame.h
//  Quiz
//
//  Created by Martyniuk.M on 2/22/13.
//  Copyright (c) 2013 DBBest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (EasyFrame)

- (float)frameX;
- (void)setFrameX:(float)x;

- (float)frameY;
- (void)setFrameY:(float)y;

- (float)frameWidth;
- (void)setFrameWidth:(float)width;

- (float)frameHeight;
- (void)setFrameHeight:(float)height;

@end