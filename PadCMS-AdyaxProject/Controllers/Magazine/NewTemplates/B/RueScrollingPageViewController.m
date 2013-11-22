//
//  RueScrollingPageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/22/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueScrollingPageViewController.h"
#import "PCScrollView.h"

@interface RueScrollingPageViewController ()

@end

@implementation RueScrollingPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL shouldBringBackgroundViewToFront = NO;
    
    if(shouldBringBackgroundViewToFront)
    {
        [self.mainScrollView bringSubviewToFront:self.backgroundViewController.view];
        self.backgroundViewController.view.userInteractionEnabled = NO;
    }
}

@end
