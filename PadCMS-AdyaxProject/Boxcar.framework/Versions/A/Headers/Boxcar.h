//
//  Boxcar.h
//  Boxcar
//
//  Copyright (c) 2012-2013 ProcessOne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BXCConstants.h"
#import "BXCSettings.h"
#import "BXCEventStream.h"

/**
 You only need to implement the delegate method if you need to receive Boxcar inApp push events.
 This is not needed to receive notifications from Apple Push Notification Service.
 */
@protocol BoxcarDelegate <NSObject>
- (void) didReceiveEvent:(NSString *)event;
@end

/**
 Boxcar is a singleton that encapsulate interface to Boxcar Push Platform.
 
 @copyright ProcessOne © 2012-2013
 
 The framework integrates two types of push notifications:
 1. Full support for *Apple Push Notification Service* (APNS).
 2. *InApp push*, which is a a push system that does not get through Apple Push. Its main advantage is that it does not requires the user to approve the reception of push messages through Apple mechanism. As such it can be fully used as a way to keep a realtime communication channel between Boxcar server and the application itself. The drawback is that it will only work while the application is running. This means that you also need to implement APNS as well if you want to notify the user after the 10 minutes the application is allowed to run in background.

 Using this class should be enough to fully control Push Service from your application.
 */

@interface Boxcar : NSObject <BXCEventStreamDelegate>

@property(nonatomic, weak) id <BoxcarDelegate> delegate;

@property(nonatomic, strong) NSString *clientKey;
@property(nonatomic, strong) NSString *clientSecret;
@property(nonatomic, strong) NSURL *apiURL;
@property(nonatomic, strong) BXCSettings *settings;

@property(nonatomic, strong) NSString *alias;
@property(nonatomic, strong) NSString *mode;
@property(nonatomic, strong) NSArray *tags;
@property(nonatomic, strong) NSString *streamId;

@property(nonatomic)         BOOL alreadyRegistering;

/**
 Deprecated method to start Boxcar Service.
 
 param launchOptions This is the NSDictionary as received by AppDelegate _application:didFinishLaunchingWithOptions:_ method.
 @returns remoteNotif NSDictionary containing remote notification if the application has been opened with a notification.
 
 @deprecated use startWithClientKey:andSecret
 */
+ (NSDictionary *) launchWithOptions:(NSDictionary *)launchOptions __attribute__((deprecated(use_method_startWithOptions_error_instead)));

/**
 Always used the shared instance class method to access Boxcar instance singleton.
 */
+ (id) sharedInstance;

/**
 Start Boxcar Service.

 This routine is used to setup the Boxcar Push service (not the same as registering with APNS) and to prepare to receive notifications.

 To use this routine, place a call to this in the applicationDidLoad:withOptions method in the App Delegate:
 @include boxcar_startwithOptions_error.m
 
 */
- (BOOL) startWithOptions:(NSDictionary *)options error:(NSError **)error;
- (NSDictionary *) extractRemoteNotificationFromLaunchOptions:(NSDictionary *)launchOptions;

/* To integrate in application life cycle: */
- (void) applicationDidBecomeActive;
- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData* )deviceToken;
- (void) didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 Associate a unique ID to device is marketing is authorized by user.
 
 If your backend application requires being able to send push notification using a unique device id, you can use this method to associate that device to a unique device ID.
 The device ID can be calculated with any algorithm, like for example:
 - OpenUDID library: You can use any UDID library (like OpenUDID, ). If you want to use the original OpenUDID library, it is bundled with the Boxcar framework as _BXCOpenUDID. For example: 
 @include boxcar_setUdid.m
 */

-(void) useAdvertisingIdentifier:(BOOL)UDIDFlag;
- (NSString *) advertisingIdentifier;

- (void) registerDevice;
- (BOOL) isPushEnabled;
- (void) sendDeviceParameters;
- (void) trackNotification:(NSDictionary *)remoteNotif;
- (void) trackNotification:(NSDictionary *)remoteNotif forApplication:(UIApplication *)app;

- (void) cleanNotifications;
- (void) cleanNotificationsAndBadge;
- (void) cleanBadge;

/**
 Unregister device from Boxcar Push server.
 
 This call deletes the device on the Boxcar server. After this call there is no more references to that device on the server and the device will not receive push anymore.
 
 This call is performing an HTTP request to Boxcar server, so network is required to unregister a device.
 
 @note When the call to the server is successful, local device data associated to Boxcar push are properly cleaned up.
 */
- (void) unregisterDevice;

/* Tag management */
- (void) retrieveProjectTagsWithBlock:(void (^)(NSArray *))resultBlock;
// @property(nonatomic, strong) NSArray *tags;
// BOOL setTags: error:? 


/* InApp Realtime event distribution */
- (BOOL) connectToEventStreamWithId:(NSString *)streamId error:(NSError **)error;
- (void) disconnectFromEventStream;

/* Put Framework in debug mode */
- (void) dbm;

@end
