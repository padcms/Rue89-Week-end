//
//  VersionManager+CoreChanges.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/16/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "VersionManager.h"
#import "Helper.h"
#import "InAppPurchases.h"

static VersionManager *sharedVersionManager;

@implementation VersionManager (CoreChanges)

+ (VersionManager*) sharedManager
{
    if (sharedVersionManager == nil)
	{
        sharedVersionManager = [[super allocWithZone:NULL] init];
#ifndef DISABLE_INAPP_PURCHASES
		[[NSNotificationCenter defaultCenter] addObserver:sharedVersionManager selector:@selector(productDataRecieved:) name:kInAppPurchaseManagerProductsFetchedNotification object:nil];
#endif
		sharedVersionManager.reachability = [Reachability reachabilityForInternetConnection];
		[sharedVersionManager.reachability startNotifier];
		
		sharedVersionManager.items = [[NSMutableArray alloc] init];
        //	sharedVersionManager.coder = [[[PadCMSCoder alloc] initWithDelegate:sharedVersionManager] autorelease];
		
        //TODO !!!!!!!!!!!!!!!!!!!!!NOT FOR KIOSQUE
		[Helper setInternalRevision:-1];
		
		//NSLog(@"UDID %@",[UIDevice currentDevice].uniqueIdentifier);
    }
	
    return sharedVersionManager;
}

@end
