//
//  AFUniEditionsApiClient.h
//  TestRueSubscribe
//
//  Created by Valero Geruch on 26.01.12.
//  Copyright (c) 2012 IdeaTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

extern NSString * const kAFGowallaClientID;
extern NSString * const kAFGowallaBaseURLString;

@interface AFUniEditionsApiClient : AFHTTPClient
+ (AFUniEditionsApiClient *)sharedClient;
@end
