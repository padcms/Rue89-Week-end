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

+ (void) isParametersOutdated:(NSDictionary*)previousParameters completion:(void(^)(NSError* error, BOOL isOutdated))completionBlock;

+ (BOOL) isInPublisherMode:(NSDictionary*)parameters;
+ (NSDictionary*) setInPublisherMode:(NSDictionary*)parameters;

- (BOOL) syncServerPlistDownloadWithPassword:(NSString*)password;

- (void) syncServerPlistDownloadAsynchronouslyWithPassword:(NSString*)password completion:(void(^)(NSError*))complBlock;

@end
