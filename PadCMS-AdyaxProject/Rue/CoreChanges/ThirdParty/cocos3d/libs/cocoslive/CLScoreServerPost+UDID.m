//
//  CLScoreServerPost+UDID.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 12/13/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "CLScoreServerPost.h"

@interface CLScoreServerPost ()
- (NSMutableURLRequest *) scoreServerRequestWithURLString:(NSString *)url;
NSInteger alphabeticSort(id string1, id string2, void *reverse);
- (void) calculateHashAndAddValue:(id)value key:(NSString*)key;
- (void) addValue:(NSString*)value key:(NSString*)key;
- (NSString*) getHashForData;
- (NSData*) getBodyValues;
@end

@implementation CLScoreServerPost (UDID)

NSString* deviceID();

- (BOOL) submitScore: (NSDictionary*)dict forUpdate:(BOOL)isUpdate
{
    [receivedData setLength:0];
	[bodyValues removeAllObjects];
	
	// reset status
	postStatus_ = kPostStatusOK;
    
	// create the request
	NSMutableURLRequest *post = [self scoreServerRequestWithURLString:(isUpdate ? SCORE_SERVER_UPDATE_URL : SCORE_SERVER_SEND_URL)];
	
	CC_MD5_Init( &md5Ctx);
    
    // hash SHALL be calculated in certain order
	NSArray *keys = [dict allKeys];
	int reverseSort = NO;
	NSArray *sortedKeys = [keys sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
	for( id key in sortedKeys )
		[self calculateHashAndAddValue:[dict objectForKey:key] key:key];
    
    // device id is hashed to prevent spoofing this same score from different devices
	// one way to prevent a replay attack is to send cc_id & cc_time and use it as primary keys
    
	[self addValue:deviceID() key:@"cc_device_id"];
	[self addValue:gameName key:@"cc_gamename"];
	[self addValue:[self getHashForData] key:@"cc_hash"];
	[self addValue:SCORE_SERVER_PROTOCOL_VERSION key:@"cc_prot_ver"];
    
	[post setHTTPBody: [self getBodyValues] ];
	
	// create the connection with the request
	// and start loading the data
	self.connection=[[NSURLConnection alloc] initWithRequest:post delegate:self];
	
	if ( ! connection_)
		return NO;
	
	return YES;
}

@end
