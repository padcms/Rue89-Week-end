//
//  BoxCarController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/11/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "BoxCarController.h"
#import <Boxcar/Boxcar.h>

#define SANDBOX //Comment this line for thr release

@implementation BoxCarController

static NSString* CLIENT_KEY;    //Your application client key on Boxcar Push console.
static NSString* CLIENT_SECRET; //Your application client sevret on Boxcar Push console.
static NSString* API_URL;       //API endpoint URL.
static NSString* LOGGING;
static NSString* PUSH_MODE;

+ (void) initialize
{
    CLIENT_KEY = @"wKIk6gJEl1d-v64Y08xZMy0VuUtQ88Ze-V1Jx_NYfehXr16x-0FpT4KILPxme-XS";
    CLIENT_SECRET = @"AITqN8aXi9AjXaV3M8yPzJFxqDQAGyt_3ucmjxJ4yzC3MqFnvvsOZbItNF7-AXjL";
    API_URL = @"https://yellow2.process-one.net";
#ifdef SANDBOX
    NSLog(@"BoxCar in debug mode.\n");
    PUSH_MODE = @"development";
    LOGGING = @"YES";
#else
    PUSH_MODE = @"production";
    LOGGING = @"NO";
#endif
}

+ (void) launchWithOptions:(NSDictionary*)launchOptions
{
    return;
    NSDictionary *boxcarOptions = @{kBXC_CLIENT_KEY : CLIENT_KEY,
                                    kBXC_CLIENT_SECRET : CLIENT_SECRET,
                                    kBXC_API_URL : API_URL,
                                    kBXC_LOGGING : LOGGING};
    
    NSError* startError = nil;
    [[Boxcar sharedInstance] startWithOptions:boxcarOptions error:&startError];
    if(startError)
    {
        NSLog(@"Boxcar start error : %@", startError);
    }
    
    [[Boxcar sharedInstance] setMode:PUSH_MODE];
    
    NSDictionary *remoteNotif = [[Boxcar sharedInstance] extractRemoteNotificationFromLaunchOptions:launchOptions];
    
    [[Boxcar sharedInstance] trackNotification:remoteNotif];
    
    [[Boxcar sharedInstance] cleanNotificationsAndBadge];
    
    [self registerForNotifications];
        
    if(remoteNotif)
    {
        [self wasLaunchedWithNotification:remoteNotif];
    }
}

+ (void) registerForNotifications
{
    [[Boxcar sharedInstance] registerDevice];
}

+ (void) wasLaunchedWithNotification:(NSDictionary*)notificationUserInfo
{
    NSLog(@"Notification received\n");
    NSLog(@"User Info : %@", notificationUserInfo.debugDescription);
    
    
    
    
}

+ (void) didReceiveNotification:(NSDictionary*)notificationUserInfo
{
    NSLog(@"Notification received\n");
    NSLog(@"User Info : %@", notificationUserInfo.debugDescription);
    
    
    
    
}

#pragma mark - AppDelegate Events

+ (void) applicationDidEnterForeground
{
    [[Boxcar sharedInstance] cleanNotificationsAndBadge];
}

+ (void) applicationDidRegisterForNotificationWithToken:(NSData*)token
{
    [[Boxcar sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:token];
}

+ (void) applicationDidBecomeActive
{
    [[Boxcar sharedInstance] applicationDidBecomeActive];
}

+ (void) applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [[Boxcar sharedInstance] didFailToRegisterForRemoteNotificationsWithError:error];
}

+ (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[Boxcar sharedInstance] trackNotification:userInfo forApplication:application];
    [[Boxcar sharedInstance] cleanNotificationsAndBadge];
    [self didReceiveNotification:userInfo];
}

#pragma mark -

@end
