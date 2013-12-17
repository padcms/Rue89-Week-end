//
//  PCKioskSubviewsFactory.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 23.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskSubviewsFactory.h"
#import "RueKioskShelfView.h"
#import "PCKioskGalleryView.h"

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
    
    PCKioskGalleryView     *gallerySubview = [[PCKioskGalleryView alloc] initWithFrame:frame];
    
    gallerySubview.tag = [PCKioskGalleryView subviewTag];
    gallerySubview.hidden = YES;
    
#ifdef RUE
    result = [NSArray arrayWithObjects:
              shelfSubview,
              gallerySubview,
              nil];
#else
    result = [NSArray arrayWithObjects:
              gallerySubview,
              shelfSubview,
              nil];
#endif
    
    return result;
}

@end
