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

@implementation PCMagazineViewControllersFactory (HtmlTemplateSupport)

+ (void) load
{
    Method prevMethod = class_getInstanceMethod([PCMagazineViewControllersFactory class], @selector(viewControllerForColumn:));
    Method newMethod = class_getInstanceMethod([PCMagazineViewControllersFactory class], @selector(viewControllerForColumnAdvanced:));
    
    method_exchangeImplementations(prevMethod, newMethod);
}

-(PCColumnViewController*)viewControllerForColumnAdvanced:(PCColumn*)column
{
    if ([column.pages count] < 1)
        return nil;
    PCPage* firstPage = [column.pages objectAtIndex:0];
    
    NSLog(@"page : %@", firstPage.pageTemplate);
    
    switch (firstPage.pageTemplate.identifier)
    {
        case PCSlideshowLandscapePageTemplate:
            return [[[PCLanscapeSladeshowColumnViewController alloc] initWithColumn:(PCColumn*)column] autorelease];
            break;
        case PCHTMLPageTemplate:
            return [[[PCHtmlColumnViewController alloc] initWithColumn:(PCColumn*)column] autorelease];
            break;
        default:
            return [[[PCColumnViewController alloc] initWithColumn:(PCColumn*)column] autorelease];
            break;
    }
    return nil;
}

@end
