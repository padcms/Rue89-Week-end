//
//  RueScrollingPageViewController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/22/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueScrollingPageViewController.h"
#import "PCScrollView.h"
#import "RuePageElementBackground.h"

@interface RueScrollingPageViewController ()

@end

@implementation RueScrollingPageViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    RuePageElementBackground* backgroundElement = (RuePageElementBackground*)[self.page firstElementForType:PCPageElementTypeBackground];
    
    BOOL shouldBringBackgroundViewToFront = backgroundElement.showOnTop;
    
    if(shouldBringBackgroundViewToFront)
    {
        [self.mainScrollView bringSubviewToFront:self.backgroundViewController.view];
        self.backgroundViewController.view.userInteractionEnabled = NO;
    }
}

@end
