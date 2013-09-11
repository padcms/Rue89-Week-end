//
//  PCRueKioskViewController.m
//  Pad CMS
//
//  Created by tar on 11.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueKioskViewController.h"

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

@end
