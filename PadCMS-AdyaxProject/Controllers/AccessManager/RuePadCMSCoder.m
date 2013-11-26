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
#import <CommonCrypto/CommonDigest.h>

#define kPublisherTokenParameterKey @"publisher_token"

NSString* PCNetworkServiceJSONRPCPath;

@implementation RuePadCMSCoder

- (NSString*) md5hashOfString:(NSString*)password
{
    // Create pointer to the string as UTF8
    const char *ptr = [password UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
//    NSLog(@"MD5 : %@", output);
    
    return [NSString stringWithString:output];
}

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
    
	NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid",[NSString stringWithFormat:@"%d",[PCConfig clientIdentifier]], @"iClientId",[NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]],@"iApplicationId", [self md5hashOfString:password], kPublisherTokenParameterKey, nil];
	[mainDict setObject:innerDict forKey:@"params"];
	
	[mainDict setObject:@"1" forKey:@"id"];
	
	SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
	NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
	
    //	NSLog(@"jsonString is:\n%@", jsonString);
	
	
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

@end
