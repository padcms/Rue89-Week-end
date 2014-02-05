//
//  RueHorizontalScrollingPageViewController+BackSwipeGwstureSupport.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/19/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueHorizontalScrollingPageViewController+BackSwipeGwstureSupport.h"
#import "PCScrollView.h"
#import "PCSlideshowViewController.h"
#import "PCPageElemetTypes.h"
#import "PCHorizontalPageElementViewController.h"
#import "RueBrowserViewController.h"

@interface PCPageViewController ()

- (void) createWebBrowserViewWithFrame:(CGRect)frame;
- (void) hideVideoWebView;
- (void) showVideoWebViewForActiveZone:(PCPageActiveZone*)activeZone;

@end

@implementation PCPageViewController (BackSwipeGwstureSupport)

- (BOOL) canSwipeBackWithGesture:(UIGestureRecognizer*)gesture
{
    return YES;
}

@end

@interface PCScrollingPageViewController()
{
@protected
    PCScrollView *_paneScrollView;
    PCPageElementViewController *_paneContentViewController;
}

@end

@implementation RueHorizontalScrollingPageViewController (BackSwipeGwstureSupport)

- (BOOL) canSwipeBackWithGesture:(UIGestureRecognizer*)gesture
{
    CGPoint gestureLocation = [gesture locationInView:self.mainScrollView];
    CGRect scrollFrame = _paneScrollView.frame;
    
    if (CGRectContainsPoint(scrollFrame, gestureLocation))
    {
        return (_paneScrollView.contentOffset.x == 0);
    }
    else
    {
        return YES;
    }
}

@end

@implementation PCSlideshowViewController(BackSwipeGwstureSupport)

- (BOOL) canSwipeBackWithGesture:(UIGestureRecognizer*)gesture
{
    CGPoint gestureLocation = [gesture locationInView:self.mainScrollView];
    CGRect scrollFrame = slidersView.frame;
    
    if (CGRectContainsPoint(scrollFrame, gestureLocation))
    {
        return (slidersView.contentOffset.x == 0);
    }
    else
    {
        return YES;
    }
}

@end
