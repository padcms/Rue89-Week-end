//
//  AIRRevisionViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/5/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "AIRRevisionViewController.h"
#import "PCTopBarView.h"
#import "PCScrollView.h"
#import "PCHorizontalPageController.h"

@interface PCRevisionViewController()
{
@public
    PCHudView *_hudView;
}

- (void) hideMenus;
- (BOOL) isOrientationChanged:(UIDeviceOrientation)orientation;
- (NSInteger) currentColumnIndex;
- (void)updateHUDView;
- (PCPage *) pageAtHorizontalIndex:(NSInteger)currentHorisontalPageIndex;
- (void) updateViewsForCurrentIndexHorizontal;

@end

@interface AIRRevisionViewController ()

@end

@implementation AIRRevisionViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    currentMagazineOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

- (void) deviceOrientationDidChange
{
    if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        if (self.revision.verticalTocLoaded && self.revision.horizontalTocLoaded)
        {
            [_hudView.topBarView setSummaryButtonHidden:NO animated:YES];
        }
        else
        {
            [_hudView.topBarView setSummaryButtonHidden:YES animated:YES];
        }
    }
    else
    {
        [_hudView.topBarView setSummaryButtonHidden:YES animated:YES];
        [_hudView hideSummaryAnimated:YES];
    }
    
    if (self.revision.horizontalMode && horizontalPagesViewControllers.count != 0)
    {
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
        {
			CGFloat index = horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width;
			NSInteger currentIndex = lrintf(round(index));
			PCHorizontalPageController* currentPageController = [horizontalPagesViewControllers objectAtIndex:currentIndex];
            
			[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:currentPageController.identifier userInfo:nil];
            
            [horizontalScrollView setHidden:NO];
            [mainScrollView setHidden:YES];
            
            if ([self isOrientationChanged:[[UIDevice currentDevice] orientation]])
            {
                [self hideMenus];
                
                PCColumnViewController* currentColumnViewController = nil;
                
                if([self isOnLastColumn])
                {
                    currentColumnViewController = [columnsViewControllers lastObject];
                }
                else
                {
                    currentColumnViewController = [self currentColumnViewController];
                }
                NSInteger currentHorisontalPage = ((PCPage*)[currentColumnViewController.column.pages objectAtIndex:0]).horisontalPageIdentifier;
                NSArray *keys = [self.revision.horizontalPages allKeys];
                NSArray *sortedKeys = [keys sortedArrayUsingSelector: @selector(compare:)];
                NSInteger currentHorisontalPageIndex = [sortedKeys indexOfObject:[NSNumber numberWithInt:currentHorisontalPage]];
                [horizontalScrollView setContentOffset:CGPointMake(1024 * currentHorisontalPageIndex, 0) animated:NO];
                //PCHorizontalPageController* horizontalPageController = [horizontalPagesViewControllers objectAtIndex:currentHorisontalPageIndex];
//                [horizontalPageController loadFullView];
                [self updateViewsForCurrentIndexHorizontal];
            }
			[currentPageController showHUD];
        }
        else if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
        {
            if (!self.currentColumnViewController.currentPageViewController.page.isComplete)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:self.currentColumnViewController.currentPageViewController.page userInfo:nil];
            }
			
            
            self.view.frame = CGRectMake(0, 0, 768, 1024);
            [mainScrollView setFrame:CGRectMake(0, 0, 768, 1024)];
            [horizontalScrollView setHidden:YES];
            [mainScrollView setHidden:NO];
            
            NSUInteger columnIndex = 0;
            NSArray *columns = mainScrollView.subviews;
            for (UIView *column in columns)
            {
                column.frame = CGRectMake(self.view.frame.size.width * columnIndex,
                                          0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
                ++columnIndex;
            }
            
            if ([self isOrientationChanged:[[UIDevice currentDevice] orientation]])
            {
                [self hideMenus];
                NSInteger currentHorisontalPageIndex = lrint(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width);
                PCPage *page = [self pageAtHorizontalIndex:currentHorisontalPageIndex];
                //                [self showPage:page];
                
                NSInteger columnIndex  = [self.revision.columns indexOfObject:page.column];
                if (columnIndex!=NSNotFound && columnIndex<[columnsViewControllers count])
                {
                    //PCColumnViewController* columnViewController = [columnsViewControllers objectAtIndex:columnIndex];
                    //                    [mainScrollView scrollRectToVisible:columnViewController.view.frame animated:YES];
                    [mainScrollView setContentOffset:CGPointMake(768 * columnIndex, 0) animated:NO];
                    //[columnViewController loadFullView];
//                    [columnViewController.currentPageViewController showHUD];
//                                       [columnViewController showPage:page];
                    
                
                    [self updateViewsForCurrentIndex];
                }
            }
            if (!isOS5())
            {
                //                [topMenuView setFrame:CGRectMake(0, 0, self.view.frame.size.width, topMenuView.frame.size.height)];
                //                tableOfContentButton.hidden = topMenuView.hidden;
            }
			[self.currentColumnViewController.currentPageViewController showHUD];
        }
    }
    
    [self updateHUDView];
    
    [_hudView reloadData];
}

- (BOOL) isOnLastColumn
{
    return (self.mainScrollView.contentOffset.x + self.mainScrollView.frame.size.width == self.mainScrollView.contentSize.width);
}

@end
