//
//  RuePageWithMenuViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RuePageWithMenuViewController.h"
#import "PCScrollView.h"
#import "RueMultiScrollingAticlesViewController.h"
#import "PCPageControllersManager.h"
#import "PCPageElemetTypes.h"
#import "RuePDFActiveZones.h"
#import "RuePageElementBackground.h"
#import "PCPageElementActiveZone.h"
#import "ScrollingArticleViewController.h"

@interface PCPageViewController ()

- (void) hideVideoWebView;
- (void) createWebBrowserViewForActiveZone:(PCPageElementActiveZone*)activeZone;
- (void) createWebBrowserViewWithFrame:(CGRect)frame onScrollView:(UIScrollView*)scrollView;

@end

@interface RuePageWithMenuViewController ()

@property (nonatomic, strong) RueMultiScrollingAticlesViewController* scrollingArticlesController;

@end

@implementation RuePageWithMenuViewController

+ (void) load
{
    PCPageTemplate* newTemplate = [PCPageTemplate templateWithIdentifier:24
                                                                   title:@"Scrolling Gallery with Fixed Menu"
                                                             description:@""
                                                              connectors:PCTemplateAllConnectors
                                                           engineVersion:1];
    [[PCPageTemplatesPool templatesPool] registerPageTemplate:newTemplate];
    
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:newTemplate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray* galleryElements = [self sortetByWeightGalleryElements];
    
    self.scrollingArticlesController = [[RueMultiScrollingAticlesViewController alloc]initWithElements:galleryElements];
    
    [self.mainScrollView insertSubview:self.scrollingArticlesController.view belowSubview:self.backgroundViewController.view];
    
    self.backgroundViewController.view.userInteractionEnabled = NO;
    
    RuePageElementBackground* backgroundElement = (RuePageElementBackground*)[self.page firstElementForType:PCPageElementTypeBackground];
    
    if(backgroundElement.showOnTop)
    {
        [self setCurrentArticleIndex:0];
        [self.scrollingArticlesController setCurrentArticleIndexTo:0 animated:NO withCompletion:nil];
    }
}

- (void) loadFullView
{
    [super loadFullView];
    [self.scrollingArticlesController loadFullView];
}

- (void) unloadFullView
{
    [self.scrollingArticlesController unloadFullView];
    [super unloadFullView];
}

- (void) setCurrentArticleIndex:(int)index
{
    if(index >= 0
       && index < self.scrollingArticlesController.contentViewControllers.count
       && self.scrollingArticlesController.isChangingArticles == NO
       && self.scrollingArticlesController.currentArticleIndex != index)
    {
        [self.scrollingArticlesController setCurrentArticleIndexTo:index animated:YES withCompletion:nil];
        if(self.scrollingArticlesController.hasVideoBrowserOn)
        {
            [self hideVideoWebView];
            self.scrollingArticlesController.hasVideoBrowserOn = NO;
        }
    }
}

- (BOOL) pdfActiveZoneAction:(PCPageActiveZone*)activeZone
{
    [super pdfActiveZoneAction:activeZone];
    
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionButton])
    {
        [self setCurrentArticleIndex:[self scrollerIndexForZone:activeZone]];
        return YES;
    }
    return NO;
}

- (int) scrollerIndexForZone:(PCPageActiveZone*)activeZone
{
    NSString* suffix = [activeZone.URL lastPathComponent];
    
    int index = [suffix intValue];
    if(index == 0)
    {
        suffix = [activeZone.URL stringByReplacingOccurrencesOfString:PCPDFActiveZoneActionButton withString:@""];
        index = [suffix intValue];
    }
    if(index == 0)
    {
        return 0;
    }
    return index - 1;
}

- (NSArray*) sortetByWeightGalleryElements
{
    NSArray* galleryElements = [self.page elementsForType:PCPageElementTypeGallery];
    return [galleryElements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES], nil]];
}

#pragma mark - Video Support

- (void) createWebBrowserViewForActiveZone:(PCPageElementActiveZone*)activeZone
{
    if([activeZone.pageElement.fieldTypeName isEqualToString:PCPageElementTypeGallery])
    {
        ScrollingArticleViewController* articleController = [self.scrollingArticlesController currentArticleController];
        
        if(articleController && self.scrollingArticlesController.isChangingArticles == NO && activeZone.pageElement == articleController.pageElement)
        {
            CGRect videoWebViewRect = [articleController activeZoneRectForType:activeZone.URL];
            [self createWebBrowserViewWithFrame:videoWebViewRect onScrollView:articleController.mainScrollView];
            self.scrollingArticlesController.hasVideoBrowserOn = YES;
            return;
        }
    }
    else
    {
        [super createWebBrowserViewForActiveZone:activeZone];
    }
}

- (NSArray*) activeZonesAtPoint:(CGPoint)point
{
    NSMutableArray* activeZones = [[NSMutableArray alloc] init];
    
    for (PCPageElement* element in self.page.elements)
    {
        if([element.fieldTypeName isEqualToString:PCPageElementTypeGallery])
        {
            [activeZones addObjectsFromArray:[self.scrollingArticlesController activeZonesForGalleryElement:element atPoint:point inPageController:self]];
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

- (CGRect) activeZoneRectForType:(NSString*)zoneType
{
    for (PCPageElement* element in self.page.elements)
    {
        CGRect rect = [element rectForElementType:zoneType];
        if (!CGRectEqualToRect(rect, CGRectZero))
        {
            CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
            float scale = pageSize.width/element.size.width;
            rect.size.width *= scale;
            rect.size.height *= scale;
            rect.origin.x *= scale;
            rect.origin.y *= scale;
            rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
            
            if([element.fieldTypeName isEqualToString:PCPageElementTypeGallery])
            {
                rect = [self.mainScrollView convertRect:rect fromView:self.scrollingArticlesController.currentArticleController.mainScrollView];
            }
            return rect;
        }
    }
    return CGRectZero;
}

@end
