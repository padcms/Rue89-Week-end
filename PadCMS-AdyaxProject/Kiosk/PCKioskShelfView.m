//
//  PCKioskShelfView.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 11.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCKioskShelfView.h"
#import "PCKioskControlElement.h"

@implementation PCKioskShelfView

- (PCKioskAbstractControlElement*) newCellWithFrame:(CGRect) frame;
{
    return [[PCKioskControlElement alloc] initWithFrame:frame];
}

@end
