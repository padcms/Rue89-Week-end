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
#import "PCPathHelper.h"

#define kPublisherTokenParameterKey @"sPublisherToken"

NSString* PCNetworkServiceJSONRPCPath;

@interface RuePadCMSCoder ()

@end

@implementation RuePadCMSCoder

static void(^syncCompletedBlock)(NSError*);

+ (NSDictionary*) applicationParametersFromCuurentPlistContent
{
    NSString* plistPath = [[PCPathHelper pathForPrivateDocuments] stringByAppendingPathComponent:@"server.plist"];
    NSDictionary* plistContent = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary* applicationsList = [plistContent objectForKey:PCJSONApplicationsKey];
    NSDictionary* applicationParameters = nil;
    if(applicationsList && applicationsList.count)
    {
        applicationParameters = [applicationsList objectForKey:[[applicationsList allKeys] objectAtIndex:0]];
        if(applicationParameters && [applicationParameters count])
            return applicationParameters;
    }
    return nil;
}

- (void) syncServerPlistDownloadAsynchronouslyWithPassword:(NSString*)password completion:(void(^)(NSError*))complBlock
{
    if(syncCompletedBlock)
    {
        syncCompletedBlock = [complBlock copy];
        return;
    }
    
    syncCompletedBlock = [complBlock copy];
    
    NSURLRequest* request = [self requestToGetIssuesWithPublisherPassword:password];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSError* returnError = nil;
        
        if(connectionError == nil)
        {
            if(data)
            {
                NSDictionary* theDict = [self dictionaryFromResponceData:data];
                if(theDict)
                {
                    self.validUDID = YES;
                    NSString * plistPath = [[Helper getHomeDirectory]stringByAppendingPathComponent:@"server.plist"];
                    
                    BOOL success = [theDict writeToFile:plistPath atomically:YES];
                    if(success)
                    {
                        returnError = nil;
                    }
                    else
                    {
                        returnError = [NSError errorWithDomain:@"adyax" code:1 userInfo:@{NSLocalizedDescriptionKey :[NSString stringWithFormat: @"Writing to %@ file failed", plistPath]}];
                    }
                }
                else
                {
                    self.validUDID = NO;
                    returnError = [NSError errorWithDomain:@"adyax" code:1 userInfo:@{NSLocalizedDescriptionKey : @"No result in responce"}];
                }
            }
            else
            {
                returnError = [NSError errorWithDomain:@"adyax" code:1 userInfo:@{NSLocalizedDescriptionKey : @"No responce fom server"}];
            }
        }
        else
        {
            returnError = connectionError;
        }
        
        [self syncCompleteWithError:returnError];
    }];
}

- (void) syncCompleteWithError:(NSError*)error
{
    if(syncCompletedBlock)
    {
        syncCompletedBlock(error);
        syncCompletedBlock = nil;
    }
}

- (BOOL) syncServerPlistDownloadWithPassword:(NSString*)password
{
    NSURLRequest* request = [self requestToGetIssuesWithPublisherPassword:password];
	
    NSHTTPURLResponse* responce = nil;
    NSError* error = nil;
	NSData *dataReply = [NSURLConnection  sendSynchronousRequest:request returningResponse:&responce error:&error];
	
    if(error)
    {
        NSLog(@"\nget issues list error : %@\n", error.debugDescription);
    }
    
	if(dataReply != nil)
	{
        NSDictionary* theDict = [self dictionaryFromResponceData:dataReply];
        
		if(theDict)
		{
			self.validUDID = YES;
            NSString * plistPath = [[Helper getHomeDirectory]stringByAppendingPathComponent:@"server.plist"];
            
			BOOL success = [theDict writeToFile:plistPath atomically:YES];
            
			return success;
		}
        else
        {
			self.validUDID = NO;
            return NO;
        }
	}
    else if(responce)
    {
        NSLog(@"responce headers : %@", responce.allHeaderFields);
    }
	
	return NO;
}

- (NSDictionary*) dictionaryFromResponceData:(NSData*)dataReply
{
    NSString* stringReply = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
    //		NSLog(@"stringReply is:\n%@", stringReply);
    NSString* stringWithoutNull = [stringReply stringByReplacingOccurrencesOfString:@":null" withString:@":\"\""];
    
    RueSBJsonParser * parser = [RueSBJsonParser new];
    
    NSDictionary* theDict = [parser objectWithString:stringWithoutNull];
    
    if(theDict)
    {
        NSLog(@"%@", theDict);
    }
    else
    {
        NSLog(@"responce : %@", stringReply);
    }
    
    return [theDict valueForKey:@"result"];
}

- (NSURLRequest*) requestToGetIssuesWithPublisherPassword:(NSString*)password
{
//    Audrey 36bd6c791d666a86f7ebba3deec743ea19b26d98
//    Greg 3dd0134ec765400638a59a586236cad1952b39f6
//    Rue89 bc152b7141ae6c9d9baf24706eb98d644d3c3bb3
//    Rue89 FFFFFFFFE353CCD2A3854F94A16F96F1495688CD
//    Rue89 e75979a675a1169f82f24dc0108ac5c36c223d9f
//    Nabil dc1efe7fc00736f7f8470e527d81803da0a76bb9
    
    NSString *devId = deviceID();
//    NSLog(@"device id = %@", devId);
    //    devId = [[[UIDevice currentDevice]identifierForVendor]UUIDString];
    
	NSURL* theURL = [[PCConfig serverURL] URLByAppendingPathComponent:PCNetworkServiceJSONRPCPath];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
	
	[request setHTTPMethod:@"POST"];
	
	NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
	[mainDict setObject:@"client.getIssues" forKey:@"method"];
    
	/*NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[PCConfig clientIdentifier]], @"iClientId",[NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]],@"iApplicationId", nil];*/
    
	NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid",[NSString stringWithFormat:@"%d",[PCConfig clientIdentifier]], @"iClientId",[NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]],@"iApplicationId", password.md5hash, kPublisherTokenParameterKey, nil];
	[mainDict setObject:innerDict forKey:@"params"];
	
	[mainDict setObject:@"1" forKey:@"id"];
	
	RueSBJsonWriter *tmpJsonWriter = [[RueSBJsonWriter alloc] init];
	NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
	
    //NSLog(@"jsonString is:\n%@", jsonString);
	
	[request setHTTPBody:[jsonString dataUsingEncoding:NSASCIIStringEncoding]];
    
    return request;
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
	
	RueSBJsonWriter *tmpJsonWriter = [[RueSBJsonWriter alloc] init];
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
