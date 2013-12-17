//
//  DCCVSlideshowViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/11/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "DCCVSlideshowViewController.h"
#import "PCScrollView.h"
#import "PCPageControllersManager.h"

@interface PCSlideshowViewController ()
- (void) afterScroll;
- (void) updateViewsForCurrentIndex;
@end

@interface DCCVSlideshowViewController ()
{
    BOOL _avoidPageChanging;
}
@end

@implementation DCCVSlideshowViewController

+ (void) load
{
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:[[PCPageTemplatesPool templatesPool] templateForId:PCSlideshowPageTemplate]];
}

- (void) afterScroll
{
    [super afterScroll];
    _avoidPageChanging = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.slidersView)
    {
        if (scrollView.contentOffset.x < 0)
        {
            if (self.pageControll.currentPage == 0 && _avoidPageChanging == NO)
            {
                if([self.magazineViewController showPrevColumn])
                {
                    scrollView.scrollEnabled = NO;
                }
            }
        }
        else if (self.pageControll.currentPage == 0)
        {
            _avoidPageChanging = YES;
        }
        else if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width)// > 2)
        {
            if (self.pageControll.currentPage == self.pageControll.numberOfPages - 1 && _avoidPageChanging == NO)
            {
                [scrollView setContentOffset:CGPointMake(scrollView.contentSize.width + scrollView.frame.size.width, scrollView.contentOffset.y) animated:NO];
                if([self.magazineViewController showNextColumn])
                {
                    scrollView.scrollEnabled = NO;
                }
            }
        }
        else if (self.pageControll.currentPage == self.pageControll.numberOfPages - 1 && _avoidPageChanging == NO)
        {
            _avoidPageChanging = YES;
        }
    }
}


@end

@implementation PCSlideshowViewController (Redefinition)

- (void) loadFullView
{
    [super loadFullView];
    
    //change slidersView contentSize and frame here for avoid subviews frame random changes
    if (!CGRectEqualToRect(sliderRect, CGRectZero))
    {
        sliderRect.size.width = self.view.frame.size.width;
        
        [self.slidersView setFrame:sliderRect];
        
        [self.slidersView setContentSize:CGSizeMake([slideViewControllers count] * self.slidersView.frame.size.width,
                                                    self.slidersView.frame.size.height - 1)];
        //decrease height for avoid vertical bounce
    }
    
    for (unsigned i = 0; i < [slideViewControllers count]; i++)
    {
        UIViewController *slideController = [slideViewControllers objectAtIndex:i];
        
        CGRect newSlideRect = CGRectMake(self.view.frame.size.width * i, /*self.slidersView.frame.size.height - self.view.frame.size.height*/-sliderRect.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        
        //        CGRect newSlideRect = CGRectMake(self.slidersView.frame.size.width * i,
        //                                         0,
        //                                         self.slidersView.frame.size.width,
        //                                         self.slidersView.frame.size.height);
        
        [slideController.view setFrame:newSlideRect];
        
    }
    
    [self updateViewsForCurrentIndex];
}

@end
