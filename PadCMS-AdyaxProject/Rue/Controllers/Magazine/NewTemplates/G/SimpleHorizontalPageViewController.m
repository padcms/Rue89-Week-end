//
//  SimpleHorizontalPageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/23/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "SimpleHorizontalPageViewController.h"
#import "PCPageControllersManager.h"
//#import <QuartzCore/QuartzCore.h>
#import "RueBrowserViewController.h"

@interface PCPageViewController ()

- (void) createWebBrowserViewWithFrame:(CGRect)frame;

@end

@interface SimpleHorizontalPageViewController ()

@end

@implementation SimpleHorizontalPageViewController

+ (void) load
{
    PCPageTemplate* newTemplate = [PCPageTemplate templateWithIdentifier:27
                                                                   title:@"Simple Horizontal Page"
                                                             description:@""
                                                              connectors:PCTemplateAllConnectors
                                                           engineVersion:1];
    [[PCPageTemplatesPool templatesPool] registerPageTemplate:newTemplate];
    
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:newTemplate];
}

- (void) createWebBrowserViewWithFrame:(CGRect)frame
{
    [super createWebBrowserViewWithFrame:frame];
    
    [(RueBrowserViewController*)webBrowserViewController setIsHorizontal:YES];
}

@end
