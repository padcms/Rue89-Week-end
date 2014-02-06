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
#import "RuePDFActiveZones.h"
#import "PCPageElemetTypes.h"

@interface RueMultiScrollPageViewController ()

@property (nonatomic, strong) NSArray* scrollingPaneControllers;

@end

@implementation RueMultiScrollPageViewController

+ (void) load
{
    PCPageTemplate* newTemplate = [PCPageTemplate templateWithIdentifier:26
                                                                   title:@"Multiscroll Page Template"
                                                             description:@""
                                                              connectors:PCTemplateAllConnectors
                                                           engineVersion:1];
    [[PCPageTemplatesPool templatesPool] registerPageTemplate:newTemplate];
    
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:newTemplate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainScrollView.scrollEnabled = YES;
    
    NSArray* scrollElements = [self sortetByWeightScrollingPaneElements];
    NSMutableArray* scrollControllers = [[NSMutableArray alloc] initWithCapacity:scrollElements.count];

    for (int i = 0; i < scrollElements.count; ++i)
    {
        CGRect scrollFrame = [self frameForScrollAtIndex:i];
        if(CGRectEqualToRect(scrollFrame, CGRectZero) == NO)
        {
            PCPageElement* element = [scrollElements objectAtIndex:i];
            RueScrollingPaneViewController* scrollController = [RueScrollingPaneViewController controllerForElement:element withFrame:scrollFrame onScrollView:self.mainScrollView pageViewController:self];
            [scrollControllers addObject:scrollController];
            [self.mainScrollView addSubview:scrollController.view];
        }
    }

    self.scrollingPaneControllers = [NSArray arrayWithArray:scrollControllers];
}

- (void) loadFullView
{
    [super loadFullView];
    for (RueScrollingPaneViewController* controller in self.scrollingPaneControllers)
    {
        [controller loadFullView];
    }
}

- (void) unloadFullView
{
    for (RueScrollingPaneViewController* controller in self.scrollingPaneControllers)
    {
        [controller unloadFullView];
    }
    [super unloadFullView];
}

- (CGRect) frameForScrollAtIndex:(int)index
{
    NSString* zoneType = [PCPDFActiveZoneScroller stringByAppendingFormat:@"%i", index + 1];
    CGRect frame = [self activeZoneRectForType:zoneType];
    
    if (index == 0 && CGRectEqualToRect(frame, CGRectZero))
    {
        frame = [self activeZoneRectForType:PCPDFActiveZoneScroller];
    }
    
    return frame;
}

- (NSArray*) sortetByWeightScrollingPaneElements
{
    NSArray* paneElements = [page elementsForType:PCPageElementTypeScrollingPane];
    return [paneElements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES], nil]];
}

- (BOOL) canSwipeBackWithGesture:(UIGestureRecognizer*)gesture
{
    CGPoint gestureLocation = [gesture locationInView:self.mainScrollView];
    
    for (RueScrollingPaneViewController* scrollController in self.scrollingPaneControllers)
    {
        if (CGRectContainsPoint(scrollController.view.frame, gestureLocation))
        {
            return (scrollController.contentOffset.x == 0);
        }
    }
    
    return YES;
}

@end
