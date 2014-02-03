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
#import "PCPageElemetTypes.h"
#import "PCHorizontalPageElementViewController.h"
#import "RueBrowserViewController.h"

@interface PCPageViewController ()

- (void) createWebBrowserViewWithFrame:(CGRect)frame;
- (void) hideVideoWebView;

@end

@implementation PCPageViewController (BackSwipeGwstureSupport)

- (BOOL) canSwipeBackWithGesture:(UIGestureRecognizer*)gesture
{
    return YES;
}

@end

@interface PCHorizontalScrollingPageViewController ()
{
    PCScrollView *_paneScrollView;
    PCHorizontalPageElementViewController *_paneContentViewController;
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

- (NSArray*) activeZonesAtPoint:(CGPoint)point
{
    NSMutableArray* activeZones = [[NSMutableArray alloc] init];
    
    for (PCPageElement* element in self.page.elements)
    {
        if([element.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
        {
            [activeZones addObjectsFromArray:[self activeZonesInScrollingPaneElement:element atPoint:point]];
        }
        else
        {
            for (PCPageActiveZone* pdfActiveZone in element.activeZones)
            {
                CGRect rect = pdfActiveZone.rect;
                if (!CGRectEqualToRect(rect, CGRectZero))
                {
                    CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
                    float scale = pageSize.width/element.size.width;
                    rect.size.width *= scale;
                    rect.size.height *= scale;
                    rect.origin.x *= scale;
                    rect.origin.y *= scale;
                    rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
                    if (CGRectContainsPoint(rect, point))
                    {
                        [activeZones addObject:pdfActiveZone];
                    }
                }
            }
        }
    }
    return activeZones;
}

- (NSArray*) activeZonesInScrollingPaneElement:(PCPageElement*)element atPoint:(CGPoint)point
{
    NSMutableArray* activeZones = [[NSMutableArray alloc]init];
    
    if(CGRectContainsPoint(_paneScrollView.frame, point))
    {
        for (PCPageActiveZone* pdfActiveZone in element.activeZones)
        {
            CGRect rect = pdfActiveZone.rect;
            if (!CGRectEqualToRect(rect, CGRectZero))
            {
                CGSize pageSize = _paneContentViewController.view.frame.size;//[self.columnViewController pageSizeForViewController:self];
                float scale = pageSize.width/element.size.width;
                rect.size.width *= scale;
                rect.size.height *= scale;
                rect.origin.x *= scale;
                rect.origin.y *= scale;
                rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
                               UIView* testView = [[UIView alloc] initWithFrame:rect];
                               testView.backgroundColor = [UIColor redColor];
                               [_paneContentViewController.view addSubview:testView];
                
                CGPoint pointInPane = [_paneContentViewController.view convertPoint:point fromView:self.mainScrollView];
                
                if (CGRectContainsPoint(rect, pointInPane))
                {
                    [activeZones addObject:pdfActiveZone];
                }
            }
        }
    }
    return activeZones;
}

- (CGRect) activeZoneRectForType:(NSString*)zoneType
{
    for (PCPageElement* element in self.page.elements)
    {
        CGRect rect = [element rectForElementType:zoneType];
        if (!CGRectEqualToRect(rect, CGRectZero))
        {
            if([element.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
            {
                CGSize pageSize = _paneContentViewController.view.frame.size;
                float scale = pageSize.width/element.size.width;
                rect.size.width *= scale;
                rect.size.height *= scale;
                rect.origin.x *= scale;
                rect.origin.y *= scale;
                rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
                
                rect = [self.mainScrollView convertRect:rect fromView:_paneContentViewController.view];
                
                return rect;
            }
            else
            {
                CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
                float scale = pageSize.width/element.size.width;
                rect.size.width *= scale;
                rect.size.height *= scale;
                rect.origin.x *= scale;
                rect.origin.y *= scale;
                rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
                return rect;
            }
        }
    }
    return CGRectZero;
}

- (void) createWebBrowserViewWithFrame:(CGRect)frame
{
    if(frame.origin.y >= _paneScrollView.frame.origin.y && frame.origin.y + frame.size.height <= _paneScrollView.frame.origin.y + _paneScrollView.frame.size.height) //frame is on paneScrollView
    {
        CGRect videoRect = frame;
        if (CGRectEqualToRect(videoRect, CGRectZero))
        {
            videoRect = [[UIScreen mainScreen] bounds];
        }
        
        videoRect = [_paneScrollView convertRect:videoRect fromView:self.mainScrollView];
        
        NSLog(@"video rect is : %@", NSStringFromCGRect(videoRect));
        
        [self hideVideoWebView];
        
        webBrowserViewController = [[RueBrowserViewController alloc] init];
        webBrowserViewController.videoRect = videoRect;
        
        ((RueBrowserViewController*)webBrowserViewController).mainScrollView = _paneScrollView;//self.mainScrollView;
        ((RueBrowserViewController*)webBrowserViewController).pageView = self.view;
        
        [_paneScrollView addSubview:webBrowserViewController.view];
        
        if (self.page.pageTemplate ==
            [[PCPageTemplatesPool templatesPool] templateForId:PCFixedIllustrationArticleTouchablePageTemplate] || self.page.pageTemplate.identifier == PCBasicArticlePageTemplate)
        {
            [self changeVideoLayout:YES]; //bodyViewController.view.hidden];
        }
    }
    else //frame is out of paneScrollView
    {
        [super createWebBrowserViewWithFrame:frame];
        [self changeVideoLayout:NO];
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
