//
//  PCHorizontalScrollingPageViewController+BackSwipeGwstureSupport.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/19/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCHorizontalScrollingPageViewController+BackSwipeGwstureSupport.h"
#import "PCScrollView.h"
#import "PCSlideshowViewController.h"

@implementation PCPageViewController (BackSwipeGwstureSupport)

- (BOOL) canSwipeBackWithGesture:(UIGestureRecognizer*)gesture
{
    return YES;
}

@end

@interface PCHorizontalScrollingPageViewController ()
{
    PCScrollView *_paneScrollView;
//    PCHorizontalPageElementViewController *_paneContentViewController;
//    UIButton *_scrollRightButton;
//    UIButton *_scrollLeftButton;
}
@end

@implementation PCHorizontalScrollingPageViewController (BackSwipeGwstureSupport)

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
