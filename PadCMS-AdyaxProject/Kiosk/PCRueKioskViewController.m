//
//  PCRueKioskViewController.m
//  Pad CMS
//
//  Created by tar on 11.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueKioskViewController.h"
#import "PCKioskSubview.h"
#import "PCKioskShelfView.h"

@interface PCRueKioskViewController ()

@end

@implementation PCRueKioskViewController

- (void)reloadSubviewsOnViewWillAppear {
    static BOOL once = NO;
    
    if (!once) {
        once = YES;
        [super reloadSubviewsOnViewWillAppear];
    }
}

#pragma mark - Downloading flow

- (void) downloadingContentStartedWithRevisionIndex:(NSInteger)index
{
    for(PCKioskSubview *subview in self.kioskSubviews)
    {
        if([subview isMemberOfClass:[PCKioskShelfView class]])
        {
            [(PCKioskShelfView*)subview downloadingContentStartedWithRevisionIndex:index];
        }
    }
}

- (void) downloadingContentFinishedWithRevisionIndex:(NSInteger)index
{
    for(PCKioskSubview *subview in self.kioskSubviews)
    {
        if([subview isMemberOfClass:[PCKioskShelfView class]])
        {
            [(PCKioskShelfView*)subview downloadingContentFinishedWithRevisionIndex:index];
        }
    }
}


@end
