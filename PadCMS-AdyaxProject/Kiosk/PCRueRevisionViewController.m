//
//  PCRueRevisionViewController.m
//  Pad CMS
//
//  Created by tar on 05.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueRevisionViewController.h"
#import "PCRevisionSummaryPopup.h"
#import "PCTMainViewController.h"
#import "PCGoogleAnalytics.h"
#import "PCScrollView.h"

#import "PCPageViewController+IsPresented.h"
#import "PCHorizontalScrollingPageViewController+BackSwipeGwstureSupport.h"

@interface PCRevisionViewController ()

- (NSInteger) currentColumnIndex;
- (void) loadFullColumnAtIndex:(NSInteger)index;
- (void) unloadFullColumnAtIndex:(NSInteger)index;

@end

@interface PCRueRevisionViewController () <PCRevisionSummaryPopupDelegate, UIGestureRecognizerDelegate>



@end

@implementation PCRueRevisionViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        
//    }
//    return self;
//}

- (void) updateViewsForCurrentIndex
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		if (self.currentColumnViewController.currentPageViewController.page && !self.currentColumnViewController.currentPageViewController.page.isComplete)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:self.currentColumnViewController.currentPageViewController.page userInfo:nil];
		}
		
		
		NSInteger currentIndex = [self currentColumnIndex];
		[self loadFullColumnAtIndex:currentIndex];
		
		for(int i = 0; i < [columnsViewControllers count]; ++i)
		{
			if(ABS(currentIndex - i) > 1)
			{
				[self unloadFullColumnAtIndex:i];
			}
			else
			{
                if(ABS(currentIndex - i) > 0)
                {
                    PCColumnViewController* columnController = [columnsViewControllers objectAtIndex:i];
                    [columnController.currentPageViewController didStopToBePresented];
                    [self loadFullColumnAtIndex:i];
                }
                else
                {
                    PCColumnViewController* columnController = [columnsViewControllers objectAtIndex:i];
                    [columnController.currentPageViewController didBecamePresented];
                }
			}
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.currentColumnViewController.currentPageViewController showHUD];
		});
		
		[PCGoogleAnalytics trackPageView:self.currentColumnViewController.currentPageViewController.page];
	});
    
}

- (NSArray*) sortedListOfAllDownloadedRevisions
{
    NSMutableArray* allRev = [NSMutableArray arrayWithArray:[(PCTMainViewController*)self.mainViewController allDownloadedRevisions]];
    [allRev removeObject:self.revision];
    return [NSArray arrayWithArray:allRev];
}

