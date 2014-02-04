//
//  PCScrollingPageViewController+VideoOnElements.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 2/3/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "PCScrollingPageViewController+VideoOnElements.h"
#import "PCPageElementActiveZone.h"
#import "PCPageElemetTypes.h"
#import "PCScrollView.h"
#import "RueBrowserViewController.h"

@interface PCPageViewController ()

- (void) showVideoWebViewForActiveZone:(PCPageElementActiveZone*)activeZone;
- (void) createWebBrowserViewWithFrame:(CGRect)frame onScrollView:(UIScrollView*)scrollView;

@end

@interface PCScrollingPageViewController()
{
    PCScrollView *_paneScrollView;
    PCPageElementViewController *_paneContentViewController;
//    UIButton *_scrollDownButton;
//    UIButton *_scrollUpButton;
}
@end

@implementation PCScrollingPageViewController (VideoOnElements)

- (void) showVideoWebViewForActiveZone:(PCPageElementActiveZone*)activeZone
{
    if([activeZone.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
    {
        NSString* videoWebViewURL = activeZone.URL;
        
        CGRect videoWebViewRect = [self activeZoneRectForType:activeZone.URL];
        videoWebViewRect = [_paneScrollView convertRect:videoWebViewRect fromView:self.mainScrollView];
        
        NSLog(@"URL playing : %@", videoWebViewURL);
        
        [self createWebBrowserViewWithFrame:videoWebViewRect onScrollView:_paneScrollView];
        
        [webBrowserViewController presentURL:videoWebViewURL];
    }
    else
    {
        [super showVideoWebViewForActiveZone:activeZone];
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
                    
                    UIView* testView = [[UIView alloc] initWithFrame:rect];
                    testView.backgroundColor = [UIColor redColor];
                    [self.mainScrollView addSubview:testView];
                    
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

- (NSArray*) sortActiveZonesByPriority:(NSArray*)array
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

@end
