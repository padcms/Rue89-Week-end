//
//  PCSliderBasedMiniArticleViewController+CurrentActiveZone.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/14/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCSliderBasedMiniArticleViewController.h"
#import <objc/runtime.h>

@interface PCPageViewController ()

- (void)hideVideoWebView;

@end

@implementation PCSliderBasedMiniArticleViewController (CurrentActiveZone)

+ (void) load
{
    Method showArticleAtIndexMethod = class_getInstanceMethod([PCSliderBasedMiniArticleViewController class], @selector(showArticleAtIndex:));
    Method showArticleAtIndexMethodAdvanced = class_getInstanceMethod([PCSliderBasedMiniArticleViewController class], @selector(showArticleAtIndexAdvanced:));
    
    method_exchangeImplementations(showArticleAtIndexMethod, showArticleAtIndexMethodAdvanced);
}

- (NSArray*) activeZonesAtPoint:(CGPoint)point
{
    NSMutableArray* activeZones = [[NSMutableArray alloc] init];
    
    for (PCPageElement* element in self.page.elements)
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
                //                UIView* testView = [[UIView alloc] initWithFrame:rect];
                //                testView.backgroundColor = [UIColor redColor];
                //                [self.mainScrollView addSubview:testView];
                if (CGRectContainsPoint(rect, point))
                {
                    [activeZones addObject:pdfActiveZone];
                }
                //                NSLog(@"fieldTypeName=%@ pdfActiveZone=%@",element.fieldTypeName,pdfActiveZone.URL);
            }
        }
    }
    
    if(activeZones.count > 1 && self.miniArticleViews.count > 1 && currentMiniArticleIndex < self.miniArticleViews.count && currentMiniArticleIndex >= 0)
    {
        PCPageElementViewController* currentMiniArticleController = [self .miniArticleViews objectAtIndex:currentMiniArticleIndex];
        
        NSArray* currentElementActiveZones = currentMiniArticleController.element.activeZones;
        
        for (id activeZone in currentElementActiveZones)
        {
            if([activeZones containsObject:activeZone])
            {
                return @[activeZone];
            }
        }
    }
    
    return activeZones;
}

- (void) showArticleAtIndexAdvanced:(NSUInteger)index
{
    [self showArticleAtIndexAdvanced:index];
    
    [self hideVideoWebView];
}

@end
