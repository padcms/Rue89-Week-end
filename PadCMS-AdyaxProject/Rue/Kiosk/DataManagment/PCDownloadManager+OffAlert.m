//
//  PCDownloadManager+OffAlert.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 1/3/14.
//  Copyright (c) 2014 Adyax. All rights reserved.
//

#import "PCDownloadManager.h"

@implementation PCDownloadManager (OffAlert)

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//	if([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null] && [change objectForKey:NSKeyValueChangeOldKey] != [NSNull null])
//	{
//		AFNetworkReachabilityStatus newStatus = [[change objectForKey: NSKeyValueChangeNewKey] intValue];
//		AFNetworkReachabilityStatus oldStatus = [[change objectForKey: NSKeyValueChangeOldKey] intValue];
//		if (newStatus == AFNetworkReachabilityStatusNotReachable)
//		{
//			NSString* message = [PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION"
//                                                                       value:@"You must be connected to the Internet."];
//            
//            NSString    *title = [PCLocalizationManager localizedStringForKey:@"TITLE_WARNING"
//                                                                        value:@"Warning!"];
//            
//            NSString    *buttonTitle = [PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
//                                                                              value:@"OK"];
//            
//			dispatch_async(dispatch_get_main_queue(), ^{
//				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
//                                                                message:message
//                                                               delegate:nil
//                                                      cancelButtonTitle:buttonTitle
//                                                      otherButtonTitles:nil];
//				[alert show];
//				[alert release];
//			});
//		}
//		else if ((oldStatus == AFNetworkReachabilityStatusNotReachable) && ((newStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (newStatus == AFNetworkReachabilityStatusReachableViaWWAN)) )
//		{
//			NSLog(@"Network now available!");
//			[self startDownloading];
//		}
//	}
}

@end
