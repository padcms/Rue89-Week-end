//
//  AFUniEditionsApiClient.m
//  TestRueSubscribe
//
//  Created by Valero Geruch on 26.01.12.
//  Copyright (c) 2012 IdeaTeam. All rights reserved.
//

#import "AFUniEditionsApiClient.h"


#import "AFJSONRequestOperation.h"


NSString* const kAFUniEditionsBaseURLString = @"http://auth.uni-editions.adyax.com";

@implementation AFUniEditionsApiClient

+ (AFUniEditionsApiClient *)sharedClient {
    static AFUniEditionsApiClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAFUniEditionsBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
   
	[self setDefaultHeader:@"Accept" value:@"application/json"];

    
    return self;
}

@end
