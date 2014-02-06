//
//  RuePageViewWithPopupsController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/25/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RuePageViewWithPopupsController.h"
#import "RuePopupViewController.h"
#import "PCSCrollView.h"
#import "PCPageControllersManager.h"
#import "PCPageElemetTypes.h"
#import "RuePDFActiveZones.h"

#define kHidePopupWhenItReceivesTouch YES

@interface RuePageViewWithPopupsController ()
{
    BOOL _transiting;
}
@property (nonatomic, strong) NSArray* popupViewControllers;


@end

@implementation RuePageViewWithPopupsController

+ (void) load
{
    PCPageTemplate* newTemplate = [PCPageTemplate templateWithIdentifier:23
                                                                   title:@"Basic Article Page With Popups"
                                                             description:@""
                                                              connectors:PCTemplateAllConnectors
                                                           engineVersion:1];
    [[PCPageTemplatesPool templatesPool] registerPageTemplate:newTemplate];
    
    [[PCPageControllersManager sharedManager] registerPageControllerClass:[self class] forTemplate:newTemplate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createPopups];
}

- (void) loadFullView
{
    [super loadFullView];
    self.mainScrollView.scrollEnabled = YES;
    
    for (RuePopupViewController* popupViewController in self.popupViewControllers)
    {
        if(popupViewController.isPresented == NO)
        {
            [popupViewController load];
        }
    }
}

- (void) unloadFullView
{
    for (RuePopupViewController* popupViewController in self.popupViewControllers)
    {
//        if(popupViewController.isPresented == NO)
//        {
            [popupViewController unload];
//        }
    }
    [super unloadFullView];
}

- (void) tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    if(_transiting == NO)
    {
        [super tapAction:gestureRecognizer];
    }
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if(kHidePopupWhenItReceivesTouch && _transiting == NO)
    {
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mainScrollView];
        RuePopupViewController* popup = [self presentedPopupAtPoint:touchPoint];
        if(popup)
        {
            [self hideWithAlphaPopup:popup];
            return NO;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (RuePopupViewController*) presentedPopupAtPoint:(CGPoint)point
{
    NSMutableArray* popupsArray = [[NSMutableArray alloc]init];
    for (RuePopupViewController* popupViewController in self.popupViewControllers)
    {
        if(popupViewController.isPresented && CGRectContainsPoint(popupViewController.view.frame, point))
        {
            [popupsArray addObject:popupViewController];
        }
    }
    
    if(popupsArray.count)
    {
        if(popupsArray.count > 1)
        {
            RuePopupViewController* returnPopup = nil;
            int returnPopupIndex = -1;
            for (RuePopupViewController* popupController in popupsArray)
            {
                int popupIndex = [popupController.view.superview.subviews indexOfObject:popupController.view];
                if(popupIndex > returnPopupIndex)
                {
                    returnPopup = popupController;
                    returnPopupIndex = popupIndex;
                }
            }
            return returnPopup;
        }
        else
        {
            return [popupsArray lastObject];
        }
    }
    else
    {
        return nil;
    }
}

- (BOOL) pdfActiveZoneAction:(PCPageActiveZone*)activeZone
{
    [super pdfActiveZoneAction:activeZone];
    
    int popupIndex = [self popupIndexForActiveZone:activeZone];
    
    if(popupIndex >= 0 && self.popupViewControllers.count > popupIndex)
    {
        RuePopupViewController* selectedPopup = [self.popupViewControllers objectAtIndex:popupIndex];
        if(selectedPopup.isPresented)
        {
            [self hidePopup:selectedPopup];
        }
        else
        {
            [self showPopup:selectedPopup];
        }
        return YES;
    }
    return NO;
}

- (void) showPopup:(RuePopupViewController*)popup
{
    _transiting = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        popup.view.hidden = NO;
        
    } completion:^(BOOL finished) {
        
        _transiting = NO;
    }];
}

- (void) hidePopup:(RuePopupViewController*)popup
{
    _transiting = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        popup.view.hidden = YES;
        
    } completion:^(BOOL finished) {
    
        _transiting = NO;
    }];
}

- (void) hideWithAlphaPopup:(RuePopupViewController*)popup
{
    _transiting = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        popup.view.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        popup.view.alpha = 1.0;
        popup.view.hidden = YES;
        _transiting = NO;
    }];
}

- (int) popupIndexForActiveZone:(PCPageActiveZone*)activeZone
{
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionPopup])
    {
        NSString* additional = [activeZone.URL stringByReplacingOccurrencesOfString:PCPDFActiveZoneActionPopup withString:@""];
        int suffixValue = [additional intValue];
        if(suffixValue == 0)
        {
            return 0;
        }
        return suffixValue - 1;
    }
    else
    {
        return -1;
    }
}

- (void) createPopups
{
    NSArray* popupsElements = [self sortedByWeightPopupElements];
    
    NSMutableArray* popups = [[NSMutableArray alloc]initWithCapacity:popupsElements.count];
    
    for (int i = 0; i < popupsElements.count; ++i)
    {
        CGRect popupFrame = [self frameForPopupAtIndex:i];
        if(CGRectEqualToRect(popupFrame, CGRectZero) == NO)
        {
            PCPageElement* element = [popupsElements objectAtIndex:i];
            RuePopupViewController* popup = [RuePopupViewController popupControllerWithIndex:i forElement:element withFrame:popupFrame onScrollView:self.mainScrollView];
            [popups addObject:popup];
            [self.mainScrollView addSubview:popup.view];
        }
    }
    
    self.popupViewControllers = [NSArray arrayWithArray:popups];
}

- (CGRect) frameForPopupAtIndex:(int)index
{
    NSString* zoneType = [PCPDFActiveZonePopup stringByAppendingFormat:@"%i", index + 1];
    CGRect frame = [self activeZoneRectForType:zoneType];
    
    if (CGRectEqualToRect(frame, CGRectZero))
    {
        if(index == 0)
        {
            frame = [self activeZoneRectForType:PCPDFActiveZonePopup];
        }
        if(CGRectEqualToRect(frame, CGRectZero))
        {
            zoneType = [PCPDFActiveZoneActionPopup stringByAppendingFormat:@"%i", index + 1];
            frame = [self activeZoneRectForType:zoneType];
            if(index == 0 && CGRectEqualToRect(frame, CGRectZero))
            {
                frame = [self activeZoneRectForType:PCPDFActiveZoneActionPopup];
            }
        }
    }
    
    return frame;
}

- (NSArray*) sortedByWeightPopupElements
{
    NSArray* popupsElements = [self.page elementsForType:PCPageElementTypePopup];
    return [popupsElements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES], nil]];
}

@end
