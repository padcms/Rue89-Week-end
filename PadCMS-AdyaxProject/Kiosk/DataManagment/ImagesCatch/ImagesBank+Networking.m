//
//  ImagesBank+Networking.m
//  Pad CMS
//
//  Created by Maksym Martyniuk on 10/28/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "ImagesBank+Networking.h"

@implementation ImagesBank (Networking)

- (void) findImageInNetworkWithPath:(NSString*)path completion:(void(^)(NSDate* lastModifiedDate, NSError* error))complBlock
{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]init];
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    request.HTTPMethod = @"HEAD";
    request.URL = [NSURL URLWithString:path];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(connectionError)
        {
            NSLog(@"connection error : %@", connectionError.debugDescription);
            if(complBlock) complBlock(nil, connectionError);
        }
        else
        {
            NSDictionary* headers = ((NSHTTPURLResponse*)response).allHeaderFields;
            NSString* dateString = [headers objectForKey:@"Last-Modified"];
            if(dateString)
            {
                NSDate* lastModifDate = [self dateFromString:dateString];
                complBlock(lastModifDate, nil);
            }
            else
            {
                NSError* noImageError = [NSError errorWithDomain:@"rue" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image not found."}];
                complBlock(nil, noImageError);
            }
        }
    }];
}

- (void) downloadImageFromPath:(NSString*)path completion:(void(^)(UIImage* image, NSDate* lastModifiedDate, NSError* error))complBlock
{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]init];
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    request.HTTPMethod = @"GET";
    request.URL = [NSURL URLWithString:path];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(connectionError)
        {
            NSLog(@"connection error : %@", connectionError.debugDescription);
            if(complBlock) complBlock(nil, nil, connectionError);
        }
        else
        {
            NSDictionary* headers = ((NSHTTPURLResponse*)response).allHeaderFields;
            NSString* dateString = [headers objectForKey:@"Last-Modified"];
            UIImage* image = [UIImage imageWithData:data];
            if(dateString && image)
            {
                NSDate* lastModifDate = [self dateFromString:dateString];
                complBlock(image, lastModifDate, nil);
            }
            else
            {
                NSError* noImageError = [NSError errorWithDomain:@"rue" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image not found."}];
                complBlock(nil, nil, noImageError);
            }
        }
    }];
}

- (NSDate*) dateFromString:(NSString*)dateString
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUSPOSIXLocale];
    [formatter setDateFormat:@"EEE, dd MMM yyy HH':'mm':'ss Z"];
    return [formatter dateFromString:dateString];
}

/*- (NSString*) stringFromDate:(NSDate*)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUSPOSIXLocale];
    [formatter setDateFormat:@"EEE, dd MMM yyy HH':'mm':'ss Z"];
    return [formatter stringFromDate:date];
}*/

@end
