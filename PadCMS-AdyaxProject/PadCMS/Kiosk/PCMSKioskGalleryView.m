//
//  PCMSKioskGalleryView.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <QuartzCore/CALayer.h>

#import "PCMSKioskGalleryView.h"
#import "PCMSKioskGalleryControlElement.h"
#import "PCKioskGalleryItem.h"

@implementation PCMSKioskGalleryView

- (PCKioskAbstractControlElement*) newControlElementWithFrame:(CGRect) frame
{
    return [[PCMSKioskGalleryControlElement alloc] initWithFrame:frame];
}

- (void)createGalleryItems
{
    [super createGalleryItems];
    
    NSArray *sublayers = self.galleryView.layer.sublayers;
    
    for (CALayer *sublayer in sublayers) {
        if ([sublayer isKindOfClass:[PCKioskGalleryItem class]]) {
            PCKioskGalleryItem *kioskGalleryItem = (PCKioskGalleryItem *)sublayer;
            kioskGalleryItem.drawReflection = NO;
        }
    }
}

@end
