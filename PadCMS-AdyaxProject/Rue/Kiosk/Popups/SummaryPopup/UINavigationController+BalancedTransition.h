//
//  UINavigationController+BalancedTransition.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (BalancedTransition)

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion;
- (UIViewController*) popViewControllerAnimated:(BOOL)animated completion:(void(^)())completion;

@end
