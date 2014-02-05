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
#import "PCPageElemetTypes.h"
#import "PCPageTemplatesPool.h"
#import "PCPageControllersManager.h"
#import "RuePDFActiveZones.h"

@interface RueGifPageViewController ()

@property (nonatomic, strong) NSArray* gifViewControllers;

@end

@implementation RueGifPageViewController

+ (void) load
{
    PCPageTemplate* newTemplate = [PCPageTemplate templateWithIdentifier:22
                                                                   title:@"Basic Article Page With Gifs"
                                                             description:@""
                                                              connectors:PCTemplateAllConnectors
                                                           engineVersion:1];
    [[PCPageTemplatesPool templatesPool] registerPageTemplate:newTemplate];
    
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:newTemplate];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    NSArray* gifElements = [self sortedByWeightGifElements];
    NSMutableArray* gifViewsArray = [[NSMutableArray alloc]initWithCapacity:gifElements.count];
    
    if (gifElements && [gifElements count] > 0)
    {
        for (unsigned i = 0; i < [gifElements count]; i++)
        {
            PCPageElementGallery* element = [gifElements objectAtIndex:i];
            
            CGRect elementFrame = [self frameForGifElementAtIndex:i];
            
            if(CGRectEqualToRect(elementFrame, CGRectZero) == NO)
            {
                GifViewController* gifController = [GifViewController controllerForElement:element withFrame:elementFrame inPageViewController:self];
                [gifViewsArray addObject:gifController];
                [self.mainScrollView addSubview:gifController.view];
            }
        }
    }
    self.gifViewControllers = [NSArray arrayWithArray:gifViewsArray];
}

- (CGRect) frameForGifElementAtIndex:(int)index
{
    NSString* activeZoneType = [PCPDFActiveZoneGif stringByAppendingFormat:@"%i", index + 1];
    CGRect frame = [self activeZoneRectForType:activeZoneType];
    if(index == 0 && CGRectEqualToRect(frame, CGRectZero))
    {
        return [self activeZoneRectForType:PCPDFActiveZoneGif];
    }
    return frame;
}

- (NSArray*) sortedByWeightGifElements
{
    NSArray* galleryElements = [page elementsForType:PCPageElementTypeGallery];
    return [galleryElements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES],nil]];
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
