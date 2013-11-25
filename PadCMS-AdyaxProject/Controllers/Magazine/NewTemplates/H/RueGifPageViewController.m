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

@interface RueGifPageViewController ()

@property (nonatomic, strong) NSArray* gifViewControllers;

@end

@implementation RueGifPageViewController


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
            
            GifViewController* gifController = [GifViewController controllerForElement:element];
            
            [gifViewsArray addObject:gifController];
            
            [self.mainScrollView addSubview:gifController.view];
        }
    }
    self.gifViewControllers = [NSArray arrayWithArray:gifViewsArray];
}

- (void) loadFullView
{
    [super loadFullView];
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
