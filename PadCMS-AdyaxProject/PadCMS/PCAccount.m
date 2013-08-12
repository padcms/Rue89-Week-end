//
//  PCAccount.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "AFNetworking.h"
#import "NSString+SBJSON.h"
#import "PCAccount.h"
#import "PCApplication.h"
#import "PCUserInfo.h"
#import "SBJsonWriter.h"
#import "NSDictionary+Additions.h"

#define PCApiPath @"/api/v1/jsonrpc.php"


@interface PCAccount ()
{
    NSString *_sessionId;
}

- (void)loginSucceed;
- (void)loginFailed;
- (void)loggedOut;
- (void)downloadApplicationsList;
- (void)setState:(PCAccountState)state;
- (void)setApplications:(NSArray *)applications;

@end

@implementation PCAccount

@synthesize state = _state;
//@synthesize loginDelegate = _loginDelegate;
@synthesize serverAddress = _serverAddress;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize applications = _applications;
@synthesize userInfo = _userInfo;

- (void)dealloc
{
    //    _loginDelegate = nil;
    
    [_serverAddress release];
    [_userName release];
    [_password release];
    [_applications release];
    [_userInfo release];
    [_sessionId release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _state = PCAccountStateNotConnected;
        _serverAddress = nil;
        //        _userName = nil;
        _userName = @"qa";
        //        _userName = @"textuellamine";
        //        _userName = @"developer";
        //        _password = nil;
        _password = @"qwerty456";
        //        _applications = nil;
        //        _userInfo = nil;
        _sessionId = nil;
    }
    
    return self;
}

- (void)logInWithUserName:(NSString *)userName password:(NSString *)password 
            serverAddress:(NSString *)serverAddress;
{
    [_userName release];
    _userName = [userName copy];
    [_password release];
    _password = [password copy];
    [_serverAddress release];
    _serverAddress = [serverAddress copy];
    
    AFHTTPClient *httpClient = [[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:_serverAddress]] autorelease];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:PCApiPath parameters:nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _userName, @"sUserLogin", 
                            _password, @"sUserPassword", 
                            nil];
    
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"user.login", @"method",
                          params, @"params",
                          [NSNumber numberWithInt:1], @"id",
                          nil];
    
    SBJsonWriter *jsonWriter = [[[SBJsonWriter alloc] init] autorelease];
    [request setHTTPBody:[[jsonWriter stringWithObject:body] dataUsingEncoding:NSUTF8StringEncoding]];
    
    void (^success)(AFHTTPRequestOperation *, id) = 
    ^ (AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *resultDictionary = [[operation.responseString JSONValue] objectForKey:@"result"];
        if (resultDictionary == nil)
        {
            [self loginFailed];
            return;
        }
        
        NSInteger resultCode = [[resultDictionary objectForKey:@"code"] integerValue];
        if (resultCode != 1)
        {
            [self loginFailed];
            return;
        }
        
        _sessionId = [[resultDictionary objectForKey:@"sessionId"] copy];
        
        NSDictionary *userInfoDictionary = [resultDictionary objectForKey:@"userInfo"];
        
        _userInfo = [[PCUserInfo alloc] init];
        _userInfo.firstName = [userInfoDictionary objectForKey:@"first_name"]; 
        _userInfo.lastName = [userInfoDictionary objectForKey:@"last_name"];
        _userInfo.login = [userInfoDictionary objectForKey:@"login"];
        _userInfo.email = [userInfoDictionary objectForKey:@"email"];
        
        [self loginSucceed];
    };
    
    void (^failure)(AFHTTPRequestOperation *, NSError *) = 
    ^ (AFHTTPRequestOperation *operation, NSError *error)
    {
        [self loginFailed];
    };
    
    AFHTTPRequestOperation* requestOperation = [httpClient HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    [requestOperation start];
}

- (void)logOut
{
    [_userName release];
    _userName = nil;
    [_password release];
    _password = nil;
    
    [self setApplications:nil];
    [_userInfo release];
    _userInfo = nil;
    
    [self loggedOut];
}

#pragma mark private

- (void)setState:(PCAccountState)state
{
    _state = state;
}

- (void)setApplications:(NSArray *)applications
{
    if (_applications != applications)
    {
        [_applications release];
        _applications = [applications retain];
    }
}

- (void)loginSucceed
{
    [self setState:PCAccountStateConnected];
    
    [self downloadApplicationsList];
}

- (void)loginFailed
{
    [self setState:PCAccountStateError];
}

- (void)loggedOut
{
    [self setState:PCAccountStateNotConnected];
}

- (void)downloadApplicationsList
{
    if (_sessionId == nil) 
    {
        NSLog(@"ERROR. Invalid session id.");
        return;
    }
    
    AFHTTPClient *httpClient = [[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:_serverAddress]] autorelease];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" 
                                                            path:PCApiPath 
                                                      parameters:nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _sessionId, @"sSessionId",
                            nil];
    
    NSDictionary *requestBody = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"user.getApplications", @"method",
                                 params, @"params",
                                 @"1", @"id",
                                 nil];
    
    SBJsonWriter *jsonWriter = [[[SBJsonWriter alloc] init] autorelease];
    NSString *requestBodyString = [jsonWriter stringWithObject:requestBody];
    
    NSMutableData *requestBodyData = [[[requestBodyString dataUsingEncoding:NSUTF8StringEncoding] 
                                       mutableCopy] autorelease];
    
    [request setHTTPBody:requestBodyData];
    
    
    void (^success)(AFHTTPRequestOperation *, id) = 
    ^ (AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *responseDictionary = [[operation.responseString JSONValue] objectForKey:@"result"];
        
        NSDictionary* applicationsList = [responseDictionary objectForKey:PCJSONApplicationsKey];
        
        NSMutableArray* applications = [[NSMutableArray alloc] init];
        
        NSArray *keys = [applicationsList allKeys];
        for (NSString *key in keys)
        {
            NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *libraryPath = [libraryPaths objectAtIndex:0];
            NSString *rootDirectory = [libraryPath stringByAppendingPathComponent:@"PrivateDocuments"];
            
            NSDictionary *applicationParameters = [[applicationsList objectForKey:key] dictionaryWithNullsReplaced];
            
            PCApplication *application = [[PCApplication alloc] initWithParameters:applicationParameters
                                                                     rootDirectory:rootDirectory 
                                                                        backEndURL:[NSURL URLWithString:_serverAddress]];
            
            if (application != nil)
            {
                [applications addObject:application];
            }
            
            [application release];
        }    
        
        self.applications = applications;
        
        [applications release];
    };
    
    void (^failure)(AFHTTPRequestOperation *, NSError *) = 
    ^ (AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"ERROR. Unable to download applications list.");
    };
    
    AFHTTPRequestOperation* requestOperation = [httpClient HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    [requestOperation start];
}

@end
