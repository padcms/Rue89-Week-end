//
//  PCBrowserViewController+FulscreenSupport.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCBrowserViewController.h"

@interface PCBrowserViewController ()

- (void) hideHUD;

@end

@implementation PCBrowserViewController (FulscreenSupport)

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self createWebView];
//    [self createReturnButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self hideHUD];
    [super viewDidDisappear:animated];
}

@end
