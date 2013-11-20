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
#import "PCRueRemouteNotificationCenter.h"

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
    NSLog(@"launch options : %@", launchOptions.debugDescription);
    BOOL handeled = [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    [BoxCarController launchWithOptions:launchOptions];
    
    return handeled;
}

//- (void) applicationDidEnterBackground:(UIApplication * )application
//{
//    UILocalNotification* notif = [UILocalNotification new];
//    notif.alertBody = @"notif";
//    //notif.hasAction = NO;
//    notif.applicationIconBadgeNumber = 5;
//    notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
//    [application scheduleLocalNotification:notif];
//}
//
//- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
//{
//    NSLog(@"fsddfjdfjdfsjdfsjdsfdsdfsjk");
//    application.applicationIconBadgeNumber = 3;
//}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
    if([[PCPadCMSAppDelegate class] instancesRespondToSelector:@selector(applicationWillEnterForeground:)])
    {
        [super applicationWillEnterForeground:application];
    }
    [BoxCarController applicationDidEnterForeground];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    if([[PCPadCMSAppDelegate class] instancesRespondToSelector:@selector(applicationDidBecomeActive:)])
    {
        [super applicationDidBecomeActive:application];
    }
    [BoxCarController applicationDidBecomeActive];
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[PCRueRemouteNotificationCenter defaultRemouteNotificationCenter] registerDeviceWithToken:deviceToken];
    
    [BoxCarController applicationDidRegisterForNotificationWithToken:deviceToken];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError : %@", error);
    [[PCRueRemouteNotificationCenter defaultRemouteNotificationCenter] registrationDidFailWithError:error];
    
    [BoxCarController applicationDidFailToRegisterForRemoteNotificationsWithError:error];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"remote notification : %@", userInfo.debugDescription);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[PCRueRemouteNotificationCenter defaultRemouteNotificationCenter] didReceiveRemoteNotification:userInfo];
    
    [BoxCarController application:application didReceiveRemoteNotification:userInfo];
}

#pragma mark -

NSString* deviceID()
{
    NSString* gettingTokenSelectorString = nil;
    NSString* udidSelectorString = nil;
    
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 6.0)
    {
        gettingTokenSelectorString = @"identifierForVendor";
        udidSelectorString = @"UUIDString";
    }
    else
    {
        gettingTokenSelectorString = @"uniqueIdentifier";
        udidSelectorString = nil;
    }
    
    if(udidSelectorString)
    {
        return [[[UIDevice currentDevice] performSelector:NSSelectorFromString(gettingTokenSelectorString)] performSelector:NSSelectorFromString(udidSelectorString)];
    }
    else
    {
        return [[UIDevice currentDevice] performSelector:NSSelectorFromString(gettingTokenSelectorString)];
    }
}
@end
