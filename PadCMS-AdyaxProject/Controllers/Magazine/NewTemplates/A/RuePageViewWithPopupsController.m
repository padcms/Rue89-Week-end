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

@interface RuePageViewWithPopupsController ()
{
    BOOL _transiting;
}
@property (nonatomic, strong) NSArray* popupViewControllers;


@end

@implementation RuePageViewWithPopupsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createPopups];

    
}

- (void) tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    if(_transiting == NO)
    {
        [super tapAction:gestureRecognizer];
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
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        popup.view.hidden = NO;
        
    } completion:^(BOOL finished) {
        
        _transiting = NO;
    }];
}

- (void) hidePopup:(RuePopupViewController*)popup
{
    _transiting = YES;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        popup.view.hidden = YES;
        
    } completion:^(BOOL finished) {
        
        _transiting = NO;
    }];
}

- (int) popupIndexForActiveZone:(PCPageActiveZone*)activeZone
{
//    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionButton])
//    {
//        NSString* additional = [activeZone.URL lastPathComponent];
//        //if (self.page.pageTemplate.identifier == PCInteractiveBulletsPageTemplate)
//        {
//            [self showArticleAtIndex:[additional integerValue] - 1];
    return 0;
}

- (void) createPopups
{
    NSArray* popupsElements = [self.page elementsForType:PCPageElementTypePopup];
    
    NSMutableArray* popups = [[NSMutableArray alloc]initWithCapacity:popupsElements.count];
    
    for (PCPageElement* element in popupsElements)
    {
        RuePopupViewController* popup = [RuePopupViewController popupControllerForElement:element];
        [popups addObject:popup];
        [self.mainScrollView addSubview:popup.view];
    }
    
    self.popupViewControllers = [NSArray arrayWithArray:popups];
}


@end
