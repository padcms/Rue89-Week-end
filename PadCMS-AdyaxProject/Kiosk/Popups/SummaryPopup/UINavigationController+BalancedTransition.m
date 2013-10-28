//
//  UINavigationController+BalancedTransition.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "UINavigationController+BalancedTransition.h"

@implementation UINavigationController (BalancedTransition)

- (void) pushViewController:(UIViewController *)newViewController animated:(BOOL)animated completion:(void(^)())completion
{
    if(animated == NO)
    {
        [self pushViewController:newViewController animated:NO];
        if(completion) completion();
    }
    else
    {
        BOOL prevUserInteraction = self.view.userInteractionEnabled;
        self.view.userInteractionEnabled = NO;
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        UIViewController* topController = self.topViewController;
        CGRect previousTopViewFrame = topController.view.frame;
        
        view_change_frame(newViewController.view, screenSize.width, 0, 0, 0);
        
        [self.view addSubview:newViewController.view];
        
        [topController.view removeFromSuperview];
        [self.view addSubview:topController.view];
        
        [UIView animateWithDuration:0.4 animations:^{
            
            view_change_frame(newViewController.view, -screenSize.width, 0, 0, 0);
            view_change_frame(topController.view, -screenSize.width, 0, 0, 0);
            
        } completion:^(BOOL finished) {
            
            [topController.view removeFromSuperview];
            topController.view.frame = previousTopViewFrame;
            
            [self pushViewController:newViewController animated:NO];
            
            self.view.userInteractionEnabled = prevUserInteraction;
            if(completion) completion();
        }];
    }
}

- (UIViewController*) popViewControllerAnimated:(BOOL)animated completion:(void(^)())completion
{
    if(animated == NO)
    {
        return [self popViewControllerAnimated:NO];
        if(completion) completion();
    }
    else
    {
        BOOL prevUserInteraction = self.view.userInteractionEnabled;
        self.view.userInteractionEnabled = NO;
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        UIViewController* oldController = self.topViewController;
        CGRect previousOldViewFrame = oldController.view.frame;
        
        [self popViewControllerAnimated:NO];
        UIViewController* newController = self.topViewController;
        
        view_change_frame(newController.view, -screenSize.width, 0, 0, 0);
        
        [self.view addSubview:oldController.view];
        
        [UIView animateWithDuration:0.4 animations:^{
            
            view_change_frame(oldController.view, screenSize.width, 0, 0, 0);
            view_change_frame(newController.view, screenSize.width, 0, 0, 0);
            
        } completion:^(BOOL finished) {
            
            [oldController.view removeFromSuperview];
            oldController.view.frame = previousOldViewFrame;
            
            self.view.userInteractionEnabled = prevUserInteraction;
            
            if(completion) completion();
        }];
        return oldController;
    }
}

void view_change_frame(UIView* view, float dx, float dy, float dw, float dh)
{
    view.frame = CGRectMake(view.frame.origin.x + dx, view.frame.origin.y + dy, view.frame.size.width + dw, view.frame.size.height + dh);
}

@end
