//
//  PCRueRemouteNotificationCenter.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/17/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCRueRemouteNotificationCenter.h"

#import "SBJson.h"
#import "PCConfig.h"
#import "PCLocalizationManager.h"

#define kNewSetDeviceTokenMethodName @"pnsApple.setDeviceToken"
//NSString* PCRemouteNotificationCenterUUIDKey = @"RemouteNotificationCenterUUID";

@implementation PCRueRemouteNotificationCenter

+(PCRemouteNotificationCenter*)defaultRemouteNotificationCenter
{
    static PCRemouteNotificationCenter* defaultRemouteNotificationCenter = nil;
    static dispatch_once_t predicate = 0;
	dispatch_once(&predicate, ^{ defaultRemouteNotificationCenter = [[PCRueRemouteNotificationCenter alloc] init]; });
    return defaultRemouteNotificationCenter;
}

- (NSString*) osVersionString
{
    return [[UIDevice currentDevice]systemVersion];
}

- (NSString*) appVersionString
{
    return [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleVersion"];
}

/*-(NSString*) generateUUID
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:PCRemouteNotificationCenterUUIDKey])
    {
        CFUUIDRef UUID =  CFUUIDCreate(nil);
        CFStringRef strUUID = CFUUIDCreateString(nil,UUID);
        [[NSUserDefaults standardUserDefaults] setObject:(__bridge NSString*)strUUID forKey:PCRemouteNotificationCenterUUIDKey];
        CFRelease(UUID);
        CFRelease(strUUID);
    }
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:PCRemouteNotificationCenterUUIDKey];
}*/

/*- (NSString*)uuidFromUserDefaults
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PCRemouteNotificationCenterUUIDKey];
}*/



-(NSString*)generateDeviceRequestWithToken:(NSString*)deviceToken
{
    NSString* appIdentifier = [NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]];
    
    NSString *UUID = nil;

    UUID =  deviceID();//[[UIDevice currentDevice] identifierForVendor].UUIDString;

    
    NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
    [mainDict setObject:kNewSetDeviceTokenMethodName forKey:PCJSONMethodNameKey];
    
    NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:UUID, PCJSONSDUDIDKey, deviceToken, PCJSONSDTokenKey, appIdentifier, PCJSONSDApplicationIDKey, [self osVersionString], @"sVersionOs", [self appVersionString], @"sVersionApp", nil];
    [mainDict setObject:innerDict forKey:PCJSONParamsKey];
    
    [mainDict setObject:@"1" forKey:PCJSONIDKey];
    
    //NSLog(@"register request : %@", mainDict.debugDescription);
    
    SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
    //[tmpJsonWriter release];
    
    return jsonString;
}

BOOL systemVersionNotLessThan(float vers)
{
    return ([[[UIDevice currentDevice]systemVersion]floatValue] >= vers);
}

@end
