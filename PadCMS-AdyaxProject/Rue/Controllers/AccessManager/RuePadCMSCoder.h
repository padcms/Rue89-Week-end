//
//  RuePadCMSCoder.h
//  Pad CMS
//
//  Created by Maksym Martyniuk on 11/26/13.
//  Copyright (c) 2013 Adyax. All rights reserved.
//

#import "PadCMSCoder.h"

@interface RuePadCMSCoder : PadCMSCoder

+ (NSDictionary*) applicationParametersFromCuurentPlistContent;

/**@brief Check on server if parameters changed and need to be update.
 @param previousParameters application parameters that is checking for update.
 @param completionBlock block that executes when operation complete. If parameters is up to date then error is nil and isOutdated is NO.*/

+ (void) isParametersOutdated:(NSDictionary*)previousParameters completion:(void(^)(NSError* error, BOOL isOutdated))completionBlock;

/**@brief Returns YES if issues list conteins unpublished issues
 @param parameters application parameters dictionary from server.plist file.
 @return YES if publisher mode parameter is true. NO if publisher parameter is false on not finded.*/

+ (BOOL) isInPublisherMode:(NSDictionary*)parameters;

+ (NSDictionary*) setInPublisherMode:(NSDictionary*)parameters;

/**@brief Download issues list synchronously with publisher password from server and store it to server.plist file.
 @param password publisher passwor to get unpublished issues or @"" if no password.
 @return YES if issue list was successfuly downloaded and writed to disk, otherwise NO.*/

- (BOOL) syncServerPlistDownloadWithPassword:(NSString*)password;

/**@brief Download issues list Asynchronously with publisher password from server and store it to server.plist file.
 @param password publisher passwor to get unpublished issues or @"" if no password.
 @param complBlock block executed when operation complete. If issues list successfuly downloaded and writed to file then error parameter is nil.*/

- (void) syncServerPlistDownloadAsynchronouslyWithPassword:(NSString*)password completion:(void(^)(NSError*))complBlock;

@end
