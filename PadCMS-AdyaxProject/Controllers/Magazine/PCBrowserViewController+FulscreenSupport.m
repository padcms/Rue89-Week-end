//
//  PCBrowserViewController+FulscreenSupport.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/12/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCBrowserViewController.h"
#import "MBProgressHUD.h"
#import "PCLocalizationManager.h"

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

-(void)showHUD
{
    if (self.HUD == nil) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.webView];
        self.HUD.labelText = [PCLocalizationManager localizedStringForKey:@"LABEL_LOADING"
                                                                    value:@"Loading"];
    }
    
    [self.webView addSubview:_HUD];
    [self.HUD show:YES];
}

-(void)hideHUD
{
	if (self.HUD != nil) {
        [self.HUD hide:YES];
		[self.HUD removeFromSuperview];
        self.HUD = nil;
	}
}

@end
