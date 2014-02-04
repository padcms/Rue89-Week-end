//
//  CostomTouchesViewDelegate.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/4/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CostomTouchesViewDelegate <NSObject>

- (BOOL) shouldReceiveTouchInPoint:(CGPoint)point;

@end
