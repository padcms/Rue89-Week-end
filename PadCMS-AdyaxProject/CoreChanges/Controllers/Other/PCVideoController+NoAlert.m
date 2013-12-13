//
//  PCVideoController+NoAlert.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PCVideoController.h"
#import "AFHTTPClient.h"
#import "PCDownloadApiClient.h"

@implementation PCVideoController (NoAlert)

- (BOOL) isConnectionEstablished
{
	AFNetworkReachabilityStatus remoteHostStatus = [PCDownloadApiClient sharedClient].networkReachabilityStatus;
	if(remoteHostStatus == AFNetworkReachabilityStatusNotReachable)
	{
        //		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION"
        //                                                                                                       value:@"You must be connected to the Internet."]
        //                                                        message:nil
        //                                                       delegate:nil
        //                                              cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
        //                                                                                                       value:@"OK"]
        //                                              otherButtonTitles:nil];
        //		[alert show];
        //		[alert release];
        //		return NO;
	}
    
    return YES;
}

@end
