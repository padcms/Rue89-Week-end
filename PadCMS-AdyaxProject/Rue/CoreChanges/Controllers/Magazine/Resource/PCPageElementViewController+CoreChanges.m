//
//  PCPageElementViewController+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCPageElementViewController.h"
#import "PCResourceView.h"

@interface PCPageElementViewController()
{
//@private
//    MBProgressHUD* _HUD;
//    CGFloat _targetWidth;
//    NSString *_resource;
	BOOL _loaded;
}

- (void)hideHUD;
- (void)applicationDidChangeStatusBarOrientationNotification;

@end

@implementation PCPageElementViewController (CoreChanges)

- (void) loadFullViewImmediate
{
    [self correctSize];
    
    if (_resourceView != nil) {
        _loaded = YES;
        return;
    }
    
    _resourceView = [[PCResourceView alloc] initWithFrame:self.view.bounds];
    _resourceView.resourceName = self.resource;
    
    _loaded = YES;
    
    [self.view addSubview:_resourceView];
}

@end
