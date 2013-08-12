//
//  PCMSKioskSubviewsFactory.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 26.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCMSKioskSubviewsFactory.h"
#import "PCMSKioskShelfView.h"
#import "PCMSKioskGalleryView.h"

@implementation PCMSKioskSubviewsFactory

-(NSArray*) subviewsListWithFrame:(CGRect) frame {
    NSArray     *result = nil;
    
    PCMSKioskShelfView     *shelfSubview = [[[PCMSKioskShelfView alloc] initWithFrame:frame] autorelease];
    
    shelfSubview.tag = [PCMSKioskShelfView subviewTag];
    shelfSubview.hidden = YES;
    
    PCMSKioskGalleryView     *gallerySubview = [[[PCMSKioskGalleryView alloc] initWithFrame:frame] autorelease];
    
    gallerySubview.tag = [PCMSKioskGalleryView subviewTag];
    gallerySubview.hidden = YES;
    
    
    result = [NSArray arrayWithObjects:
              shelfSubview,
              gallerySubview,
              nil];
    
    return result;
}

@end
