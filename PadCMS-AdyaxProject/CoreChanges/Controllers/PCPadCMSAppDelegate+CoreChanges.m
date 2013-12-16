//
//  PCPadCMSAppDelegate+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/16/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCPadCMSAppDelegate.h"
#import "InAppPurchases.h"
#import "PCDownloadManager.h"
#import "PCGoogleAnalytics.h"
#import "PCMainViewController.h"

@implementation PCPadCMSAppDelegate (CoreChanges)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initTrackers];
    
#ifdef  NSFoundationVersionNumber_iOS_6_1
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
#endif
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge)];
    [InAppPurchases sharedInstance];
	[PCDownloadManager sharedManager];
    
    [self showMainViewController];
    
    [window makeKeyAndVisible];
	
	return YES;
}

- (void)initTrackers
{
    [PCGoogleAnalytics start];
    [PCGoogleAnalytics trackAction:@"Application launch" category:@"General"];
}

- (void)showMainViewController
{
    [window addSubview:viewController.view];
}

@end
