//
//  RueFixedIllustrationArticleTouchablePageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/1/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueFixedIllustrationArticleTouchablePageViewController.h"
#import "PCScrollView.h"
#import "RueGalleryWithOverlaysViewController.h"
#import "PCPageElemetTypes.h"
#import "PCPDFActiveZones.h"

typedef enum{
    GalleryPresentstionStateHidden,
    GalleryPresentstionStatePresenting,
    GalleryPresentstionStatePresented
} GalleryPresentstionState;

@interface RueFixedIllustrationArticleTouchablePageViewController ()
{
    GalleryPresentstionState galleryPresentationState;
}

- (void)deviceOrientationDidChange;
- (BOOL)isOrientationChanged:(UIDeviceOrientation)orientation;
- (void)showGallery;
- (void)hideGallery;

@end

@implementation RueFixedIllustrationArticleTouchablePageViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    PCPageElementBody* bodyElement = (PCPageElementBody*)[self.page firstElementForType:PCPageElementTypeBody];
    
    if(bodyElement)
    {
        [self.bodyViewController.view setHidden:!bodyElement.showTopLayer];
        [self changeVideoLayout:self.bodyViewController.view.hidden];
    }
    
    [self.articleView setScrollEnabled:self.bodyViewController.view.hidden];
    
    if (bodyElement && bodyElement.showGalleryOnRotate && [self.page elementsForType:PCPageElementTypeGallery].count > 0)
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        currentMagazineOrientation = [[UIDevice currentDevice] orientation];
        if(currentMagazineOrientation==UIDeviceOrientationUnknown)
        {
            UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            if(UIInterfaceOrientationIsLandscape(currentOrientation))
            {
                currentMagazineOrientation = currentOrientation == UIInterfaceOrientationLandscapeLeft ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationLandscapeRight;
            } else
                if(UIInterfaceOrientationIsPortrait(currentOrientation))
                {
                    currentMagazineOrientation = currentOrientation == UIInterfaceOrientationPortrait ? UIDeviceOrientationPortrait : UIDeviceOrientationPortraitUpsideDown;
                }
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        NSLog(@"registered");
        
        self.galleryWithOverlaysViewController = [[RueGalleryWithOverlaysViewController alloc] initWithPage:self.page];
        
    }
    
    [self.articleView setScrollEnabled:( ! self.bodyViewController.view.hidden )];
}

-(void)tapAction:(id)sender
{
    CGPoint tapLocation = [sender locationInView:[sender view]];
    
    BOOL firstCheck = (!self.bodyViewController.view.hidden&&
                       ((NSArray*)[super activeZonesAtPoint:tapLocation]).count == 0);
    
    BOOL secondCheck = (self.bodyViewController.view.hidden && ![self.page hasPageActiveZonesOfType:PCPDFActiveZoneActionButton]);
    
    [UIView transitionWithView: mainScrollView
                      duration: 0.35f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         
         if (firstCheck)
         {
             CGPoint tapLocationWithOffset;
             tapLocationWithOffset.x = self.articleView.contentOffset.x + tapLocation.x;
             tapLocationWithOffset.y = self.articleView.contentOffset.y + tapLocation.y;
             NSArray* actions = [self activeZonesAtPoint:tapLocationWithOffset];
             for (PCPageActiveZone* action in actions)
                 if ([self pdfActiveZoneAction:action])
                     break;
             if (actions.count == 0)
             {
                 self.bodyViewController.view.hidden = YES;
                 [self changeVideoLayout:self.bodyViewController.view.hidden];
             }
         }
         
         else if (secondCheck)
         {
             [self.articleView setScrollEnabled:self.bodyViewController.view.hidden];
             [self.bodyViewController.view setHidden:!self.bodyViewController.view.hidden];
             [self changeVideoLayout:self.bodyViewController.view.hidden];
         }
         
         
     } completion: ^(BOOL isFinished) {
         
     }];
    
    if (!firstCheck && ! secondCheck) {
        [super tapAction:sender];
    }
    
    
    
    [self.articleView setScrollEnabled:( ! self.bodyViewController.view.hidden )];
}

-(BOOL) pdfActiveZoneAction:(PCPageActiveZone*)activeZone
{
    [super pdfActiveZoneAction:activeZone];
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionButton])
    {
        [self.articleView setScrollEnabled:self.bodyViewController.view.hidden];
        [self.bodyViewController.view setHidden:!self.bodyViewController.view.hidden];
        [self changeVideoLayout:self.bodyViewController.view.hidden];
        return YES;
    }
    return NO;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}


#pragma mark - private

- (void) checkFofGalleryPresentationState
{
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    if(UIDeviceOrientationIsPortrait(currentDeviceOrientation) && galleryPresentationState == GalleryPresentstionStatePresented)
    {
        [self hideGallery];
    }
    else if (UIDeviceOrientationIsLandscape(currentDeviceOrientation) && galleryPresentationState == GalleryPresentstionStateHidden)
    {
        if([self isPresentedPage])
        {
            [self showGallery];
        }
    }
}

-(void)showGallery
{
    if(galleryPresentationState == GalleryPresentstionStateHidden)
    {
        galleryPresentationState = GalleryPresentstionStatePresenting;
        [self.magazineViewController.mainViewController presentViewController:self.galleryWithOverlaysViewController animated:YES completion:^{
            
            galleryPresentationState = GalleryPresentstionStatePresented;
            [self checkFofGalleryPresentationState];
        }];
    }
}

-(void)hideGallery
{
    if (galleryPresentationState == GalleryPresentstionStatePresented)
    {
        galleryPresentationState = GalleryPresentstionStatePresenting;
        [self.magazineViewController.mainViewController dismissViewControllerAnimated:YES completion:^{
            
            galleryPresentationState = GalleryPresentstionStateHidden;
            [self checkFofGalleryPresentationState];
        }];
    }
}

-(void)deviceOrientationDidChange
{
    if(galleryPresentationState != GalleryPresentstionStatePresenting)
    {
        [self checkFofGalleryPresentationState];
    }
}

- (BOOL)isOrientationChanged:(UIDeviceOrientation)orientation
{
    UIDeviceOrientation tempOrientation;
    tempOrientation = currentMagazineOrientation;
    
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        currentMagazineOrientation = orientation;
        return (UIDeviceOrientationIsPortrait(tempOrientation));
    }
    else if (UIDeviceOrientationIsPortrait(orientation))
    {
        currentMagazineOrientation = orientation;
        return (UIDeviceOrientationIsLandscape(tempOrientation));
    }
    return NO;
}

- (BOOL) isPresentedPage
{
    return (self.columnViewController == self.magazineViewController.currentColumnViewController && self == self.columnViewController.currentPageViewController);
}

@end
