//
//  PCSliderBasedMiniArticleViewController+CurrentActiveZone.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/14/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCSliderBasedMiniArticleViewController.h"

@implementation PCSliderBasedMiniArticleViewController (CurrentActiveZone)

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

/*-(void)showArticleAtIndex:(NSUInteger)index
{
    
    //TODO we need something for more blurring page change
    if (miniArticleViews != nil && [miniArticleViews count] > index)
    {
        if([self.bodyViewController isEqual:[miniArticleViews objectAtIndex:index]])
        {
            return;
        }
        
        for (UIView* view in [self.thumbsView subviews])
            if ([view isKindOfClass:[UIButton class]])
            {
                [(UIButton*)view setSelected:[view tag]==index];
            }
        
        PCPageElementViewController *prevController = [self.bodyViewController retain];
        
        self.bodyViewController = [miniArticleViews objectAtIndex:index];
        
        currentMiniArticleIndex = index;
        
        [self.mainScrollView addSubview:self.bodyViewController.view];
        
        
		if (!self.bodyViewController.element.isComplete && index!=0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:self.bodyViewController.element];
            NSLog(@"BOOST message from miniarticle element - %d", self.bodyViewController.element?self.bodyViewController.element.identifier:0);
		}
		
        [self.bodyViewController loadFullViewImmediate];
        [self.bodyViewController showHUD];
        
        [prevController.view removeFromSuperview];
        //        if (self.page.pageTemplate.identifier==PCFlashBulletInteractivePageTemplate)
        //        {
        //            self.bodyViewController.view.alpha = 0.0;
        //
        //            [UIView beginAnimations:nil context:NULL];
        //            [UIView setAnimationDuration:.5];
        //            self.bodyViewController.view.alpha = 1.0;
        //            [UIView commitAnimations];
        //        }
        [prevController unloadView];
        
        [prevController release];
    }
 
}*/

@end
