//
//  RueScrollingPaneViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/29/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPageElement;

@interface RueScrollingPaneViewController : UIViewController

+ (id) controllerForElement:(PCPageElement*)element atZone:(CGRect)zone;

- (CGPoint) contentOffset;

- (void) loadFullView;
- (void) unloadFullView;

@end
