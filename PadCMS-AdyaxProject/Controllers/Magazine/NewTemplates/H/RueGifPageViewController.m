//
//  RueGifPageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/22/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueGifPageViewController.h"
#import "PCScrollView.h"
#import "GifView.h"

@interface RueGifPageViewController ()

@property (nonatomic, strong) NSArray* gifViews;

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
            GifView* gifView = [GifView gifViewForElement:element];
            [gifViewsArray addObject:gifView];
            
            [self.mainScrollView addSubview:gifView];
        }
    }
}

- (void) loadFullView
{
    [super loadFullView];
    for (GifView* gif in self.gifViews)
    {
        [gif startShowing];
    }
}

- (void) unloadFullView
{
    for (GifView* gif in self.gifViews)
    {
        [gif stopShowing];
    }
    [super unloadFullView];
}

@end
