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

@interface RuePageWithMenuViewController ()

@property (nonatomic, strong) RueMultiScrollingAticlesViewController* multiArticlesController;

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
    
    self.multiArticlesController = [[RueMultiScrollingAticlesViewController alloc]initWithElements:galleryElements];
    
    [self.mainScrollView insertSubview:self.multiArticlesController.view belowSubview:self.backgroundViewController.view];
    
    self.backgroundViewController.view.userInteractionEnabled = NO;
    
    RuePageElementBackground* backgroundElement = (RuePageElementBackground*)[self.page firstElementForType:PCPageElementTypeBackground];
    
    if(backgroundElement.showOnTop)
    {
        [self setCurrentArticleIndex:0];
        [self.multiArticlesController setCurrentArticleIndexTo:0 animated:NO withCompletion:nil];
    }
}

- (void) loadFullView
{
    [super loadFullView];
    [self.multiArticlesController loadFullView];
}

- (void) unloadFullView
{
    [self.multiArticlesController unloadFullView];
    [super unloadFullView];
}

- (void) setCurrentArticleIndex:(int)index
{
    if(index >= 0
       && index < self.multiArticlesController.contentViewControllers.count
       && self.multiArticlesController.isChangingArticles == NO
       && self.multiArticlesController.currentArticleIndex != index)
    {
        [self.multiArticlesController setCurrentArticleIndexTo:index animated:YES withCompletion:nil];
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

/*- (void) createWebBrowserViewForActiveZone:(PCPageElementActiveZone*)activeZone
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
}*/

//- (NSArray*) activeZonesAtPoint:(CGPoint)point
//{
//    NSMutableArray* activeZones = [[NSMutableArray alloc] init];
//    
//    for (PCPageElement* element in self.page.elements)
//    {
//        if([element.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
//        {
//            [activeZones addObjectsFromArray:[self activeZonesInScrollingPaneElement:element atPoint:point]];
//        }
//        else
//        {
//            for (PCPageActiveZone* pdfActiveZone in element.activeZones)
//            {
//                CGRect rect = pdfActiveZone.rect;
//                if (!CGRectEqualToRect(rect, CGRectZero))
//                {
//                    //                    CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
//                    //                    float scale = pageSize.width/element.size.width;
//                    //                    rect.size.width *= scale;
//                    //                    rect.size.height *= scale;
//                    //                    rect.origin.x *= scale;
//                    //                    rect.origin.y *= scale;
//                    rect.origin.y = element.size.height/**scale*/ - rect.origin.y - rect.size.height;
//                    
//                    if (CGRectContainsPoint(rect, point))
//                    {
//                        [activeZones addObject:pdfActiveZone];
//                    }
//                }
//            }
//        }
//    }
//    return [self sortActiveZonesByPriority:activeZones];
//}

//- (NSArray*) sortActiveZonesByPriority:(NSArray*)array //scrolling pane zones go to the beginning of array
//{
//    return [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        
//        PCPageElementActiveZone* activeZone1 = obj1;
//        PCPageElementActiveZone* activeZone2 = obj2;
//        
//        if([activeZone1.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
//        {
//            if([activeZone2.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
//            {
//                return NSOrderedSame;
//            }
//            else
//            {
//                return NSOrderedAscending;
//            }
//        }
//        else if([activeZone2.pageElement.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
//        {
//            return NSOrderedDescending;
//        }
//        else
//        {
//            return NSOrderedSame;
//        }
//    }];
//}

//- (NSArray*) activeZonesInScrollingPaneElement:(PCPageElement*)element atPoint:(CGPoint)point
//{
//    NSMutableArray* activeZones = [[NSMutableArray alloc]init];
//    
//    for (RueScrollingPaneViewController* controller in self.scrollingPaneControllers)
//    {
//        if(CGRectContainsPoint(controller.scrollView.frame, point))
//        {
//            for (PCPageActiveZone* pdfActiveZone in element.activeZones)
//            {
//                CGRect rect = pdfActiveZone.rect;
//                if (!CGRectEqualToRect(rect, CGRectZero))
//                {
//                    //                    CGSize pageSize = _paneContentViewController.view.frame.size;//[self.columnViewController pageSizeForViewController:self];
//                    //                    float scale = pageSize.width/element.size.width;
//                    //                    rect.size.width *= scale;
//                    //                    rect.size.height *= scale;
//                    //                    rect.origin.x *= scale;
//                    //                    rect.origin.y *= scale;
//                    rect.origin.y = element.size.height/**scale*/ - rect.origin.y - rect.size.height;
//                    
//                    CGPoint pointInPane = [controller.scrollView convertPoint:point fromView:self.mainScrollView];
//                    
//                    if (CGRectContainsPoint(rect, pointInPane))
//                    {
//                        [activeZones addObject:pdfActiveZone];
//                    }
//                }
//            }
//        }
//        break;
//    }
//    
//    return activeZones;
//}

//- (CGRect) activeZoneRectForType:(NSString*)zoneType
//{
//    for (PCPageElement* element in self.page.elements)
//    {
//        CGRect rect = [element rectForElementType:zoneType];
//        if (!CGRectEqualToRect(rect, CGRectZero))
//        {
//            if([element.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])
//            {
//                //                CGSize pageSize = _paneContentViewController.view.frame.size;
//                //                float scale = pageSize.width/element.size.width;
//                //                rect.size.width *= scale;
//                //                rect.size.height *= scale;
//                //                rect.origin.x *= scale;
//                //                rect.origin.y *= scale;
//                rect.origin.y = element.size.height/**scale*/ - rect.origin.y - rect.size.height;
//                
//                rect = [self.mainScrollView convertRect:rect fromView:[self scrollControllerForElement:element].view];
//                
//                return rect;
//            }
//            else
//            {
//                CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
//                float scale = pageSize.width/element.size.width;
//                rect.size.width *= scale;
//                rect.size.height *= scale;
//                rect.origin.x *= scale;
//                rect.origin.y *= scale;
//                rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
//                return rect;
//            }
//        }
//    }
//    return CGRectZero;
//}

@end
