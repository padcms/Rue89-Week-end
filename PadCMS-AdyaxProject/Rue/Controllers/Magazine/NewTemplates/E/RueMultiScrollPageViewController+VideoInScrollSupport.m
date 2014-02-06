//
//  RueMultiScrollPageViewController+VideoInScrollSupport.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/6/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "RueMultiScrollPageViewController+VideoInScrollSupport.h"
#import "PCPageElementActiveZone.h"
#import "PCPageElemetTypes.h"
#import "RueScrollingPaneViewController.h"
#import "PCScrollView.h"
#import "RuePDFActiveZones.h"

@interface PCPageViewController ()

- (void) createWebBrowserViewForActiveZone:(PCPageElementActiveZone*)activeZone;
- (void) createWebBrowserViewWithFrame:(CGRect)frame onScrollView:(UIScrollView*)scrollView;

@end

@interface RueMultiScrollPageViewController ()

@property (nonatomic, strong) NSArray* scrollingPaneControllers;

@end

@implementation RueMultiScrollPageViewController (VideoInScrollSupport)

- (void) createWebBrowserViewForActiveZone:(PCPageElementActiveZone*)activeZone
{
    if([activeZone.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
    {
        RueScrollingPaneViewController* scrollController = [self scrollControllerForElement:activeZone.pageElement];
        if(scrollController)
        {
            CGRect videoWebViewRect = [self activeZoneRectForType:activeZone.URL];
            videoWebViewRect = [scrollController.scrollView convertRect:videoWebViewRect fromView:self.mainScrollView];
            [self createWebBrowserViewWithFrame:videoWebViewRect onScrollView:scrollController.scrollView];
            
            return;
        }
    }
    
    [super createWebBrowserViewForActiveZone:activeZone];
    [self changeVideoLayout:NO];
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
//                    CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
//                    float scale = pageSize.width/element.size.width;
//                    rect.size.width *= scale;
//                    rect.size.height *= scale;
//                    rect.origin.x *= scale;
//                    rect.origin.y *= scale;
                    rect.origin.y = element.size.height/**scale*/ - rect.origin.y - rect.size.height;
                    
                    if (CGRectContainsPoint(rect, point))
                    {
                        [activeZones addObject:pdfActiveZone];
                    }
                }
            }
        }
    }
    return [self sortActiveZonesByPriority:activeZones];
}

- (NSArray*) sortActiveZonesByPriority:(NSArray*)array //scrolling pane zones go to the beginning of array
{
    return [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        PCPageElementActiveZone* activeZone1 = obj1;
        PCPageElementActiveZone* activeZone2 = obj2;
        
        if([activeZone1.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
        {
            if([activeZone2.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
            {
                return NSOrderedSame;
            }
            else
            {
                return NSOrderedAscending;
            }
        }
        else if([activeZone2.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
}

- (NSArray*) activeZonesInScrollingPaneElement:(PCPageElement*)element atPoint:(CGPoint)point
{
    NSMutableArray* activeZones = [[NSMutableArray alloc]init];
    
    for (RueScrollingPaneViewController* controller in self.scrollingPaneControllers)
    {
        if(CGRectContainsPoint(controller.scrollView.frame, point))
        {
            for (PCPageActiveZone* pdfActiveZone in element.activeZones)
            {
                CGRect rect = pdfActiveZone.rect;
                if (!CGRectEqualToRect(rect, CGRectZero))
                {
//                    CGSize pageSize = _paneContentViewController.view.frame.size;//[self.columnViewController pageSizeForViewController:self];
//                    float scale = pageSize.width/element.size.width;
//                    rect.size.width *= scale;
//                    rect.size.height *= scale;
//                    rect.origin.x *= scale;
//                    rect.origin.y *= scale;
                    rect.origin.y = element.size.height/**scale*/ - rect.origin.y - rect.size.height;
                    
                    CGPoint pointInPane = [controller.scrollView convertPoint:point fromView:self.mainScrollView];
                    
                    if (CGRectContainsPoint(rect, pointInPane))
                    {
                        [activeZones addObject:pdfActiveZone];
                    }
                }
            }
        }
        break;
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
//                CGSize pageSize = _paneContentViewController.view.frame.size;
//                float scale = pageSize.width/element.size.width;
//                rect.size.width *= scale;
//                rect.size.height *= scale;
//                rect.origin.x *= scale;
//                rect.origin.y *= scale;
                rect.origin.y = element.size.height/**scale*/ - rect.origin.y - rect.size.height;
                
                rect = [self.mainScrollView convertRect:rect fromView:[self scrollControllerForElement:element].view];
                
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

- (RueScrollingPaneViewController*) scrollControllerForElement:(PCPageElement*)element
{
    for (RueScrollingPaneViewController* controller in self.scrollingPaneControllers)
    {
        if(controller.pageElement == element)
        {
            return controller;
        }
    }
    return nil;
}

@end
