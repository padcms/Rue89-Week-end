//
//  PCKioskSubviewsFactory.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 23.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskSubviewsFactory.h"
#import "PCKioskShelfView.h"
#import "PCKioskGalleryView.h"

@implementation PCKioskSubviewsFactory

-(NSArray*) subviewsListWithFrame:(CGRect) frame
{
    NSArray     *result = nil;
    
    PCKioskShelfView     *shelfSubview = [[[PCKioskShelfView alloc] initWithFrame:frame] autorelease];
    
    shelfSubview.tag = [PCKioskShelfView subviewTag];
    shelfSubview.hidden = YES;
    
    PCKioskGalleryView     *gallerySubview = [[[PCKioskGalleryView alloc] initWithFrame:frame] autorelease];
    
    gallerySubview.tag = [PCKioskGalleryView subviewTag];
    gallerySubview.hidden = YES;
    
#ifdef RUE
    result = [NSArray arrayWithObjects:
             // gallerySubview,
              shelfSubview,
              gallerySubview,
              nil];
#else
    result = [NSArray arrayWithObjects:
              // gallerySubview,
              gallerySubview,
              shelfSubview,
              nil];
#endif
    
    return result;
}

@end
