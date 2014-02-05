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
#import "PCPDFActiveZones.h"
#import "MBProgressHUD.h"

@interface PCPageViewController ()

- (void) createWebBrowserViewWithFrame:(CGRect)frame onScrollView:(UIScrollView*)scrollView;
- (void) createWebBrowserViewForActiveZone:(PCPageElementActiveZone*)activeZone;

@end

@interface PCScrollingPageViewController()
{
    PCScrollView *_paneScrollView;
    PCPageElementViewController *_paneContentViewController;
//    UIButton *_scrollDownButton;
//    UIButton *_scrollUpButton;
}

- (void)initializeScrollButtons;

@end

@implementation PCScrollingPageViewController (VideoOnElements)

- (void) createWebBrowserViewForActiveZone:(PCPageElementActiveZone*)activeZone
{
    if([activeZone.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
    {
        CGRect videoWebViewRect = [self activeZoneRectForType:activeZone.URL];
        videoWebViewRect = [_paneScrollView convertRect:videoWebViewRect fromView:self.mainScrollView];
        [self createWebBrowserViewWithFrame:videoWebViewRect onScrollView:_paneScrollView];
    }
    else
    {
        [super createWebBrowserViewForActiveZone:activeZone];
        [self changeVideoLayout:NO];
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

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect scrollPaneRect = [self activeZoneRectForType:PCPDFActiveZoneScroller];
    
    if (CGRectEqualToRect(scrollPaneRect, CGRectZero)) {
        scrollPaneRect = [[self mainScrollView] bounds];
    }
    
    _paneScrollView = [[PCScrollView alloc] initWithFrame:scrollPaneRect];
    _paneScrollView.delegate = self;
    _paneScrollView.contentSize = CGSizeZero;
    _paneScrollView.showsVerticalScrollIndicator = NO;
    _paneScrollView.showsHorizontalScrollIndicator = NO;
    
    PCPageElement* scrollingPaneElement = [page firstElementForType:PCPageElementTypeScrollingPane];
    if (scrollingPaneElement != nil)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:scrollingPaneElement.resource];
        
        _paneContentViewController = [self createPaneContentViewControllerForResource:fullResource];
        
        [_paneScrollView addSubview:_paneContentViewController.view];
        [_paneScrollView setContentSize:_paneContentViewController.view.frame.size];
        [_paneScrollView setContentInset:UIEdgeInsetsMake(0, -_paneScrollView.frame.origin.x, 0, 0)];
    }
    
    [_paneScrollView setUserInteractionEnabled:YES];
    [self.mainScrollView addSubview: _paneScrollView];
    [self.mainScrollView setContentSize: _paneScrollView.frame.size];
    [self.mainScrollView bringSubviewToFront: _paneScrollView];
    
    if (_paneScrollView.frame.size.width > self.mainScrollView.frame.size.width)
    {
        CGRect scrollingPaneRect = _paneScrollView.frame;
        scrollingPaneRect.size.width = self.mainScrollView.frame.size.width;
        _paneScrollView.frame = scrollingPaneRect;
    }
    
    if (_paneScrollView.contentSize.width > _paneScrollView.frame.size.width)
    {
        _paneScrollView.contentSize = CGSizeMake(_paneScrollView.frame.size.width, _paneScrollView.contentSize.height);
    }
    
    [self initializeScrollButtons];
    [self.mainScrollView bringSubviewToFront:HUD];
}

- (PCPageElementViewController*) createPaneContentViewControllerForResource:(NSString *)fullResource
{
    return [[PCPageElementViewController alloc] initWithResource:fullResource];
}

@end
