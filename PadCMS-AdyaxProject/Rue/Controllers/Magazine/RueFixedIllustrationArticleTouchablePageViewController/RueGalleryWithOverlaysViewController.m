//
//  RueGalleryWithOverlaysViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/6/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueGalleryWithOverlaysViewController.h"
#import "PCPageElementGallery.h"
#import "PCPDFActiveZones.h"
#import "PCScrollView.h"
#import "UIView+EasyFrame.h"
#import "PCPage.h"

@interface PCGalleryWithOverlaysViewController ()
- (void)showPhotoAtIndex:(NSInteger)currentIndex;
@end

@interface RueGalleryWithOverlaysViewController ()

@property (nonatomic, strong) NSMutableArray* galleryViews;

@end

@implementation RueGalleryWithOverlaysViewController

- (void)createImageViews
{
    self.galleryImageViews = [[NSMutableArray alloc] init];
    self.zoomableViews = [[NSMutableArray alloc] init];
    self.galleryPopupImageViews = [[NSMutableArray alloc] init];
    self.popupsIndexes = [[NSMutableArray alloc] init];
    self.popupsGalleryElementLinks = [[NSMutableArray alloc] init];
    self.popupsZones = [[NSMutableArray alloc] init];
    
    self.galleryViews = [[NSMutableArray alloc] init];
    
    self.view.autoresizesSubviews = NO;
    
    float rotation = 0;
    if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft)
    {
        rotation = M_PI_2;
    }
    else
    {
        rotation = -M_PI_2;
    }
    
    CGRect              elementRect, rotatedRect;
    CGFloat             tmp;
    
    if(_horizontalOrientation)
    {
        elementRect = CGRectMake(0, 0, 768, 1024);
    } else {
        elementRect = CGRectMake(0, 0, 1024, 768);
    }
    
    self.view.frame = elementRect;
    rotatedRect = elementRect;
    tmp = rotatedRect.size.width;
    rotatedRect.size.width = rotatedRect.size.height;
    rotatedRect.size.height = tmp;
    
    for (int i=0; i < [self.galleryElements count]; i++)
    {
        PCPageElementGallery    *pageElement = [self.galleryElements objectAtIndex:i];
        
        
        UIView          *galleryElementView = [[UIView alloc] initWithFrame:CGRectMake(0, elementRect.size.height * i, elementRect.size.width, elementRect.size.height)];
        UIImageView     *galleryElementImageView = [[UIImageView alloc] initWithFrame:elementRect];
        
        if(pageElement.zoomable)   // zoom support [UIView]-[UIScrollView]-[UIView](zoomable)-[UIView](rotated)-[UIImageView](gallery element)
        {                          //                  '----[UIImageView](popup)(rotated) ...
            UIScrollView    *innerScrollView = [[UIScrollView alloc] initWithFrame:elementRect];
            [galleryElementView addSubview:innerScrollView];
            
            
            UIView          *zoomView = [[UIView alloc] initWithFrame:elementRect];
            [innerScrollView addSubview:zoomView];
            
            
            //UIView          *rotateView = [[UIView alloc] initWithFrame:elementRect];
            //[zoomView addSubview:rotateView];
            
            
           // [rotateView addSubview:galleryElementImageView];
            [zoomView addSubview:galleryElementImageView];
            
            //rotateView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            //rotateView.frame = elementRect;
            //galleryElementImageView.frame = rotatedRect;
            
            innerScrollView.tag = 1000 + i;
            [self.zoomableViews addObject:zoomView];
            
            innerScrollView.delegate = self;
            innerScrollView.bouncesZoom = NO;
            innerScrollView.maximumZoomScale = 4.0;
            innerScrollView.zoomScale = 1;
        }
        else
        {                   // no zoom      [UIView]-[UIImageView](gallery element)(rotated)
            //                  '----[UIImageView](popup)(rotated) ...
            [galleryElementView addSubview:galleryElementImageView];
            
            //galleryElementImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            galleryElementImageView.frame = elementRect;
            [self.zoomableViews addObject:[NSNull null]];
        }
        
        // Popups
        NSArray* popups = [[pageElement.dataRects allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@",PCPDFActiveZonePopup]];
        if([popups count]>0)
        {
            UIImageView     *popupImageView = [[UIImageView alloc] initWithFrame:elementRect];
            popupImageView.hidden = YES;
            [galleryElementView addSubview:popupImageView];
            [self.galleryPopupImageViews addObject:popupImageView];
            
            //popupImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            popupImageView.frame = elementRect;
            
            for (NSString* type in popups)
            {
                NSInteger       popupIndex = [[type lastPathComponent] intValue] - 1;
                
                //                NSLog(@"Gallery item %d - POPUP - %@", i, type);
                
                CGRect      rect = [pageElement rectForElementType:type];
                
                if (!CGRectEqualToRect(rect, CGRectZero))
                {
                    CGSize pageSize = rotatedRect.size;
                    float scale = pageSize.width/pageElement.size.width;
                    rect.size.width *= scale;
                    rect.size.height *= scale;
                    rect.origin.x *= scale;
                    rect.origin.y *= scale;
                    CGFloat     newX = pageElement.size.height*scale - rect.origin.y - rect.size.height;
                    CGFloat     newY = pageElement.size.width*scale - rect.origin.x - rect.size.width;
                    rect.origin.x = newX;
                    rect.origin.y = newY;
                    
                    tmp = rect.size.width;
                    rect.size.width = rect.size.height;
                    rect.size.height = tmp;
                } else {
                    rect = elementRect;
                }
                [self.popupsZones addObject:[NSValue valueWithCGRect:rect]];
                [self.popupsGalleryElementLinks addObject:[NSNumber numberWithInteger:i]];
                [self.popupsIndexes addObject:[NSNumber numberWithInteger:popupIndex]];
            }
        }
        else
        {
            [self.galleryPopupImageViews addObject:[NSNull null]];
        }
        
        [self.galleryImageViews addObject:galleryElementImageView];
        [self.mainScrollView addSubview:galleryElementView];
        [self.galleryViews addObject:galleryElementView];
        
        galleryElementView.tag = 1000 + i;
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(galleryElementTapped:)];
        tapGestureRecognizer.cancelsTouchesInView = NO;
        [galleryElementView  addGestureRecognizer:tapGestureRecognizer];
        
    }
    
    if(self.popupsZones.count == 0)
    {
        [self adjustPopupsAutomaticly];
    }
    
	[self showPhotoAtIndex:self.currentPage];
    
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation);
    
    self.view.transform = rotationTransform;
}

