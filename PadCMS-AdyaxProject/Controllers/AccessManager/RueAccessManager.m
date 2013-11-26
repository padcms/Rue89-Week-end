//
//  RueAccessManager.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "RueAccessManager.h"
#import "PCConfig.h"
#import "SBJsonWriter.h"

@implementation RueAccessManager

static NSString* _password = @"";

+ (NSString*) publisherPassword
{
    return _password;
}

+ (NSURL*) apiURL
{
    return [[PCConfig serverURL] URLByAppendingPathComponent:@"/api/v1/jsonrpc.php"];
}

+ (NSURLRequest*) confirmRequestForPassword:(NSString*)password
{
    NSString* appIdentifier = [NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]];
    
//    NSString *UUID =  deviceID();
    
    NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
    [mainDict setObject:@"client.authenticatePublisher" forKey:PCJSONMethodNameKey];

    NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:password, @"sPublisherToken", appIdentifier, PCJSONSDApplicationIDKey, nil];
    [mainDict setObject:innerDict forKey:PCJSONParamsKey];
    [mainDict setObject:@"1" forKey:PCJSONIDKey];

    SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self apiURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"tokenRequest - %@", jsonString);
    [request setHTTPBody:[jsonString dataUsingEncoding:NSASCIIStringEncoding]];
    return request;
}

+ (void) confirmPassword:(NSString*)password completion:(void(^)(NSError* error))completionBlock
{
    dispatch_queue_t requestQueue = dispatch_queue_create("WebServiceAPIQueue", NULL);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(requestQueue,
                   ^{
                       NSError* error = nil;
                       NSURLResponse *response = nil;

                       NSData *dataReply = [NSURLConnection  sendSynchronousRequest:[self confirmRequestForPassword:password] returningResponse:&response error:&error];
                       //NSDictionary* jsonResponse = nil;
                       
                       BOOL success = NO;
                       
                       if(dataReply != nil && dataReply.length)
                       {
                           NSError* serializError = nil;
                           NSArray* result = [NSJSONSerialization JSONObjectWithData:dataReply options:NSJSONReadingAllowFragments error:&serializError];
                           
                           NSLog(@"access responce : %@", result.debugDescription);
                           
                           NSString* stringReply = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
                           NSLog(@"confirm - %@", stringReply);
                           //NSString* stringWithoutNull = [stringReply stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
                           //sonResponse = [stringWithoutNull JSONValue];
                           
                       }
                       else
                       {
                           NSLog(@"WebServiceAPI error=%@",error);
                           NSLog(@"WebServiceAPI response=%@",response);
                       }

                       dispatch_async(mainQueue,
                                      ^{
                                          if(success)
                                          {
                                              _password = password;
                                              completionBlock(nil);
                                          }
                                          else
                                          {
                                              completionBlock(error);
                                          }
                                      });

                   });
    dispatch_release(requestQueue);
}

@end
