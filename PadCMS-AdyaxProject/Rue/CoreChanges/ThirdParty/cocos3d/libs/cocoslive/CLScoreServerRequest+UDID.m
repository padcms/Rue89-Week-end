//
//  CLScoreServerRequest+UDID.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "CLScoreServerRequest.h"

@implementation CLScoreServerRequest (UDID)

NSString* deviceID();

- (BOOL) requestScores:(tQueryType)type
				limit:(int)limit
			   offset:(int)offset
				flags:(tQueryFlags)flags
			 category:(NSString*)category
{
	// create the request
	[receivedData setLength:0];
	
	// it's not a call for rank
	reqRankOnly = NO;
	
	NSString *device = @"";
	if( flags & kQueryFlagByDevice )
		device = deviceID();//[[[UIDevice currentDevice]identifierForVendor]UUIDString];
	
	// arguments:
	//  query: type of query
	//  limit: how many scores are being requested. Default is 25. Maximun is 100
	//  offset: offset of the scores
	//  flags: bring only country scores, world scores, etc.
	//  category: string user defined string used to filter
	NSString *url= [NSString stringWithFormat:@"%@?gamename=%@&querytype=%d&offset=%d&limit=%d&flags=%d&category=%@&device=%@",
					SCORE_SERVER_REQUEST_URL,
					gameName,
					type,
					offset,
					limit,
					flags,
					[category stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
					device
					];
	
	//	NSLog(@"%@", url);
	
	NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
										   cachePolicy:NSURLRequestUseProtocolCachePolicy
									   timeoutInterval:10.0];
	
	// create the connection with the request
	// and start loading the data
	self.connection=[NSURLConnection connectionWithRequest:request delegate:self];
	if (! connection_)
		return NO;
    
	return YES;
}

@end
