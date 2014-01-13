//
//  PCKioskViewController+RemoveMemoryLeak.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/10/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "PCKioskViewController+RemoveMemoryLeak.h"
#import "PCKioskSubview.h"

@implementation PCKioskViewController (RemoveMemoryLeak)

- (void) unloadView
{
    for(PCKioskSubview *current in self.kioskSubviews)
    {
        [current removeFromSuperview];
        current.delegate = nil;
        current.dataSource = nil;
    }
    self.kioskSubviews = nil;
}

@end
