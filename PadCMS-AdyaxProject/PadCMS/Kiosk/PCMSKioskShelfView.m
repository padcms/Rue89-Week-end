//
//  PCMSKioskShelfView.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCMSKioskShelfView.h"
#import "PCMSKioskControlElement.h"

@implementation PCMSKioskShelfView

- (PCKioskAbstractControlElement*) newCellWithFrame:(CGRect) frame;
{
    return [[PCMSKioskControlElement alloc] initWithFrame:frame];
}

- (void)createView
{
    [super createView];
    
    self.backgroundColor = [UIColor clearColor];
}

@end
