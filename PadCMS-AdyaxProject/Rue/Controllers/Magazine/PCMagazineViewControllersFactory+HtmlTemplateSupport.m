//
//  PCMagazineViewControllersFactory+HtmlTemplateSupport.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/18/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCMagazineViewControllersFactory.h"
#import "PCColumnViewController.h"
#import "PCLanscapeSladeshowColumnViewController.h"
#import "PCHtmlColumnViewController.h"
#import "objc/runtime.h"
#import "FixedIllustrationTouchableColumnViewController.h"
#import "PCPageControllersManager.h"
#import "RueSlideshowViewController.h"

#import "RueScrollingPageViewController.h"

@implementation PCMagazineViewControllersFactory (HtmlTemplateSupport)

+ (void) load
{
    Method prevMethod = class_getInstanceMethod([PCMagazineViewControllersFactory class], @selector(viewControllerForColumn:));
    Method newMethod = class_getInstanceMethod([PCMagazineViewControllersFactory class], @selector(viewControllerForColumnAdvanced:));
    Method prevMethod2 = class_getInstanceMethod([PCMagazineViewControllersFactory class], @selector(viewControllerForPage:));
    Method newMethod2 = class_getInstanceMethod([PCMagazineViewControllersFactory class], @selector(viewControllerForPageAdvanced:));
    
    method_exchangeImplementations(prevMethod, newMethod);
    method_exchangeImplementations(prevMethod2, newMethod2);
}

-(PCColumnViewController*)viewControllerForColumnAdvanced:(PCColumn*)column
{
    if ([column.pages count] < 1)
        return nil;
    PCPage* firstPage = [column.pages objectAtIndex:0];
    
    //NSLog(@"page : %@", firstPage.pageTemplate);
    
    switch (firstPage.pageTemplate.identifier)
    {
        case PCSlideshowLandscapePageTemplate:
            return [[[PCLanscapeSladeshowColumnViewController alloc] initWithColumn:(PCColumn*)column] autorelease];
            break;
        case PCHTMLPageTemplate:
            return [[[PCHtmlColumnViewController alloc] initWithColumn:(PCColumn*)column] autorelease];
            break;
        case PCFixedIllustrationArticleTouchablePageTemplate:
            return [[[FixedIllustrationTouchableColumnViewController alloc] initWithColumn:(PCColumn*)column] autorelease];
            break;
        default:
            return [[[PCColumnViewController alloc] initWithColumn:(PCColumn*)column] autorelease];
            break;
    }
    return nil;
}

-(PCPageViewController*)viewControllerForPageAdvanced:(PCPage *)page
{
    if(page.pageTemplate.identifier == PCSlideshowPageTemplate)
    {
        return [[[RueSlideshowViewController alloc]initWithPage:page]autorelease];
    }
    else if (page.pageTemplate.identifier == PCScrollingPageTemplate)
    {
        return [[[RueScrollingPageViewController alloc]initWithPage:page]autorelease];
    }
    else
    {
        Class pageControllerClass = [[PCPageControllersManager sharedManager] controllerClassForPageTemplate:page.pageTemplate];
        
        if (pageControllerClass != nil)
        {
            return [[[pageControllerClass alloc] initWithPage:(PCPage *)page] autorelease];
        }
        
        return nil;
    }
}

@end