- (void) setMainViewController:(PCMainViewController *)newMainViewController
{
    [super setMainViewController:newMainViewController];
    if(newMainViewController == nil)
    {
        for (PCColumnViewController* column in columnsViewControllers)
        {
            column.magazineViewController = nil;
            for (PCPageViewController* page in column.pageViewControllers)
            {
                page.magazineViewController = nil;
            }
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    
    //owerrided for keeping controller alive
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self addLeftSwipeToBackGesture];
}

- (void) fadeInViewWithDuration:(NSTimeInterval)duration completion:(void(^)())complBlock
{
    void(^fadeIn)() = ^{
        
        self.mainScrollView.alpha = 0.0;
    };
    
    if(duration)
    {
        [UIView animateWithDuration:duration animations:^{
            
            fadeIn();
            
        } completion:^(BOOL finished) {
            
            if(complBlock) complBlock();
        }];
    }
    else
    {
        fadeIn();
        if(complBlock)complBlock();
    }
}

- (void) fadeOutViewWithDuration:(NSTimeInterval)duration completion:(void(^)())complBlock
{
    void(^fadeOut)() = ^{
        
        self.mainScrollView.alpha = 1.0;
    };
    
    if(duration)
    {
        [UIView animateWithDuration:duration animations:^{
            
            fadeOut();
            
        } completion:^(BOOL finished) {
            
            if(complBlock) complBlock();
        }];
    }
    else
    {
        fadeOut();
        if(complBlock)complBlock();
    }
}

- (void) showSummaryMenuAnimated:(BOOL)animated withRevisionsList:(NSArray*)revisionsList menuOffset:(float)offset
{
    if(revisionsList == nil)
    {
        revisionsList = [self sortedListOfAllDownloadedRevisions];
    }
    [self.summaryPopup setRevisionsList:revisionsList];
    self.summaryPopup.contentOffset = offset;
    [self.summaryPopup showAnimated:animated completion:nil];
}

- (void) showSummaryMenuAnimated:(BOOL)animated withRevisionsList:(NSArray*)revisionsList
{
    [self showSummaryMenuAnimated:animated withRevisionsList:revisionsList menuOffset:0];
}

- (void) showSummaryMenuAnimated:(BOOL)animated
{
    [self showSummaryMenuAnimated:animated withRevisionsList:nil];
}

- (void) hideSummaryMenuAnimated:(BOOL)animated
{
    [self.summaryPopup hideAnimated:animated completion:nil];
}

- (void)addLeftSwipeToBackGesture
{
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandler:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    swipe.delegate = self;
    [self.view addGestureRecognizer:swipe];
}

#pragma mark - Gesture recognizer delagete

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (((UIScrollView *)self.mainScrollView).contentOffset.x > 0) {
        return NO;
    }
    
    if([self.currentColumnViewController.currentPageViewController canSwipeBackWithGesture:gestureRecognizer])
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(self.summaryPopup.frame, [touch locationInView:self.summaryPopup])) {
        return NO;
    }
    
    
    
    return YES;
}

#pragma mark - HUD (top summary view for Rue) Overrides

- (void)createHUDView {
    
    NSLog(@"TOC %@", self.revision.toc);
    
    self.summaryPopup = [[PCRevisionSummaryPopup alloc] initWithSize:CGSizeMake(self.view.frame.size.width, 146) viewToShowIn:self.view tocItems:self.revision.toc];
    [self.summaryPopup setPresentationStyle:PCKioskPopupPresentationStyleFromTop];
    [self.summaryPopup setDelegate:self];
}

- (void)destroyHUDView {
    [super destroyHUDView];
    

}

#pragma mark - Transition

- (void)switchToKiosk {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - tap handler

- (void)tapGesture:(UIGestureRecognizer *)recognizer
{
    if (self.summaryPopup.isShown)
    {
        [self.summaryPopup hide];
    }
}

#pragma mark - Left swipe handler

- (void)leftSwipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    if (self.summaryPopup.isShown)
    {
        [self.summaryPopup hide];
    }
    [self topBarView:nil backButtonTapped:nil];
}

#pragma mark - PCRevisionSummaryPopupDelegate

- (void)revisionSummaryPopupDidTapHomeButton:(PCRevisionSummaryPopup *)popup {
    if (self.summaryPopup.isShown)
    {
        [self.summaryPopup hide];
    }
    [self topBarView:nil backButtonTapped:nil];
}

- (void)revisionSummaryPopupDidTapMenuButton:(PCRevisionSummaryPopup *)popup
{
    if (!self.summaryPopup.isShown)
    {
        [self.summaryPopup setRevisionsList:[self sortedListOfAllDownloadedRevisions]];
        [self.summaryPopup show];
    }
    else
    {
        [self.summaryPopup hide];
    }
}

- (void)revisionSummaryPopup:(PCRevisionSummaryPopup *)popup didSelectIndex:(NSInteger)index {
    [self hudView:nil didSelectIndex:index];
}

- (void) revisionSummaryPopup:(PCRevisionSummaryPopup *)popup didSelectRevision:(PCRevision *)revision
{
    //[popup hide];
    [(PCTMainViewController*)self.mainViewController switchToRevision:revision];
}

@end
