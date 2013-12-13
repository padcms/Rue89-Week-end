//
//  RuePadCMSCoder.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RuePadCMSCoder.h"
#import "PCConfig.h"
#import "SBJsonWriter.h"
#import "SBJsonParser.h"
#import "Helper.h"
#import "NSString+MD5.h"

#define kPublisherTokenParameterKey @"sPublisherToken"

NSString* PCNetworkServiceJSONRPCPath;

@implementation RuePadCMSCoder

- (BOOL) syncServerPlistDownloadWithPassword:(NSString*)password
{
    NSString *devId = deviceID();
    
    //    devId = [[[UIDevice currentDevice]identifierForVendor]UUIDString];
    
    
	
	NSURL* theURL = [[PCConfig serverURL] URLByAppendingPathComponent:PCNetworkServiceJSONRPCPath];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
	
	[request setHTTPMethod:@"POST"];
	
	NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
	[mainDict setObject:@"client.getIssues" forKey:@"method"];
	
    
	/*NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[PCConfig clientIdentifier]], @"iClientId",[NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]],@"iApplicationId", nil];*/
    
	NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid",[NSString stringWithFormat:@"%d",[PCConfig clientIdentifier]], @"iClientId",[NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]],@"iApplicationId", password.md5hash, kPublisherTokenParameterKey, nil];
	[mainDict setObject:innerDict forKey:@"params"];
	
	[mainDict setObject:@"1" forKey:@"id"];
	
	SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
	NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
	
    //NSLog(@"jsonString is:\n%@", jsonString);
	
	
	[request setHTTPBody:[jsonString dataUsingEncoding:NSASCIIStringEncoding]];
	
	NSData *dataReply = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:nil];
	
	if(dataReply != nil)
	{
		NSString* stringReply = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
        //		NSLog(@"stringReply is:\n%@", stringReply);
		NSString* stringWithoutNull = [stringReply stringByReplacingOccurrencesOfString:@":null" withString:@":\"\""];
        
        SBJsonParser * parser = [SBJsonParser new];
        
        
        NSDictionary* theDict = [parser objectWithString:stringWithoutNull];
		//NSDictionary* theDict = [stringWithoutNull JSONValue];
        
        NSLog(@"%@", theDict);
        
		
		if([theDict valueForKey:@"result"] == nil)
			self.validUDID = NO;
		else
		{
			NSDictionary* aDict = [theDict objectForKey:@"result"];
			self.validUDID = NO;
			if(aDict == nil) return NO;
			self.validUDID = YES;
            
            NSString * plistPath = [[Helper getHomeDirectory]stringByAppendingPathComponent:@"server.plist"];
            
			BOOL success = [aDict writeToFile:plistPath atomically:YES];
            
            
			return success;
		}
	}
	
	return NO;
}

- (void) sendReceipt: (NSNotification *)notification
{
	NSLog(@"transactionReceipt: %@", [notification object]);
	
    NSString *devId = deviceID();
	
	NSURL* theURL = [[PCConfig serverURL] URLByAppendingPathComponent:PCNetworkServiceJSONRPCPath];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	
	[request setHTTPMethod:@"POST"];
	
	NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
	[mainDict setObject:@"purchase.apple.verifyReceipt" forKey:@"method"];
    
    NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid", [notification object], @"sReceiptData", [PCConfig sharedSecretKey], @"sSecretPassword", nil];
	
	[mainDict setObject:innerDict forKey:@"params"];
	
	[mainDict setObject:@"1" forKey:@"id"];
	
	SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
	NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
	
    //	NSLog(@"jsonString is:\n %@", jsonString);
	
	//[tmpJsonWriter release];
	
	[request setHTTPBody:[jsonString dataUsingEncoding:NSASCIIStringEncoding]];
	
	NSData *dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	if(dataReply != nil)
	{
		NSString *str = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
        //		NSLog(@"ReceiptVerify response:\n %@", str);
		//[str release];
	}
	
	[padDelegate restartApplication];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:reloadCellNotification object:nil];
}

@end
