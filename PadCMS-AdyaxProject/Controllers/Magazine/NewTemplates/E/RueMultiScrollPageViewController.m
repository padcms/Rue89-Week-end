//
//  RueMultiScrollPageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/29/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueMultiScrollPageViewController.h"
#import "PCPageControllersManager.h"
#import "PCScrollView.h"
#import "RueScrollingPaneViewController.h"

@interface RueMultiScrollPageViewController ()

@property (nonatomic, strong) NSArray* ScrollingPaneControllers;

@end

@implementation RueMultiScrollPageViewController

+ (void) load
{
    PCPageTemplate* newTemplate = [PCPageTemplate templateWithIdentifier:26
                                                                   title:@"Multiscroll Page"
                                                             description:@""
                                                              connectors:PCTemplateAllConnectors
                                                           engineVersion:1];
    [[PCPageTemplatesPool templatesPool] registerPageTemplate:newTemplate];
    
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:newTemplate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainScrollView.scrollEnabled = NO;
    
    NSArray* scrollersActiveZones = [self scrollActiveZones];
    NSArray* scrollElements = [self sortetByWeightPageElementsOfType:PCPageElementTypeScrollingPane];
    NSMutableArray* scrollControllers = [[NSMutableArray alloc] initWithCapacity:scrollersActiveZones.count];
    
    for (int i = 0; i < scrollersActiveZones.count && i < scrollElements.count; ++i)
    {
        PCPageActiveZone* activeZone = scrollersActiveZones[i];
        RueScrollingPaneViewController* scrollController = [RueScrollingPaneViewController controllerForElement:scrollElements[i] atZone:[self activeZoneRectForType:activeZone.URL]];
        [scrollControllers addObject:scrollController];
        [self.mainScrollView addSubview:scrollController.view];
    }
    
    self.ScrollingPaneControllers = [NSArray arrayWithArray:scrollControllers];
}

- (void) loadFullView
{
    [super loadFullView];
    for (RueScrollingPaneViewController* controller in self.ScrollingPaneControllers)
    {
        [controller loadFullView];
    }
}

- (void) unloadFullView
{
    for (RueScrollingPaneViewController* controller in self.ScrollingPaneControllers)
    {
        [controller unloadFullView];
    }
    [super unloadFullView];
}

- (NSArray*) scrollActiveZones
{
    NSMutableArray* activeZones = [[NSMutableArray alloc] init];
    
    for (PCPageElement* element in self.page.elements)
    {
        for (PCPageActiveZone* pdfActiveZone in element.activeZones)
        {
            if([pdfActiveZone.URL hasPrefix:PCPDFActiveZoneScroller])
            {
                [activeZones addObject:pdfActiveZone];
            }
        }
    }
    return [activeZones sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"URL" ascending:YES]]];
}

- (NSArray*) sortetByWeightPageElementsOfType:(NSString*)elementType
{
    NSArray* elementsOfType = [page elementsForType:elementType];
    elementsOfType = [elementsOfType sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES], nil]];
    return elementsOfType;
}

- (BOOL) canSwipeBackWithGesture:(UIGestureRecognizer*)gesture
{
    CGPoint gestureLocation = [gesture locationInView:self.mainScrollView];
    
    for (RueScrollingPaneViewController* scrollController in self.ScrollingPaneControllers)
    {
        if (CGRectContainsPoint(scrollController.view.frame, gestureLocation))
        {
            return (scrollController.contentOffset.x == 0);
        }
    }
    
    return YES;
}

@end
