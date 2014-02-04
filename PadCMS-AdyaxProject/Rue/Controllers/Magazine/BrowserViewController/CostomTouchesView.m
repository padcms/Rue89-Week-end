//
//  CostomTouchesView.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/4/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "CostomTouchesView.h"

@implementation CostomTouchesView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(event && event.type == UIEventTypeTouches)
    {
        return [self.delegate shouldReceiveTouchInPoint:point];
    }
    else
    {
        return [super pointInside:point withEvent:event];
    }
}


@end
