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
#import "PCPDFActiveZones.h"

#define kHidePopupWhenHiReceiveTouch YES

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
    
    //--------------- place button in active zones for debugging ------------
//    for (PCPageElement* element in self.page.elements)
//    {
//        for (PCPageActiveZone* pdfActiveZone in element.activeZones)
//        {
//            CGRect rect = pdfActiveZone.rect;
//            if (!CGRectEqualToRect(rect, CGRectZero))
//            {
//                UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//                [btn setTitle:[pdfActiveZone.URL lastPathComponent] forState:UIControlStateNormal];
//                btn.frame = rect;
//                btn.backgroundColor = [UIColor yellowColor];
//                btn.userInteractionEnabled = NO;
//                [self.mainScrollView addSubview:btn];
//            }
//        }
//    }
    //------------------------------------------------------------------------
    
    [self createPopups];
}

- (void) loadFullView
{
    [super loadFullView];
    self.mainScrollView.scrollEnabled = YES;
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
    if(kHidePopupWhenHiReceiveTouch && _transiting == NO)
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

- (NSArray*) activeZonesAtPoint:(CGPoint)point
{
    NSMutableArray* activeZones = [[NSMutableArray alloc] init];

    for (PCPageElement* element in self.page.elements)
    {
        for (PCPageActiveZone* pdfActiveZone in element.activeZones)
        {
            CGRect rect = pdfActiveZone.rect;
            if (!CGRectEqualToRect(rect, CGRectZero))
            {
                if (CGRectContainsPoint(rect, point))
                {
                    [activeZones addObject:pdfActiveZone];
                }
            }
        }
    }
    return activeZones;
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
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionButton])
    {
        NSString* additional = [activeZone.URL lastPathComponent];
        return [additional intValue] - 1;
    }
    else
    {
        return -1;
    }
}

- (void) createPopups
{
    NSArray* popupsElements = [self.page elementsForType:PCPageElementTypePopup];
    
    popupsElements = [popupsElements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES], nil]];
    
    NSMutableArray* popups = [[NSMutableArray alloc]initWithCapacity:popupsElements.count];
    
    for (int i = 0; i < popupsElements.count; ++i)
    {
        PCPageElement* element = [popupsElements objectAtIndex:i];
        
        RuePopupViewController* popup = [RuePopupViewController popupControllerWithIndex:i forElement:element];
        [popups addObject:popup];
        [self.mainScrollView addSubview:popup.view];
    }
    
    self.popupViewControllers = [NSArray arrayWithArray:popups];
}


@end
