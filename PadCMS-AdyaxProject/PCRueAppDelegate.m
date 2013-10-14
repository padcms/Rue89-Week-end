//
//  PCRueAppDelegate.m
//  Pad CMS
//
//  Created by tar on 12.09.13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueAppDelegate.h"
#import "TestFlight.h"
#import "PCRueNavigationController.h"
#import "MKStoreManager.h"
#import "BoxCarController.h"

@implementation PCRueAppDelegate

#ifdef RUE

- (void)initTrackers {
    [super initTrackers];
    
    [TestFlight takeOff:@"e22c706b-4282-4628-8dd4-9f6624fd2f16"];
    
    [MKStoreManager sharedManager];
}

- (void)showMainViewController {
    
    self.window.rootViewController = nil;
    
    PCRueNavigationController * navigationController = [[PCRueNavigationController alloc] initWithRootViewController:(UIViewController *)self.viewController];
    navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = navigationController;
    
}

#endif

#pragma mark - Boxcar support

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL handeled = [super application:application didFinishLaunchingWithOptions:launchOptions];
    [BoxCarController launchWithOptions:launchOptions];
    return handeled;
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
    if([super respondsToSelector:@selector(applicationWillEnterForeground:)])
    {
        [super applicationWillEnterForeground:application];
    }
    [BoxCarController applicationDidEnterForeground];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    if([super respondsToSelector:@selector(applicationDidBecomeActive:)])
    {
        [super applicationDidBecomeActive:application];
    }
    [BoxCarController applicationDidBecomeActive];
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if([super respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)])
    {
        [super application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
    [BoxCarController applicationDidRegisterForNotificationWithToken:deviceToken];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if([super respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)])
    {
        [super application:application didFailToRegisterForRemoteNotificationsWithError:error];
    }
    [BoxCarController applicationDidFailToRegisterForRemoteNotificationsWithError:error];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if([super respondsToSelector:@selector(application:didReceiveRemoteNotification:)])
    {
        [super application:application didReceiveRemoteNotification:userInfo];
    }
    [BoxCarController application:application didReceiveRemoteNotification:userInfo];
}

#pragma mark -
@end