- (void) adjustPopupsAutomaticly
{
    NSArray* popups = [self.page elementsForType:PCPageElementTypePopup];
    for (int i = 0; i < popups.count && i < self.galleryViews.count; ++i)
    {
        UIView* galleryElementView = [self.galleryViews objectAtIndex:i];
        
        UIImageView     *popupImageView = [[UIImageView alloc] initWithFrame:galleryElementView.bounds];
        popupImageView.hidden = YES;
        [galleryElementView addSubview:popupImageView];
        [self.galleryPopupImageViews replaceObjectAtIndex:i withObject:popupImageView];
        
        popupImageView.frame = galleryElementView.bounds;
        
        for (NSString* type in popups)
        {
            NSInteger       popupIndex = i; //[[type lastPathComponent] intValue] - 1;
            
            
            CGRect      rect = galleryElementView.bounds; //[pageElement rectForElementType:type];
            
//            if (!CGRectEqualToRect(rect, CGRectZero))
//            {
//                CGSize pageSize = rotatedRect.size;
//                float scale = pageSize.width/pageElement.size.width;
//                rect.size.width *= scale;
//                rect.size.height *= scale;
//                rect.origin.x *= scale;
//                rect.origin.y *= scale;
//                CGFloat     newX = pageElement.size.height*scale - rect.origin.y - rect.size.height;
//                CGFloat     newY = pageElement.size.width*scale - rect.origin.x - rect.size.width;
//                rect.origin.x = newX;
//                rect.origin.y = newY;
//                
//                tmp = rect.size.width;
//                rect.size.width = rect.size.height;
//                rect.size.height = tmp;
//            } else {
//                rect = elementRect;
//            }
            [self.popupsZones addObject:[NSValue valueWithCGRect:rect]];
            [self.popupsGalleryElementLinks addObject:[NSNumber numberWithInteger:i]];
            [self.popupsIndexes addObject:[NSNumber numberWithInteger:popupIndex]];
        }
    }
}

#pragma mark - Interface Orientation

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark -

@end
