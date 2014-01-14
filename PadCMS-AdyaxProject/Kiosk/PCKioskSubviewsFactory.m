//
//  PCKioskSubviewsFactory.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 23.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskSubviewsFactory.h"
#import "RueKioskShelfView.h"
#import "AIRKioskGalleryView.h"
#import "DCCVKioskGalleryView.h"

@implementation PCKioskSubviewsFactory

-(NSArray*) subviewsListWithFrame:(CGRect) frame
{
    NSArray     *result = nil;
    
    Class kioskShelfViewClass = [PCKioskShelfView class];
#ifdef RUE
    kioskShelfViewClass = [RueKioskShelfView class];
#endif
    
    PCKioskShelfView     *shelfSubview = [[kioskShelfViewClass alloc] initWithFrame:frame];
    
    shelfSubview.tag = [PCKioskShelfView subviewTag];
    shelfSubview.hidden = YES;
    
    
#ifndef RUE
    PCKioskGalleryView     *gallerySubview = [[[self kioskGalleryViewClass] alloc] initWithFrame:frame];
    
    gallerySubview.tag = [PCKioskGalleryView subviewTag];
    gallerySubview.hidden = YES;
#endif
    
    
#ifdef RUE
    result = [NSArray arrayWithObjects:
              shelfSubview,
              //gallerySubview,
              nil];
#else
    result = [NSArray arrayWithObjects:
              gallerySubview,
              shelfSubview,
              nil];
#endif
    
    return result;
}

- (Class) kioskGalleryViewClass
{
    Class kioskGalleryViewClass = [PCKioskGalleryView class];
    
#ifdef DCCV
    kioskGalleryViewClass = [DCCVKioskGalleryView class];
#elif MAG_AIR
    kioskGalleryViewClass = [AIRKioskGalleryView class];
#endif
    return kioskGalleryViewClass;
}

@end
