//
//  AnimatableWebView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/18/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "AnimatableWebView.h"

@implementation AnimatableWebView

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self layoutSublayersOfLayer:self.layer];
}

@end
