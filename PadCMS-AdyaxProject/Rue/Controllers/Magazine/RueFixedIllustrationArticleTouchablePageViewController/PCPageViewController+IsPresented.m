//
//  PCPageViewController+IsPresented.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCPageViewController+IsPresented.h"
#import "PCColumnViewController.h"

@interface PCPageViewController ()

- (void) didBecamePresented;
- (void) hideSubviews;

@end

@implementation PCPageViewController (IsPresented)

- (BOOL) isPresentedPage
{
    if([self magazineViewController])
    {
        if([[self magazineViewController]respondsToSelector:@selector(navigationController)] && self.magazineViewController.navigationController != nil)
        {
            if(self.columnViewController == self.magazineViewController.currentColumnViewController)
            {
                if(self == self.columnViewController.currentPageViewController)
                {
                    return YES;
                }
            }
        }
    }
    return NO;
    //return ([self magazineViewController] && [[self magazineViewController]navigationController] && self.columnViewController == self.magazineViewController.currentColumnViewController && self == self.columnViewController.currentPageViewController);
}

- (void) didStopToBePresented
{
    [self hideSubviews];
}

@end

@interface PCColumnViewController ()

- (void) loadFullPageAtIndex:(NSInteger)index;
- (void) unloadFullPageAtIndex:(NSInteger)index;

@end

@implementation PCColumnViewController (PageIsPresentedSupport)

- (void) updateViewsForCurrentIndex
{
    NSInteger currentIndex = [self currentPageIndex];
    
    for(int i = 0; i < [pageViewControllers count]; ++i)
    {
        if(ABS(currentIndex - i) > 1)
        {
            [self unloadFullPageAtIndex:i];
        }
        else
        {
            if(ABS(currentIndex - i) > 0)
            {
                PCPageViewController *currentPage = [pageViewControllers objectAtIndex:i];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [currentPage didStopToBePresented];
                });
                [self loadFullPageAtIndex:i];
            }
            else
            {
                [self loadFullPageAtIndex:i];
                PCPageViewController *currentPage = [pageViewControllers objectAtIndex:i];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [currentPage didBecamePresented];
                });
            }
        }
    }
}

@end
