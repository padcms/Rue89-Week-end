//
//  RueGifPageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/22/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueGifPageViewController.h"
#import "PCScrollView.h"
#import "GifViewController.h"

#import "PCPageTemplatesPool.h"
#import "PCPageControllersManager.h"

@interface RueGifPageViewController ()

@property (nonatomic, strong) NSArray* gifViewControllers;

@end

@implementation RueGifPageViewController

+ (void) load
{
    PCPageTemplate* newTemplate = [PCPageTemplate templateWithIdentifier:22
                                                                   title:@"Scrolling Page With Gifs"
                                                             description:@""
                                                              connectors:PCTemplateAllConnectors
                                                           engineVersion:1];
    [[PCPageTemplatesPool templatesPool] registerPageTemplate:newTemplate];
    
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:newTemplate];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    NSArray* gifElements = [page elementsForType:PCPageElementTypeGallery];
    
    NSMutableArray* gifViewsArray = [[NSMutableArray alloc]initWithCapacity:gifElements.count];
    
    if (gifElements && [gifElements count] > 0)
    {
        for (unsigned i = 0; i < [gifElements count]; i++)
        {
            PCPageElementGallery* element = [gifElements objectAtIndex:i];
            if([element.dataRects valueForKey:@"gif"])
            {
                GifViewController* gifController = [GifViewController controllerForElement:element inPageViewController:self];
                [gifViewsArray addObject:gifController];
                [self.mainScrollView addSubview:gifController.view];
            }
        }
    }
    self.gifViewControllers = [NSArray arrayWithArray:gifViewsArray];
}

- (void) loadFullView
{
    [super loadFullView];
    
    self.mainScrollView.scrollEnabled = YES;
    
    for (GifViewController* gifController in self.gifViewControllers)
    {
        [gifController startShowing];
    }
}

- (void) unloadFullView
{
    for (GifViewController* gifController in self.gifViewControllers)
    {
        [gifController stopShowing];
    }
    [super unloadFullView];
}

@end
