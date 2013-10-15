//
//  BoxCarController.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/11/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoxCarController : NSObject

+ (void) registerForNotifications;

//AppDelegate events
+ (void) launchWithOptions:(NSDictionary*)launchOptions;
+ (void) applicationDidEnterForeground;
+ (void) applicationDidBecomeActive;
+ (void) applicationDidRegisterForNotificationWithToken:(NSData*)token;
+ (void) applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
+ (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end
