//
//  PCKioskGalleryView.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskGalleryView.h"
#import "PCKioskGalleryControlElement.h"

@implementation PCKioskGalleryView

- (PCKioskAbstractControlElement*) newControlElementWithFrame:(CGRect) frame
{
    return [[PCKioskGalleryControlElement alloc] initWithFrame:frame];
}

@end
