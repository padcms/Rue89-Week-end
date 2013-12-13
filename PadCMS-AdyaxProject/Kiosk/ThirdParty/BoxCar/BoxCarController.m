//
//  BoxCarController.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/11/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "BoxCarController.h"
#import <Boxcar/Boxcar.h>

//#define SANDBOX //Comment this line for thr release

@implementation BoxCarController

static NSString* CLIENT_KEY;    //Your application client key on Boxcar Push console.
static NSString* CLIENT_SECRET; //Your application client sevret on Boxcar Push console.
static NSString* API_URL;       //API endpoint URL.
static NSString* LOGGING;
static NSString* PUSH_MODE;

+ (void) load
{
    objc_disposeClassPair(NSClassFromString(@"AFImageCache"));
}

+ (void) initialize
{
    CLIENT_KEY = @"AJpk3l1oqHCq2OYG1CXAU3RIRzgBtCEXpX3wqcpHQmskboBaQfVOXFXIZnuBt0Pl";   //@"CHIVHixQMylMlMdwTDp24y9jtzZCvd1O6l9RHV8t3VmVk1C9ypklFLOj6cNI0SGJ";
    CLIENT_SECRET = @"ucNzyWiJcLcAdqHUPr7LViU9TncRZ-YUA3sLlKs5I1Oo1gBy5ZNpdsULfAK26rEP";    //@"DtWhec2eX6Km71BHnGjMdlmZqfhQ-ZHSXTZYvss8LJr--86KmQf9TKciSUrx1C6k";
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
    NSLog(@"device token : %@", token);
    [[Boxcar sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:token];
}

+ (void) applicationDidBecomeActive
{
    [[Boxcar sharedInstance] applicationDidBecomeActive];
}

+ (void) applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"boxcar registration faild : %@", error.debugDescription);
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
