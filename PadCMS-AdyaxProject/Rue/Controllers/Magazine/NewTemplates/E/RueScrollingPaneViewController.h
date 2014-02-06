//
//  RueScrollingPaneViewController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/29/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCPageElement, PCPageViewController;

@interface RueScrollingPaneViewController : UIViewController

+ (id) controllerForElement:(PCPageElement*)element withFrame:(CGRect)scrollFrame onScrollView:(UIScrollView*)scrollView pageViewController:(PCPageViewController*)pageController;

- (CGPoint) contentOffset;

- (void) loadFullView;
- (void) unloadFullView;

@end
