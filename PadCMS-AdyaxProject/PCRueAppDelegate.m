//
//  PCRueAppDelegate.m
//  Pad CMS
//
//  Created by tar on 12.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueAppDelegate.h"
#import "TestFlight.h"

@implementation PCRueAppDelegate

- (void)initTrackers {
    [super initTrackers];
    
    [TestFlight takeOff:@"e22c706b-4282-4628-8dd4-9f6624fd2f16"];
}

- (void)showMainViewController {
    
    self.window.rootViewController = nil;
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:(UIViewController *)self.viewController];
    navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = navigationController;
    
}

@end
